<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens; // Important for API Tokens

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The table associated with the model.
     */
    protected $table = 'utilisateurs';
    protected $primaryKey = 'idUtilisateur';

    protected $fillable = [
        'nomComplet',
        'email',
        'motDePasse',
        'telephone',
        'role',
        'ville',
        'adresse',
        'statut',
        'photo_licence',
        'google_id',
        'facebook_id',
    ];

    protected $hidden = [
        'motDePasse', // Hide password in JSON responses
    ];

    // We tell Laravel which column holds the password
    public function getAuthPassword()
    {
        return $this->motDePasse;
    }
}