<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Laravel\Sanctum\Sanctum;        // 👈 Import
use App\Models\PersonalAccessToken; // 👈 Import

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        // 🟢 Force Sanctum to use the Auth DB
        Sanctum::usePersonalAccessTokenModel(PersonalAccessToken::class);
    }
}