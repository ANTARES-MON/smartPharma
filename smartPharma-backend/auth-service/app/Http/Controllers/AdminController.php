<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class AdminController extends Controller
{
    /**
     * Admin login
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        try {
            $user = User::where('email', $request->email)->first();

            if (!$user) {
                return response()->json(['message' => 'Identifiants invalides'], 401);
            }

            // Check if user is admin
            if ($user->role !== 'admin') {
                return response()->json(['message' => 'Accès non autorisé'], 403);
            }

            // Verify password
            if (!Hash::check($request->password, $user->motDePasse)) {
                return response()->json(['message' => 'Identifiants invalides'], 401);
            }

            // Create token
            $token = $user->createToken('Admin API Token')->plainTextToken;

            return response()->json([
                'message' => 'Connexion réussie',
                'user' => $user,
                'token' => $token
            ]);

        } catch (\Exception $e) {
            Log::error('Admin Login Error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors de la connexion'], 500);
        }
    }

    /**
     * Get admin profile
     */
    public function profile(Request $request)
    {
        return response()->json([
            'user' => $request->user()
        ]);
    }

    /**
     * Logout
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        
        return response()->json([
            'message' => 'Déconnexion réussie'
        ]);
    }
}
