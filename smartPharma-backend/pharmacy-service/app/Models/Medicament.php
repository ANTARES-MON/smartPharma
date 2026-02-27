<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Medicament extends Model
{
    protected $table = 'medicaments';
    protected $primaryKey = 'idMedicament';

    protected $fillable = [
        'nom',
        'description',
        'categorie',
        'necessiteOrdonnance'
    ];

    public $timestamps = true;
}