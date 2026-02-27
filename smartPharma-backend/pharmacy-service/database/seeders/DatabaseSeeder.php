<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
{
    echo "\n🌱 Seeding Pharmacy Service Database...\n\n";
    
    // 1. First create the pharmacy
    $this->call(PharmacySeeder::class);
    
    // 2. Create the schedules (Needs to happen after PharmacySeeder)
    $this->call(PharmacyScheduleSeeder::class); // <--- FIXED: Added $this->call()
    
    // 3. Create medications
    $this->call(MedicationSeeder::class);
    
    // 4. Link medications to pharmacy stock
    $this->call(PharmacyStockSeeder::class);
    
    echo "\n✅ Pharmacy Service seeding complete!\n";

    // ... rest of your code
}
}
