<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Pharmacy;
use Illuminate\Support\Facades\DB;

class PharmacyController extends Controller
{
    public function list()
    {
        // Get approved pharmacy IDs from the auth DB (uses AUTH_DB_* env vars)
        $approvedPharmacyIds = DB::connection('auth_db')
            ->table('utilisateurs')
            ->where('role', 'pharmacien')
            ->where('statut', 'actif')
            ->whereNotNull('idPharmacie')
            ->pluck('idPharmacie')
            ->toArray();

        $pharmacies = Pharmacy::whereIn('idPharmacie', $approvedPharmacyIds)->get();

        $formatted = $pharmacies->map(function ($p) {
            
            $scheduleMap = [];
            $isOnCall = false;
            
            foreach ($p->horaires as $h) {
                $times = substr($h->heureOuverture, 0, 5) . '-' . substr($h->heureFermeture, 0, 5);
                $scheduleMap[$h->jourSemaine] = $times;
                
                // Check if pharmacy is on guard today
                if ($h->deGarde) {
                    $isOnCall = true;
                }
            }

            $meds = $p->stocks->pluck('medicament_nom')->toArray();

            return [
                'id' => (string) $p->idPharmacie,
                'name' => $p->nom,
                'address' => $p->adresse,
                'lat' => (float) $p->latitude,
                'lng' => (float) $p->longitude,
                'distance_fallback' => 'Calculated in App', 
                'phone' => $p->telephone,
                'medications' => $meds,
                'is_on_call' => $isOnCall,
                'schedule' => $scheduleMap
            ];
        });

        return response()->json($formatted);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'nom' => 'required|string|max:255',
            'adresse' => 'required|string|max:255',
            'telephone' => 'required|string|max:20',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        DB::table('pharmacies')
            ->where('idPharmacie', $id)
            ->update([
                'nom' => $request->nom,
                'adresse' => $request->adresse,
                'telephone' => $request->telephone,
                'latitude' => $request->latitude,
                'longitude' => $request->longitude,
                'updated_at' => now(),
            ]);

        return response()->json(['message' => 'Pharmacy updated successfully']);
    }

    public function getSchedules($pharmacyId)
    {
        try {
            $schedules = DB::table('horaire_pharmacies')
                ->where('idPharmacie', $pharmacyId)
                ->get();

            return response()->json(['data' => $schedules]);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Failed to fetch schedules'], 500);
        }
    }

    public function updateSchedules(Request $request, $pharmacyId)
    {
        try {
            $request->validate([
                'horaires' => 'required|array',
                'horaires.*.jourSemaine' => 'required|string',
                'horaires.*.heureOuverture' => 'nullable|string',
                'horaires.*.heureFermeture' => 'nullable|string',
                'horaires.*.deGarde' => 'required|boolean',
            ]);

            $horaires = $request->input('horaires');

            foreach ($horaires as $horaire) {
                DB::table('horaire_pharmacies')
                    ->where('idPharmacie', $pharmacyId)
                    ->where('jourSemaine', $horaire['jourSemaine'])
                    ->update([
                        'heureOuverture' => $horaire['heureOuverture'],
                        'heureFermeture' => $horaire['heureFermeture'],
                        'deGarde' => $horaire['deGarde'],
                        'updated_at' => now(),
                    ]);
            }

            return response()->json(['message' => 'Schedules updated successfully']);
        } catch (\Exception $e) {
        \Log::error('Failed to update schedules: ' . $e->getMessage());
        \Log::error('Stack trace: ' . $e->getTraceAsString());
        return response()->json([
            'error' => 'Failed to update schedules',
            'message' => $e->getMessage()
        ], 500);
        }
    }
}