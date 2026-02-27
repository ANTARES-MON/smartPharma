<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $connection = 'auth_db'; 
    protected $table = 'utilisateurs';
    protected $primaryKey = 'idUtilisateur';

    protected $fillable = [
        'idPharmacie',
        'nomComplet',
        'email',
        'motDePasse',
        'role',
        'telephone',
        'statut',
        'fcm_token',
        'ville',
        'adresse'
    ];

    protected $hidden = [
        'motDePasse',
        'remember_token',
    ];

    public function getAuthPassword()
    {
        return $this->motDePasse;
    }
}