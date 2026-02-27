<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class AdminPharmacistController extends Controller
{
    /**
     * Get all pending pharmacist applications
     */
    public function pending()
    {
        try {
            $pharmacists = User::where('role', 'pharmacien')
                ->where('statut', 'en_attente')
                ->orderBy('created_at', 'desc')
                ->get();

            // Attach pharmacy data if available
            $pharmacists->each(function($pharmacist) {
                try {
                    $pharmacy = DB::connection('pharmacy')
                        ->table('pharmacies')
                        ->where('idPharmacien', $pharmacist->idUtilisateur)
                        ->first();

                    if ($pharmacy) {
                        $pharmacist->pharmacy = $pharmacy;
                    }
                } catch (\Exception $e) {
                    Log::warning("Failed to fetch pharmacy for user {$pharmacist->idUtilisateur}");
                }
            });

            return response()->json([
                'pharmacists' => $pharmacists
            ]);
        } catch (\Exception $e) {
            Log::error('Fetch pending pharmacists error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors du chargement'], 500);
        }
    }

    /**
     * Get all pharmacists with optional filters
     */
    public function index(Request $request)
    {
        try {
            $query = User::where('role', 'pharmacien');

            // Filter by status (supports comma-separated values, e.g. 'actif,suspendu')
            if ($request->has('statut')) {
                $statuts = explode(',', $request->statut);
                $query->whereIn('statut', $statuts);
            }

            // Search by name or email
            if ($request->has('search')) {
                $search = $request->search;
                $query->where(function($q) use ($search) {
                    $q->where('nomComplet', 'like', "%{$search}%")
                      ->orWhere('email', 'like', "%{$search}%");
                });
            }

            $pharmacists = $query->orderBy('created_at', 'desc')->get();

            // Attach pharmacy data if available
            $pharmacists->each(function($pharmacist) {
                try {
                    $pharmacy = DB::connection('pharmacy')
                        ->table('pharmacies')
                        ->where('idPharmacien', $pharmacist->idUtilisateur)
                        ->first();
                    
                    if ($pharmacy) {
                        $pharmacist->pharmacy = $pharmacy;
                    }
                } catch (\Exception $e) {
                    Log::warning("Failed to fetch pharmacy for user {$pharmacist->idUtilisateur}");
                }
            });

            return response()->json([
                'pharmacists' => $pharmacists
            ]);
        } catch (\Exception $e) {
            Log::error('Fetch pharmacists error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors du chargement'], 500);
        }
    }

    /**
     * Approve a pharmacist application
     */
    public function approve(Request $request, $id)
    {
        try {
            $pharmacist = User::where('idUtilisateur', $id)
                ->where('role', 'pharmacien')
                ->first();

            if (!$pharmacist) {
                return response()->json(['message' => 'Pharmacien non trouvé'], 404);
            }

            $pharmacist->statut = 'actif';
            $pharmacist->save();

            // Send approval email
            $this->sendApprovalEmail($pharmacist);

            return response()->json([
                'message' => 'Pharmacien approuvé avec succès',
                'pharmacist' => $pharmacist
            ]);
        } catch (\Exception $e) {
            Log::error('Approve pharmacist error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors de l\'approbation'], 500);
        }
    }

    /**
     * Reject or suspend a pharmacist
     */
    public function reject(Request $request, $id)
    {
        $request->validate([
            'reason' => 'nullable|string',
        ]);

        try {
            $pharmacist = User::where('idUtilisateur', $id)
                ->where('role', 'pharmacien')
                ->first();

            if (!$pharmacist) {
                return response()->json(['message' => 'Pharmacien non trouvé'], 404);
            }

            $pharmacist->statut = 'suspendu';
            $pharmacist->save();

            // Send rejection email
            $this->sendRejectionEmail($pharmacist, $request->reason);

            return response()->json([
                'message' => 'Pharmacien rejeté/suspendu',
                'pharmacist' => $pharmacist
            ]);
        } catch (\Exception $e) {
            Log::error('Reject pharmacist error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors du rejet'], 500);
        }
    }

    /**
     * Get pharmacist details
     */
    public function show($id)
    {
        try {
            $pharmacist = User::where('idUtilisateur', $id)
                ->where('role', 'pharmacien')
                ->first();

            if (!$pharmacist) {
                return response()->json(['message' => 'Pharmacien non trouvé'], 404);
            }

            // Get pharmacy data
            try {
                $pharmacy = DB::connection('pharmacy')
                    ->table('pharmacies')
                    ->where('idPharmacien', $pharmacist->idUtilisateur)
                    ->first();
                
                if ($pharmacy) {
                    $pharmacist->pharmacy = $pharmacy;
                }
            } catch (\Exception $e) {
                Log::warning("Failed to fetch pharmacy for user {$pharmacist->idUtilisateur}");
            }

            return response()->json([
                'pharmacist' => $pharmacist
            ]);
        } catch (\Exception $e) {
            Log::error('Fetch pharmacist error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors du chargement'], 500);
        }
    }

    /**
     * Send approval email to pharmacist
     */
    private function sendApprovalEmail($pharmacist)
    {
        try {
            Mail::send('emails.pharmacist-approved', ['user' => $pharmacist], function($message) use ($pharmacist) {
                $message->to($pharmacist->email)
                    ->subject('SmartPharma - Compte Approuvé');
            });
        } catch (\Exception $e) {
            Log::error('Failed to send approval email: ' . $e->getMessage());
        }
    }

    /**
     * Send rejection email to pharmacist
     */
    private function sendRejectionEmail($pharmacist, $reason = null)
    {
        try {
            Mail::send('emails.pharmacist-rejected', [
                'user' => $pharmacist,
                'reason' => $reason
            ], function($message) use ($pharmacist) {
                $message->to($pharmacist->email)
                    ->subject('SmartPharma - Compte Suspendu');
            });
        } catch (\Exception $e) {
            Log::error('Failed to send rejection email: ' . $e->getMessage());
        }
    }

    /**
     * Delete a user (pharmacist or client)
     */
    public function destroy(Request $request, $id)
    {
        try {
            $user = User::where('idUtilisateur', $id)->first();

            if (!$user) {
                return response()->json(['message' => 'Utilisateur non trouvé'], 404);
            }

            // Prevent admin from deleting themselves
            if ($request->user()->idUtilisateur == $id) {
                return response()->json(['message' => 'Vous ne pouvez pas supprimer votre propre compte'], 403);
            }

            // Prevent deleting other admins
            if ($user->role === 'admin') {
                return response()->json(['message' => 'Impossible de supprimer un compte administrateur'], 403);
            }

            // If pharmacist, delete associated pharmacy
            if ($user->role === 'pharmacien' && $user->idPharmacie) {
                try {
                    DB::connection('pharmacy')
                        ->table('pharmacies')
                        ->where('idPharmacien', $user->idUtilisateur)
                        ->delete();
                } catch (\Exception $e) {
                    Log::warning("Failed to delete pharmacy for user {$user->idUtilisateur}: " . $e->getMessage());
                }
            }

            // Delete license photo if exists
            if ($user->photo_licence) {
                try {
                    Storage::delete($user->photo_licence);
                } catch (\Exception $e) {
                    Log::warning("Failed to delete license photo: " . $e->getMessage());
                }
            }

            // Delete the user
            $userName = $user->nomComplet;
            $user->delete();

            return response()->json([
                'message' => "Utilisateur {$userName} supprimé avec succès"
            ]);
        } catch (\Exception $e) {
            Log::error('Delete user error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors de la suppression'], 500);
        }
    }
}
