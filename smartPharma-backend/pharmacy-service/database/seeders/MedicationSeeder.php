<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MedicationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $medications = [
            [
                'nom' => 'Amoxicilline 500mg',
                'barcode' => '3400936041059',
                'necessiteOrdonnance' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nom' => 'Doliprane 1000mg',
                'barcode' => '3400935541185',
                'necessiteOrdonnance' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nom' => 'Aspirine 500mg',
                'barcode' => '3400936074934',
                'necessiteOrdonnance' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nom' => 'Augmentin 1g',
                'barcode' => '3400937657549',
                'necessiteOrdonnance' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nom' => 'Vitamines C 500mg',
                'barcode' => '3401344839238',
                'necessiteOrdonnance' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('medicaments')->insert($medications);
    }
}