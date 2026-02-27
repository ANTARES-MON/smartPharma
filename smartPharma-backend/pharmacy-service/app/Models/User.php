<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens; // 🟢 Import this

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    // 🟢 1. Connect to Auth DB
    protected $connection = 'auth_db'; 

    // 🟢 2. Use Custom Table
    protected $table = 'utilisateurs';
    protected $primaryKey = 'idUtilisateur';

    protected $fillable = [
        'nomComplet', 'email', 'motDePasse', 'role', 'telephone', 'statut', 'fcm_token', 'ville', 'adresse'
    ];

    protected $hidden = [
        'motDePasse', 'remember_token',
    ];

    public function getAuthPassword()
    {
        return $this->motDePasse;
    }
}