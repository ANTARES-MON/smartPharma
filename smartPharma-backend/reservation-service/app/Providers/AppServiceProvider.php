<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Laravel\Sanctum\Sanctum;            // 👈 IMPORT THIS
use App\Models\PersonalAccessToken;     // 👈 IMPORT THIS

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // 🟢 This forces the Reservation Service to look for tokens in the Auth DB
        Sanctum::usePersonalAccessTokenModel(PersonalAccessToken::class);
    }
}