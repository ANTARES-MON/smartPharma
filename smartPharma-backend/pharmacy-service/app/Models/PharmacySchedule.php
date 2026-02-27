<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PharmacySchedule extends Model
{
    // Maps to your SQL table 'HORAIRE_PHARMACIE'
    protected $table = 'horaire_pharmacies';
    protected $primaryKey = 'idHoraire';

    protected $fillable = [
        'idPharmacie',
        'jourSemaine',
        'heureOuverture',
        'heureFermeture',
        'deGarde'
    ];

    // Disable timestamps if your SQL table doesn't have created_at/updated_at
    // But your script says it does, so we keep them true.
    public $timestamps = true;
}