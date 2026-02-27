<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\Rules\Password;
use App\Mail\ResetPasswordCode;
use Carbon\Carbon;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use App\Http\Requests\RegisterRequest;


class AuthController extends Controller
{
    public function register(RegisterRequest $request)
    {
        $fields = $request->validated();

        return DB::transaction(function () use ($fields, $request) {
            $photoLicencePath = null;
            if ($fields['role'] === 'pharmacien' && $request->hasFile('photo_licence')) {
                $file = $request->file('photo_licence');
                $filename = 'licence_' . time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
                $file->storeAs('licenses', $filename, 'local');
                $photoLicencePath = 'licenses/' . $filename;
            }

            $statut = $fields['role'] === 'client' ? 'actif' : 'en_attente';

            $user = User::create([
                'nomComplet' => $fields['nomComplet'],
                'email' => $fields['email'],
                'motDePasse' => Hash::make($fields['motDePasse']),
                'telephone' => $fields['telephone'],
                'role' => $fields['role'],
                'statut' => $statut,
                'photo_licence' => $photoLicencePath,
                'adresse' => $fields['role'] === 'pharmacien' ? $fields['pharmacyAddress'] : null,
            ]);

            if ($fields['role'] === 'pharmacien') {
                try {
                    $pharmacyId = DB::connection('pharmacy')->table('pharmacies')->insertGetId([
                        'idPharmacien' => $user->idUtilisateur,
                        'nom' => $fields['pharmacyName'],
                        'adresse' => $fields['pharmacyAddress'],
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);

                    $user->pharmacy = (object) [
                        'id' => $pharmacyId,
                        'nom' => $fields['pharmacyName']
                    ];
                } catch (\Exception $e) {
                    $user->delete();
                    return response()->json(['message' => 'Erreur pharmacie DB: ' . $e->getMessage()], 422);
                }
            }

            if ($fields['role'] === 'pharmacien') {
                // Send confirmation email to pharmacist
                $this->sendRegistrationPendingEmail($user);

                return response()->json([
                    'message' => 'Compte créé. Veuillez attendre la vérification de votre licence.',
                    'user' => $user,
                    'status' => 'pending',
                ], 201);
            }

            return response()->json([
                'message' => 'Compte créé avec succès',
                'user' => $user,
                'token' => $user->createToken('API Token')->plainTextToken
            ], 201);
        });
    }

    /**
     * Send registration pending confirmation email to pharmacist
     */
    private function sendRegistrationPendingEmail($pharmacist)
    {
        try {
            // Get pharmacy info
            $pharmacy = null;
            try {
                $pharmacy = DB::connection('pharmacy')
                    ->table('pharmacies')
                    ->where('idPharmacien', $pharmacist->idUtilisateur)
                    ->first();
            } catch (\Exception $e) {
                Log::warning('Could not fetch pharmacy for email');
            }

            Mail::send('emails.pharmacist-registration-pending', [
                'pharmacist' => $pharmacist,
                'pharmacy' => $pharmacy
            ], function($message) use ($pharmacist) {
                $message->to($pharmacist->email)
                    ->subject('SmartPharma - Compte en cours de vérification');
            });
        } catch (\Exception $e) {
            Log::error('Failed to send registration pending email: ' . $e->getMessage());
        }
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'sometimes|required',
            'motDePasse' => 'sometimes|required',
        ]);

