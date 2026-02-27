<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use App\Models\User;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        echo "\n🌱 Seeding Auth Service Database...\n\n";

        // 1. Create Admin User First
        $this->call(AdminUserSeeder::class);

        // 2. CRITICAL FIX: CLEANUP EXTERNAL DB
        // Since 'migrate:fresh' only wipes the local Auth DB, we must manually
        // delete the pharmacy from the external DB to avoid "Duplicate Entry" errors.
        try {
            DB::connection('pharmacy')->table('pharmacies')->delete();
        } catch (\Exception $e) {
            // Ignore if table doesn't exist yet
        }

        // 3. Create Pharmacist
        echo "👨‍⚕️ Creating pharmacist...\n";
        $pharmacist = User::create([
            'nomComplet' => 'Dr. Amine',
            'email'      => 'pharma@gmail.com',
            'telephone'  => '0600000001',
            'motDePasse' => Hash::make('password'),
            'role'       => 'pharmacien',
            'statut'     => 'actif',
            'ville'      => 'Casablanca',
            'adresse'    => '12 Rue Al Massira',
        ]);

        // 4. Create Associated Pharmacy (External DB)
        echo "🏪 Creating pharmacy...\n";
        DB::connection('pharmacy')->table('pharmacies')->insert([
            'idPharmacie'  => 1, // Hardcoded ID 1
            'idPharmacien' => $pharmacist->idUtilisateur, // Link to the user we just created
            'nom'          => 'Pharmacie Al Majd',
            'adresse'      => '12 Rue Al Massira, Casablanca',
            'ville'        => 'Casablanca',
            'latitude'     => 33.5731,
            'longitude'    => -7.5898,
            'telephone'    => '0522000000',
            'created_at'   => now(),
            'updated_at'   => now(),
        ]);

        // 5. Link Pharmacist to Pharmacy
        // We update the local user record to point to the external pharmacy ID
        DB::table('utilisateurs')
            ->where('idUtilisateur', $pharmacist->idUtilisateur)
            ->update(['idPharmacie' => 1]);

        // 6. Create Client
        echo "👤 Creating client...\n";
        User::create([
            'nomComplet' => 'Ahmed Client',
            'email'      => 'client@gmail.com',
            'telephone'  => '0600000002',
            'motDePasse' => Hash::make('password'),
            'role'       => 'client',
            'statut'     => 'actif',
            'ville'      => 'Rabat',
            'adresse'    => 'Hay Riad', // Added generic address
        ]);

        echo "\n✅ Auth Service seeding complete!\n";
        echo "   - Admin: admin@smartpharma.com (admin123)\n";
        echo "   - Pharmacist: pharma@gmail.com (password)\n";
        echo "   - Client: client@gmail.com (password)\n\n";
    }
}