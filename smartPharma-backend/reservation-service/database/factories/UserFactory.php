<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            // 🟢 1. Use 'nomComplet' instead of 'name'
            'nomComplet' => fake()->name(),
            
            'email' => fake()->unique()->safeEmail(),

            // 🟢 2. Use 'motDePasse' instead of 'password'
            'motDePasse' => Hash::make('password'), 

            // 🟢 3. Add default values for required columns in your table
            'role' => 'client',
            'telephone' => '0600000000',
            'ville' => 'Casablanca',
            
            // 🔴 REMOVED 'email_verified_at' and 'remember_token' 
            // because they don't exist in your 'utilisateurs' table.
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            // 'email_verified_at' => null, // Commented out to prevent errors
        ]);
    }
}