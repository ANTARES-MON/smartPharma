<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Reservation extends Model
{
    protected $table = 'reservations';
    protected $primaryKey = 'idReservation';

    protected $fillable = [
        'idUtilisateur',
        'idStock',
        'idPharmacie',
        'quantiteDemande',
        'statut', 
        'dateReservation',
        'qr_code'
    ];

    /**
     * Relationship to the User (Same Database)
     * Fixes: "Call to undefined relationship [utilisateur]"
     */
    public function utilisateur()
    {
        return $this->belongsTo(User::class, 'idUtilisateur', 'idUtilisateur');
    }

    /**
     * Relationship to Pharmacy
     * Note: Since you are in a microservice setup, we define this 
     * but we don't need a physical 'Pharmacy' model file if you 
     * fetch the data manually in the Controller. 
     * * To stop the "Relationship [pharmacie] not found" error, 
     * this method must exist if your Controller uses ->with('pharmacie').
     */
    public function pharmacie()
    {
        // We return an empty relation or a placeholder to prevent crashes
        // if the controller tries to eager load it.
        return $this->belongsTo(User::class, 'idPharmacie', 'idPharmacie')->withDefault([
            'nom' => 'Pharmacie Distante'
        ]);
    }
}