<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pharmacy extends Model
{
    protected $table = 'pharmacies';
    protected $primaryKey = 'idPharmacie';

    // We fetch these relationships automatically
    protected $with = ['horaires', 'stocks'];

    public function horaires()
    {
        return $this->hasMany(PharmacySchedule::class, 'idPharmacie', 'idPharmacie');
    }

    // Link to Stock to get Medications
    public function stocks()
    {
        return $this->hasMany(Stock::class, 'idPharmacie', 'idPharmacie')
                    ->join('medicaments', 'stock_pharmacies.idMedicament', '=', 'medicaments.idMedicament')
                    ->select('stock_pharmacies.*', 'medicaments.nom as medicament_nom');
    }
}