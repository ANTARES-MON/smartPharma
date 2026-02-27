<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Stock extends Model
{
    // Maps to your SQL table 'STOCK_PHARMACIE'
    protected $table = 'stock_pharmacies';
    protected $primaryKey = 'idStock';

    protected $fillable = [
        'idPharmacie',
        'idMedicament',
        'quantite',
        'prix',
        'disponible',
        'categorie'
    ];

    // Helper to get the Medicament name automatically
    public function medicament()
    {
        return $this->hasOne(Medicament::class, 'idMedicament', 'idMedicament');
    }
}