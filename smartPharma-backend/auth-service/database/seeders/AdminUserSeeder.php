<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create admin user if doesn't exist
        $adminExists = User::where('email', 'admin@smartpharma.com')->first();
        
        if (!$adminExists) {
            User::create([
                'nomComplet' => 'Admin SmartPharma',
                'email' => 'admin@smartpharma.com',
                'motDePasse' => Hash::make('admin123'),
                'role' => 'admin',
                'statut' => 'actif',
                'telephone' => '0600000000',
            ]);

            echo "✅ Admin user created successfully!\n";
            echo "📧 Email: admin@smartpharma.com\n";
            echo "🔑 Password: admin123\n";
        } else {
            echo "⚠️  Admin user already exists.\n";
        }
    }
}
