<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Reservation;
use App\Models\User; 
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Pusher\Pusher; 

class ReservationController extends Controller
{
    // -------------------------------------------------------------------------
    // FCM Helper — sends a push notification via FCM HTTP v1 API
    // -------------------------------------------------------------------------
    private function sendFcmNotification(int $userId, string $title, string $body): void
    {
        try {
            // 1. Get the user's FCM token from auth_db
            $fcmToken = DB::connection('auth_db')
                ->table('utilisateurs')
                ->where('idUtilisateur', $userId)
                ->value('fcm_token');

            if (empty($fcmToken)) {
                Log::info("FCM: No token for user $userId — skipping push.");
                return;
            }

            // 2. Load service account credentials
            $credentialsPath = base_path('firebase-service-account.json');
            if (!file_exists($credentialsPath)) {
                Log::error("FCM: firebase-service-account.json not found.");
                return;
            }

            $credentials = json_decode(file_get_contents($credentialsPath), true);
            $projectId   = $credentials['project_id'];

            // 3. Generate a short-lived OAuth2 access token using JWT (RS256)
            $accessToken = $this->getFcmAccessToken($credentials);
            if (!$accessToken) {
                Log::error("FCM: Could not obtain OAuth2 access token.");
                return;
            }

            // 4. Build FCM v1 message payload
            $payload = [
                'message' => [
                    'token' => $fcmToken,
                    'notification' => [
                        'title' => $title,
                        'body'  => $body,
                    ],
                    'android' => [
                        'priority' => 'high',
                        'notification' => [
                            'channel_id'    => 'smart_pharma_channel',
                            'priority'      => 'max',
                            'default_sound' => true,
                            'default_vibrate_timings' => true,
                            'visibility'    => 'public',
                        ],
                    ],
                    'apns' => [
                        'payload' => [
                            'aps' => [
                                'alert' => [
                                    'title' => $title,
                                    'body'  => $body,
                                ],
                                'sound' => 'default',
                                'badge' => 1,
                            ],
                        ],
                        'headers' => [
                            'apns-priority' => '10',
                        ],
                    ],
                ],
            ];

            // 5. Send to FCM v1 API
            $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

            $ch = curl_init($url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json',
                "Authorization: Bearer $accessToken",
            ]);

            $result   = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            if ($httpCode === 200) {
                Log::info("FCM: Push sent to user $userId");
            } else {
                Log::error("FCM: Failed for user $userId. HTTP $httpCode. Response: $result");
            }

        } catch (\Exception $e) {
            Log::error("FCM: Exception for user $userId — " . $e->getMessage());
        }
    }

    // -------------------------------------------------------------------------
    // Generates a short-lived OAuth2 access token using a service account JWT
    // -------------------------------------------------------------------------
    private function getFcmAccessToken(array $credentials): ?string
    {
        try {
            $now = time();
            $exp = $now + 3600;

            $header  = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
            $claim   = base64_encode(json_encode([
                'iss'   => $credentials['client_email'],
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud'   => 'https://oauth2.googleapis.com/token',
                'exp'   => $exp,
                'iat'   => $now,
            ]));

            // URL-safe base64 (RFC 4648)
            $header = rtrim(strtr($header, '+/', '-_'), '=');
            $claim  = rtrim(strtr($claim,  '+/', '-_'), '=');

            $signingInput = "$header.$claim";

            $privateKey = $credentials['private_key'];
            openssl_sign($signingInput, $signature, $privateKey, 'SHA256');
            $sig = rtrim(strtr(base64_encode($signature), '+/', '-_'), '=');

            $jwt = "$signingInput.$sig";

            // Exchange JWT for an OAuth2 access token
            $ch = curl_init('https://oauth2.googleapis.com/token');
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion'  => $jwt,
            ]));

            $response = curl_exec($ch);
            curl_close($ch);

            $data = json_decode($response, true);
            return $data['access_token'] ?? null;

        } catch (\Exception $e) {
            Log::error("FCM JWT Error: " . $e->getMessage());
            return null;
        }
    }

    // -------------------------------------------------------------------------
    // Pusher helper
    // -------------------------------------------------------------------------
    private function getPusher()
    {
        $key     = config('broadcasting.connections.pusher.key') ?? env('PUSHER_APP_KEY');
        $secret  = config('broadcasting.connections.pusher.secret') ?? env('PUSHER_APP_SECRET');
        $appId   = config('broadcasting.connections.pusher.app_id') ?? env('PUSHER_APP_ID');
        $cluster = config('broadcasting.connections.pusher.options.cluster') ?? env('PUSHER_APP_CLUSTER');

        if (empty($key) || empty($secret) || empty($appId)) {
            Log::error("PUSHER CONFIG MISSING");
            return null;
        }

        return new Pusher($key, $secret, $appId, ['cluster' => $cluster, 'useTLS' => false]);
    }

    // --- 1. LIST ---
    public function index(Request $request)
    {
        $user = $request->user();
        
        if ($user->role === 'pharmacien') {
            if (!$user->idPharmacie) return response()->json(['data' => []], 200);

            $reservations = Reservation::with('utilisateur') 
                ->where('idPharmacie', $user->idPharmacie)
                ->orderBy('created_at', 'desc')
                ->get();

            foreach ($reservations as $res) {
                 $medName = DB::connection('pharmacy')->table('stock_pharmacies')
                    ->join('medicaments', 'stock_pharmacies.idMedicament', '=', 'medicaments.idMedicament')
                    ->where('stock_pharmacies.idStock', $res->idStock)
                    ->value('medicaments.nom');
                 $res->medication_name = $medName ?? 'Médicament';
            }
            return response()->json(['data' => $reservations]);
        } else {
            $reservations = Reservation::where('idUtilisateur', $user->idUtilisateur)
                ->orderBy('created_at', 'desc')
                ->get();

            foreach ($reservations as $res) {
                 $medName = DB::connection('pharmacy')->table('stock_pharmacies')
                    ->join('medicaments', 'stock_pharmacies.idMedicament', '=', 'medicaments.idMedicament')
                    ->where('stock_pharmacies.idStock', $res->idStock)
                    ->value('medicaments.nom');
                 
                 $pharma = DB::connection('pharmacy')->table('pharmacies')
                    ->where('idPharmacie', $res->idPharmacie)->first();

                 $res->medication_name = $medName ?? 'Médicament';
                 $res->pharmacy_name = $pharma->nom ?? 'Pharmacie';
                 $res->pharmacy_address = $pharma->adresse ?? '';
                 $res->pharmacy_phone = $pharma->telephone ?? '';
            }
            return response()->json(['data' => $reservations]);
        }
    }

    // --- 2. CREATE ---
    public function create(Request $request)
    {
        $request->validate([
            'idStock'    => 'required|integer',
            'idPharmacie' => 'required|integer',
            'quantite'   => 'required|integer|min:1',
        ]);

        $user = $request->user();

        try {
            return DB::transaction(function () use ($request, $user) {
                // A. Check Stock
                $stock = DB::connection('pharmacy')->table('stock_pharmacies')
                            ->where('idStock', $request->idStock)->lockForUpdate()->first();
                
                if (!$stock || $stock->quantite < $request->quantite) {
                    throw new \Exception('Stock insuffisant ou indisponible.');
                }

                // B. Deduct Stock
                DB::connection('pharmacy')->table('stock_pharmacies')
                    ->where('idStock', $request->idStock)
                    ->decrement('quantite', $request->quantite);

                // C. Create
                $reservation = Reservation::create([
                    'idUtilisateur'  => $user->idUtilisateur,
                    'idStock'        => $request->idStock,
                    'idPharmacie'    => $request->idPharmacie,
                    'quantiteDemande' => $request->quantite,
                    'statut'         => 'en_attente',
                    'dateReservation' => now(), 
                    'qr_code'        => uniqid('RES-'),
                ]);

                // D. Get medication name
                $medName = DB::connection('pharmacy')->table('stock_pharmacies')
                    ->join('medicaments', 'stock_pharmacies.idMedicament', '=', 'medicaments.idMedicament')
                    ->where('stock_pharmacies.idStock', $request->idStock)
                    ->value('medicaments.nom') ?? 'Médicament';

                $clientName = $user->nomComplet ?? $user->name ?? 'Un client';

                // E. DB Notifications
                DB::table('notifications')->insert([
                    'idUtilisateur' => $user->idUtilisateur,
                    'titre'         => "Commande envoyée",
                    'message'       => "Votre commande pour $medName est en attente.",
                    'lu'            => 0,
                    'type'          => 'order_created',
                    'data'          => json_encode(['reservation_id' => $reservation->id]),
                    'created_at'    => now(),
                    'updated_at'    => now()
                ]);

                $pharmacist = User::where('idPharmacie', $request->idPharmacie)
                                  ->where('role', 'pharmacien')->first();

                if ($pharmacist) {
                    DB::table('notifications')->insert([
                        'idUtilisateur' => $pharmacist->idUtilisateur, 
                        'titre'         => "Nouvelle commande",
                        'message'       => "$clientName a commandé $medName",
                        'lu'            => 0,
                        'type'          => 'order',
                        'data'          => json_encode([
                            'reservation_id' => $reservation->id,
                            'nom_patient'    => $clientName,
                            'nom_medicament' => $medName
                        ]),
                        'created_at'    => now(),
                        'updated_at'    => now()
                    ]);
                }

                // F. Pusher (in-app real-time)
                $pusher = $this->getPusher();
                if ($pusher) {
                    $pharmaChannel = 'private-pharmacy.' . $request->idPharmacie;
                    $reservation->utilisateur = $user; 
                    $reservation->medication_name = $medName;
                    $pusher->trigger($pharmaChannel, 'new-reservation', $reservation);

                    $userChannel = 'private-user.' . $user->idUtilisateur;
                    $pusher->trigger($userChannel, 'NotifyStatusUpdate', [
                        'id'      => $reservation->id,
                        'titre'   => "Commande envoyée",
                        'message' => "Votre commande pour $medName est en attente.",
                        'type'    => 'order_created'
                    ]);
                }

                // G. FCM Push (background / terminated app)
                if ($pharmacist) {
                    $this->sendFcmNotification(
                        $pharmacist->idUtilisateur,
                        "Nouvelle commande 💊",
                        "$clientName a commandé $medName"
                    );
                }

                // Also notify client (confirms their order was received)
                $this->sendFcmNotification(
                    $user->idUtilisateur,
                    "Commande envoyée ✅",
                    "Votre commande pour $medName est en attente de confirmation."
                );

                return response()->json(['message' => 'Réservation réussie', 'data' => $reservation], 201);
            });

        } catch (\Exception $e) {
            return response()->json(['message' => 'Erreur', 'error' => $e->getMessage()], 500);
        }
    }

    // --- 3. UPDATE STATUS ---
    public function updateStatus(Request $request, $id)
    {
        $statusMap     = ['cancelled' => 'refusee', 'rejected' => 'refusee', 'accepted' => 'acceptee', 'completed' => 'terminee', 'pending' => 'en_attente'];
        $statusLabels  = ['refusee' => 'refusée ❌', 'acceptee' => 'acceptée ✅', 'terminee' => 'terminée 🏁', 'en_attente' => 'en attente ⏳'];

        try {
            $reservation  = Reservation::findOrFail($id);
            $inputStatus  = $request->input('status'); 
            $newStatus    = $statusMap[$inputStatus] ?? 'en_attente';

            if (($newStatus === 'refusee' || $newStatus === 'annulee') && $reservation->statut === 'en_attente') {
                DB::connection('pharmacy')->table('stock_pharmacies')
                    ->where('idStock', $reservation->idStock)
                    ->increment('quantite', $reservation->quantiteDemande);
            }

            $reservation->statut = $newStatus;
            $reservation->save();

            try {
                $medName = DB::connection('pharmacy')->table('stock_pharmacies')
                    ->join('medicaments', 'stock_pharmacies.idMedicament', '=', 'medicaments.idMedicament')
                    ->where('stock_pharmacies.idStock', $reservation->idStock)
                    ->value('medicaments.nom') ?? 'Médicament';

                $label   = $statusLabels[$newStatus] ?? $inputStatus;
                $titre   = "Mise à jour de commande";
                $message = "Votre commande ($medName) est $label";

                // DB Notification
                DB::table('notifications')->insert([
                    'idUtilisateur' => $reservation->idUtilisateur,
                    'titre'         => $titre,
                    'message'       => $message,
                    'lu'            => 0,
                    'type'          => 'status_update',
                    'data'          => json_encode(['reservation_id' => $reservation->id]),
                    'created_at'    => now(),
                    'updated_at'    => now()
                ]);

                // Pusher (in-app)
                $pusher = $this->getPusher();
                if ($pusher) {
                    $channel = 'private-user.' . $reservation->idUtilisateur;
                    $pusher->trigger($channel, 'NotifyStatusUpdate', [
                        'id'              => $reservation->id,
                        'titre'           => $titre,
                        'message'         => $message,
                        'statut'          => $inputStatus,
                        'medication_name' => $medName
                    ]);
                }

                // FCM Push (background / terminated app)
                $this->sendFcmNotification(
                    $reservation->idUtilisateur,
                    $titre,
                    $message
                );

            } catch (\Exception $e) {
                Log::error("Notification send error: " . $e->getMessage());
            }

            return response()->json(['message' => 'Statut mis à jour', 'data' => $reservation]);

        } catch (\Exception $e) {
            return response()->json(['message' => 'Erreur', 'error' => $e->getMessage()], 500);
        }
    } 

    // --- 4. SCAN QR CODE ---
    public function scan(Request $request, $qrCode)
    {
        $user = $request->user();

        if ($user->role !== 'pharmacien') {
            return response()->json(['message' => 'Non autorisé'], 403);
        }

        try {
            Log::info("SCAN QR CODE", ['qr_code' => $qrCode]);
            
            $anyReservation = Reservation::where(function($query) use ($qrCode) {
                    $query->where('qr_code', $qrCode)
                          ->orWhere('qr_code', 'RES-' . $qrCode)
                          ->orWhere('idReservation', $qrCode);
                })
                ->first();
            
            if ($anyReservation) {
                Log::info("FOUND RESERVATION", [
                    'id'     => $anyReservation->idReservation,
                    'statut' => $anyReservation->statut,
                    'qr_code' => $anyReservation->qr_code
                ]);
            }
            
            $reservation = Reservation::where(function($query) use ($qrCode) {
                    $query->where('qr_code', $qrCode)
                          ->orWhere('qr_code', 'RES-' . $qrCode)
                          ->orWhere('idReservation', $qrCode);
                })
                ->where('statut', 'acceptee')
                ->with('utilisateur')
                ->first();

            if (!$reservation) {
                Log::warning("NO ACCEPTED RESERVATION FOUND");
                return response()->json([
                    'message' => 'Cette réservation n\'est pas encore acceptée ou n\'existe pas.'
                ], 404);
            }

            if ($reservation->idPharmacie != $user->idPharmacie) {
                return response()->json([
                    'message' => 'Cette réservation appartient à une autre pharmacie.'
                ], 403);
            }

            $medName = DB::connection('pharmacy')->table('stock_pharmacies')
                ->join('medicaments', 'stock_pharmacies.idMedicament', '=', 'medicaments.idMedicament')
                ->where('stock_pharmacies.idStock', $reservation->idStock)
                ->value('medicaments.nom');

            $reservation->medication_name = $medName ?? 'Médicament';

            return response()->json(['data' => $reservation], 200);

        } catch (\Exception $e) {
            return response()->json(['message' => 'Erreur serveur: ' . $e->getMessage()], 500);
        }
    }
}