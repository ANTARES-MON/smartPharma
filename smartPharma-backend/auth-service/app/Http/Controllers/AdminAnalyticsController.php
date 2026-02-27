<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class AdminAnalyticsController extends Controller
{
    /**
     * Get dashboard statistics
     */
    public function stats()
    {
        try {
            // Only count active non-admin users (exclude admins and en_attente)
            $totalUsers = User::whereIn('role', ['client', 'pharmacien'])
                ->where('statut', 'actif')
                ->count();
            $totalClients = User::where('role', 'client')->where('statut', 'actif')->count();
            $totalPharmacists = User::where('role', 'pharmacien')->where('statut', 'actif')->count();
            $pendingPharmacists = User::where('role', 'pharmacien')
                ->where('statut', 'en_attente')
                ->count();
            $activePharmacists = User::where('role', 'pharmacien')
                ->where('statut', 'actif')
                ->count();

            // Active pharmacies = pharmacies whose pharmacist is actif
            $activePharmacistIds = User::where('role', 'pharmacien')
                ->where('statut', 'actif')
                ->pluck('idUtilisateur')
                ->toArray();

            $activePharmacies = 0;
            try {
                $activePharmacies = DB::connection('pharmacy')
                    ->table('pharmacies')
                    ->whereIn('idPharmacien', $activePharmacistIds)
                    ->count();
                $totalPharmacies = $activePharmacies; // same — no inactive concept in schema
            } catch (\Exception $e) {
                Log::warning('Failed to count pharmacies: ' . $e->getMessage());
            }

            // Get reservation count
            $totalReservations = 0;
            try {
                $totalReservations = DB::connection('pharmacy')
                    ->table('reservations')
                    ->count();
            } catch (\Exception $e) {
                Log::warning('Failed to count reservations: ' . $e->getMessage());
            }

            // Recent registrations (last 7 days)
            $recentRegistrations = User::where('created_at', '>=', Carbon::now()->subDays(7))
                ->count();

            return response()->json([
                'stats' => [
                    'totalUsers' => $totalUsers,
                    'totalClients' => $totalClients,
                    'totalPharmacists' => $totalPharmacists,
                    'pendingPharmacists' => $pendingPharmacists,
                    'activePharmacists' => $activePharmacists,
                    'totalPharmacies' => $totalPharmacies,
                    'totalReservations' => $totalReservations,
                    'recentRegistrations' => $recentRegistrations,
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Stats error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors du chargement des statistiques'], 500);
        }
    }

    /**
     * Get registration trends over time
     */
    public function registrations(Request $request)
    {
        try {
            $days = $request->get('days', 30);
            
            $registrations = User::select(
                    DB::raw('DATE(created_at) as date'),
                    DB::raw('COUNT(*) as count'),
                    DB::raw('SUM(CASE WHEN role = "client" THEN 1 ELSE 0 END) as clients'),
                    DB::raw('SUM(CASE WHEN role = "pharmacien" THEN 1 ELSE 0 END) as pharmacists')
                )
                ->where('created_at', '>=', Carbon::now()->subDays($days))
                ->groupBy('date')
                ->orderBy('date', 'asc')
                ->get();

            return response()->json([
                'registrations' => $registrations
            ]);
        } catch (\Exception $e) {
            Log::error('Registrations analytics error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors du chargement'], 500);
        }
    }

    /**
     * Get monthly activity stats
     */
    public function monthlyActivity()
    {
        try {
            $monthlyStats = [];
            
            for ($i = 5; $i >= 0; $i--) {
                $date = Carbon::now()->subMonths($i);
                $startOfMonth = $date->copy()->startOfMonth();
                $endOfMonth = $date->copy()->endOfMonth();

                $newUsers = User::whereBetween('created_at', [$startOfMonth, $endOfMonth])->count();
                
                $newReservations = 0;
                try {
                    $newReservations = DB::connection('pharmacy')
                        ->table('reservations')
                        ->whereBetween('dateReservation', [$startOfMonth, $endOfMonth])
                        ->count();
                } catch (\Exception $e) {
                    Log::warning('Failed to count monthly reservations');
                }

                $monthlyStats[] = [
                    'month' => $date->format('M Y'),
                    'users' => $newUsers,
                    'reservations' => $newReservations,
                ];
            }

            return response()->json([
                'monthlyActivity' => $monthlyStats
            ]);
        } catch (\Exception $e) {
            Log::error('Monthly activity error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors du chargement'], 500);
        }
    }

    /**
     * Get recent activity feed
     */
    public function recentActivity()
    {
        try {
            $recentUsers = User::whereIn('role', ['client', 'pharmacien'])
                ->orderBy('created_at', 'desc')
                ->take(10)
                ->get(['idUtilisateur', 'nomComplet', 'email', 'role', 'statut', 'created_at']);

            return response()->json([
                'recentActivity' => $recentUsers
            ]);
        } catch (\Exception $e) {
            Log::error('Recent activity error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors du chargement'], 500);
        }
    }
}