        $password = $request->password ?? $request->motDePasse;
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($password, $user->motDePasse)) {
            return response()->json(['message' => 'Email ou mot de passe incorrect'], 401);
        }

        $token = $user->createToken('API Token')->plainTextToken;

        if ($user->role === 'pharmacien' || $user->role === 'pharmacist') {
            try {
                $pharmacy = DB::connection('pharmacy')->table('pharmacies')->where('idPharmacien', $user->idUtilisateur)->first();
                if ($pharmacy) {
                    $user = $user->toArray();
                    $user['pharmacy'] = $pharmacy;
                    $user['pharmacyId'] = $pharmacy->idPharmacie;
                }
            } catch (\Exception $e) {
                Log::warning('Failed to fetch pharmacy data: ' . $e->getMessage());
            }
        }

        return response()->json([
            'message' => 'Connexion réussie',
            'user' => $user,
            'token' => $token
        ]);
    }

    public function googleLogin(Request $request)
    {
        $request->validate([
            'id_token' => 'required|string',
        ]);

        try {
            // Verify the Google ID token
            $googleClientId = env('GOOGLE_CLIENT_ID');
            /** @var \Illuminate\Http\Client\Response $response */
            $response = Http::get("https://oauth2.googleapis.com/tokeninfo", [
                'id_token' => $request->id_token,
            ]);

            if ($response->failed()) {
                Log::error('Google token verification failed', [
                    'status' => $response->status(),
                    'body' => $response->body()
                ]);
                return response()->json(['message' => 'Token Google invalide'], 401);
            }

            $googleData = $response->json();
            Log::info('Google token verified', [
                'email' => $googleData['email'] ?? 'no-email',
                'aud' => $googleData['aud'] ?? 'no-aud',
                'expected_aud' => $googleClientId
            ]);

            // Verify the token is for our app
            // Google tokens can have aud as string or array, so we handle both
            $tokenAudience = $googleData['aud'] ?? null;
            $isValidAudience = false;
            
            if (is_array($tokenAudience)) {
                $isValidAudience = in_array($googleClientId, $tokenAudience);
            } else {
                $isValidAudience = ($tokenAudience === $googleClientId);
            }
            
            if (!$isValidAudience) {
                Log::error('Google token audience mismatch', [
                    'received' => $tokenAudience,
                    'expected' => $googleClientId,
                    'type' => gettype($tokenAudience)
                ]);
                return response()->json(['message' => 'Token non autorisé pour cette application'], 401);
            }

            $googleId = $googleData['sub'];
            $email = $googleData['email'];
            $name = $googleData['name'] ?? $googleData['email'];

            // Find existing user by google_id or email
            $user = User::where('google_id', $googleId)->orWhere('email', $email)->first();

            if (!$user) {
                // Create new user
                $user = User::create([
                    'nomComplet' => $name,
                    'email' => $email,
                    'google_id' => $googleId,
                    'motDePasse' => Hash::make(Str::random(32)),
                    'role' => 'client',
                    'statut' => 'actif',
                ]);
            } else {
                // Update google_id if not set
                if (!$user->google_id) {
                    $user->google_id = $googleId;
                    $user->save();
                }
            }

            $token = $user->createToken('API Token')->plainTextToken;

            // Fetch pharmacy data if pharmacist
            if ($user->role === 'pharmacien' || $user->role === 'pharmacist') {
                try {
                    $pharmacy = DB::connection('pharmacy')->table('pharmacies')->where('idPharmacien', $user->idUtilisateur)->first();
                    if ($pharmacy) {
                        $user = $user->toArray();
                        $user['pharmacy'] = $pharmacy;
                        $user['pharmacyId'] = $pharmacy->idPharmacie;
                    }
                } catch (\Exception $e) {
                    Log::warning('Failed to fetch pharmacy data: ' . $e->getMessage());
                }
            }

            return response()->json([
                'message' => 'Connexion Google réussie',
                'user' => $user,
                'token' => $token
            ]);

        } catch (\Exception $e) {
            Log::error('Google Login Error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors de la connexion Google: ' . $e->getMessage()], 500);
        }
    }

    public function facebookLogin(Request $request)
    {
        $request->validate([
            'access_token' => 'required|string',
        ]);

        try {
            // Verify the Facebook access token and get user data
            Log::info('Facebook Login Attempt', ['access_token' => substr($request->access_token, 0, 20) . '...']);
            
            /** @var \Illuminate\Http\Client\Response $response */
            $response = Http::timeout(30)->get("https://graph.facebook.com/me", [
                'fields' => 'id,name,email',
                'access_token' => $request->access_token,
            ]);

            Log::info('Facebook API Response', [
                'status' => $response->status(),
                'body' => $response->json()
            ]);

            if ($response->failed()) {
                Log::error('Facebook Token Validation Failed', ['response' => $response->json()]);
                return response()->json([
                    'message' => 'Token Facebook invalide',
                    'debug' => $response->json()
                ], 401);
            }

            $facebookData = $response->json();

            // Check if email is provided
            if (!isset($facebookData['email'])) {
                Log::error('Email not provided by Facebook', ['data' => $facebookData]);
                return response()->json(['message' => 'Email non fourni par Facebook'], 401);
            }

            $facebookId = $facebookData['id'];
            $email = $facebookData['email'];
            $name = $facebookData['name'] ?? $email;

            // Find existing user by facebook_id or email
            $user = User::where('facebook_id', $facebookId)->orWhere('email', $email)->first();

            if (!$user) {
                // Create new user
                $user = User::create([
                    'nomComplet' => $name,
                    'email' => $email,
                    'facebook_id' => $facebookId,
                    'motDePasse' => Hash::make(Str::random(32)),
                    'role' => 'client',
                    'statut' => 'actif',
                ]);
            } else {
                // Update facebook_id if not set
                if (!$user->facebook_id) {
                    $user->facebook_id = $facebookId;
                    $user->save();
                }
            }

            $token = $user->createToken('API Token')->plainTextToken;

            // Fetch pharmacy data if pharmacist
            if ($user->role === 'pharmacien' || $user->role === 'pharmacist') {
                try {
                    $pharmacy = DB::connection('pharmacy')->table('pharmacies')->where('idPharmacien', $user->idUtilisateur)->first();
                    if ($pharmacy) {
                        $user = $user->toArray();
                        $user['pharmacy'] = $pharmacy;
                        $user['pharmacyId'] = $pharmacy->idPharmacie;
                    }
                } catch (\Exception $e) {
                    Log::warning('Failed to fetch pharmacy data: ' . $e->getMessage());
                }
            }

            return response()->json([
                'message' => 'Connexion Facebook réussie',
                'user' => $user,
                'token' => $token
            ]);

        } catch (\Exception $e) {
            Log::error('Facebook Login Error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors de la connexion Facebook: ' . $e->getMessage()], 500);
        }
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Déconnexion réussie']);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $data = $request->validate([
            'nomComplet' => 'sometimes|string|min:3|max:100',
            'name' => 'sometimes|string|min:3|max:100',
            'telephone' => 'sometimes|string|max:20',
            'phone' => 'sometimes|string|max:20',
            'ville' => 'sometimes|string|max:100',
            'city' => 'sometimes|string|max:100',
            'adresse' => 'sometimes|string|max:255',
            'address' => 'sometimes|string|max:255',
            // Photo validation removed
        ]);

        if (isset($data['name'])) {
            $user->nomComplet = $data['name'];
        }
        if (isset($data['phone'])) {
            $user->telephone = $data['phone'];
        }
        if (isset($data['city'])) {
            $user->ville = $data['city'];
        }
        if (isset($data['address'])) {
            $user->adresse = $data['address'];
        }

        // Photo upload logic removed per user request

        if (isset($data['nomComplet'])) {
            $user->nomComplet = $data['nomComplet'];
        }
        if (isset($data['telephone'])) {
            $user->telephone = $data['telephone'];
        }
        if (isset($data['ville'])) {
            $user->ville = $data['ville'];
        }
        if (isset($data['adresse'])) {
            $user->adresse = $data['adresse'];
        }

        $user->save();

        $userData = $user->toArray();
        // Photo URL generation removed

        return response()->json([
            'message' => 'Profil mis à jour avec succès',
            'user' => $userData
        ]);
    }

    public function changePassword(Request $request)
    {
        $user = $request->user();
        $request->validate([
            'currentPassword' => 'required',
            'newPassword' => ['required', 'confirmed', Password::min(8)->letters()->mixedCase()->numbers()->symbols()],
        ]);

        if (!Hash::check($request->currentPassword, $user->motDePasse)) {
            return response()->json(['message' => 'Mot de passe actuel incorrect'], 422);
        }

        $user->motDePasse = Hash::make($request->newPassword);
        $user->save();

        return response()->json(['message' => 'Mot de passe modifié avec succès']);
    }

    public function updateDeviceToken(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string'
        ]);

        $user = $request->user();
        $user->fcm_token = $request->fcm_token;
        $user->save();

        return response()->json(['message' => 'Token updated successfully']);
    }

    public function forgotPassword(Request $request)
    {
        $request->validate(['email' => 'required|email|exists:utilisateurs,email']);

        $code = rand(1000, 9999);

        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $request->email],
            [
                'token' => $code,
                'created_at' => Carbon::now()
            ]
        );

        try {
            Mail::to($request->email)->send(new ResetPasswordCode($code));
        } catch (\Exception $e) {
            Log::error("Mail Error: " . $e->getMessage());
            return response()->json(['message' => 'Erreur technique lors de l\'envoi (SMTP).'], 500);
        }

        return response()->json(['message' => 'Code envoyé. Vérifiez votre email.']);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:utilisateurs,email',
            'code' => 'required|numeric',
            'password' => ['required', 'confirmed', Password::min(8)->letters()->mixedCase()->numbers()->symbols()],
        ]);

        $record = DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->where('token', $request->code)
            ->first();

        if (!$record) {
            return response()->json(['message' => 'Code invalide.'], 400);
        }

        if (Carbon::parse($record->created_at)->addMinutes(15)->isPast()) {
            return response()->json(['message' => 'Code expiré.'], 400);
        }

        $user = User::where('email', $request->email)->first();
        $user->motDePasse = Hash::make($request->password);
        $user->save();

        DB::table('password_reset_tokens')->where('email', $request->email)->delete();

        return response()->json(['message' => 'Mot de passe réinitialisé avec succès.']);
    }
}
