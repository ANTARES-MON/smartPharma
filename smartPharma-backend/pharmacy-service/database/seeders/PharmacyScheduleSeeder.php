<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PharmacyScheduleSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Find the Pharmacy created in PharmacySeeder
        // We assume it has ID 1, or we search by name
        $pharmacy = DB::table('pharmacies')->where('nom', 'Pharmacie Al Majd')->first();

        if (!$pharmacy) {
            echo "⚠️ Pharmacie Al Majd not found. Skipping Schedule Seeder.\n";
            return;
        }

        $pharmacyId = $pharmacy->idPharmacie;
        $days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

        $schedules = [];

        foreach ($days as $day) {
            // Default: Open 09:00 to 19:00, except Sunday
            $isOpen = $day !== 'Dimanche';
            // Set all days to NOT on-call by default (pharmacist controls via toggle)
            $isOnCall = false;

            $schedules[] = [
                'idPharmacie'    => $pharmacyId,
                'jourSemaine'    => $day,
                'heureOuverture' => $isOpen ? '09:00:00' : null,
                'heureFermeture' => $isOpen ? '19:00:00' : null,
                'deGarde'        => $isOnCall,
                'created_at'     => now(),
                'updated_at'     => now(),
            ];
        }

        DB::table('horaire_pharmacies')->insert($schedules);
        echo "✅ Created 7 schedule entries for Pharmacie Al Majd\n";
    }
}