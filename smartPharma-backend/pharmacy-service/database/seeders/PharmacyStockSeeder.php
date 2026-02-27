<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PharmacyStockSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Links medications to 'Pharmacie Al Majd'
     */
    public function run(): void
    {
        // Get the 'Pharmacie Al Majd' pharmacy
        $pharmacy = DB::table('pharmacies')->where('nom', 'Pharmacie Al Majd')->first();
        
        if (!$pharmacy) {
            $this->command->warn("⚠️ Warning: 'Pharmacie Al Majd' not found. Ensure PharmacySeeder ran first.");
            return;
        }

        $pharmacyId = $pharmacy->idPharmacie;

        // Get all medications
        $medications = DB::table('medicaments')->get();

        $stockEntries = [];
        foreach ($medications as $medication) {
            $stockEntries[] = [
                'idPharmacie' => $pharmacyId,
                'idMedicament' => $medication->idMedicament,
                'quantite' => rand(10, 100),
                'prix' => match($medication->nom) {
                    'Amoxicilline 500mg' => 45.00,
                    'Doliprane 1000mg' => 25.00,
                    'Aspirine 500mg' => 18.00,
                    'Augmentin 1g' => 85.00,
                    'Vitamines C 500mg' => 32.00,
                    default => 30.00,
                },
                'disponible' => true,
                // Match the column name 'categorie' from your migration
                'categorie' => match($medication->nom) {
                    'Amoxicilline 500mg', 'Augmentin 1g' => 'Antibiotiques',
                    'Doliprane 1000mg' => 'Antalgiques',
                    'Aspirine 500mg' => 'Anti-inflammatoires',
                    'Vitamines C 500mg' => 'Vitamines',
                    default => 'Divers',
                },
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        DB::table('stock_pharmacies')->insert($stockEntries);
        
        $this->command->info("✅ Successfully linked " . count($stockEntries) . " medications to 'Pharmacie Al Majd'");
    }
}