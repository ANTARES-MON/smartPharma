<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PharmacySeeder extends Seeder
{
    public function run(): void
    {
        // Create the same pharmacy that exists in auth-service
        // This should match the pharmacy created in auth-service DatabaseSeeder
        DB::table('pharmacies')->insert([
            'idPharmacie' => 1,
            'idPharmacien' => 1, // This matches the pharmacist in auth-service
            'nom' => 'Pharmacie Al Majd',
            'adresse' => '123 Rue Example',
            'latitude' => '33.5731',
            'longitude' => '-7.5898',
            'telephone' => '0522123456',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        echo "✅ Pharmacy 'Pharmacie Al Majd' created with ID 1\n";
    }
}
