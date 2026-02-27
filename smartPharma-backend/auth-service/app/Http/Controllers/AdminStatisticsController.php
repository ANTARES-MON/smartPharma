<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AdminStatisticsController extends Controller
{
    /**
     * Get detailed statistics for a pharmacist
     */
    public function pharmacistStats($id)
    {
        try {
            $user = User::where('idUtilisateur', $id)->first();

            if (!$user || $user->role !== 'pharmacien') {
                return response()->json(['message' => 'Pharmacien non trouvé'], 404);
            }

            $stats = [];

            // Get pharmacy ID from pharmacy database
            if ($user->pharmacy) {
                $pharmacyId = $user->pharmacy->idPharmacie;

                // Connect to pharmacy database for medication count
                $pharmacyConnection = DB::connection('pharmacy');
                $medicationCount = $pharmacyConnection->table('stock_pharmacies')
                    ->where('idPharmacie', $pharmacyId)
                    ->count();

                // Connect to reservation database for reservation stats
                $reservationConnection = DB::connection('reservation');
                $totalReservations = $reservationConnection->table('reservations')
                    ->where('idPharmacie', $pharmacyId)
                    ->count();

                $completedReservations = $reservationConnection->table('reservations')
                    ->where('idPharmacie', $pharmacyId)
                    ->where('statut', 'terminee')
                    ->count();

                $pendingReservations = $reservationConnection->table('reservations')
                    ->where('idPharmacie', $pharmacyId)
                    ->whereIn('statut', ['en_attente', 'confirmee', 'prete'])
                    ->count();

                $stats = [
                    'total_medications' => $medicationCount,
                    'total_reservations' => $totalReservations,
                    'completed_reservations' => $completedReservations,
                    'pending_reservations' => $pendingReservations,
                    'pharmacy_id' => $pharmacyId,
                ];
            } else {
                $stats = [
                    'total_medications' => 0,
                    'total_reservations' => 0,
                    'completed_reservations' => 0,
                    'pending_reservations' => 0,
                    'pharmacy_id' => null,
                ];
            }

            return response()->json([
                'stats' => $stats
            ]);
        } catch (\Exception $e) {
            Log::error('Pharmacist stats error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors du chargement'], 500);
        }
    }

    /**
     * Get detailed statistics for a client
     */
    public function clientStats($id)
    {
        try {
            $user = User::where('idUtilisateur', $id)->first();

            if (!$user || $user->role !== 'client') {
                return response()->json(['message' => 'Client non trouvé'], 404);
            }

            // Connect to reservation database
            $reservationConnection = DB::connection('reservation');
            
            $totalReservations = $reservationConnection->table('reservations')
                ->where('idUtilisateur', $id)
                ->count();

            $completedReservations = $reservationConnection->table('reservations')
                ->where('idUtilisateur', $id)
                ->where('statut', 'terminee')
                ->count();

            $cancelledReservations = $reservationConnection->table('reservations')
                ->where('idUtilisateur', $id)
                ->where('statut', 'annulee')
                ->count();

            // Get most recent reservations
            $recentReservations = $reservationConnection->table('reservations')
                ->where('idUtilisateur', $id)
                ->orderBy('created_at', 'desc')
                ->limit(5)
                ->get(['nomMedicament', 'statut', 'created_at']);

            $stats = [
                'total_reservations' => $totalReservations,
                'completed_reservations' => $completedReservations,
                'cancelled_reservations' => $cancelledReservations,
                'recent_reservations' => $recentReservations,
            ];

            return response()->json([
                'stats' => $stats
            ]);
        } catch (\Exception $e) {
            Log::error('Client stats error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors du chargement'], 500);
        }
    }
}
