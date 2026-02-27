<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class NewReservationEvent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $reservation;

    public function __construct($reservation)
    {
        $this->reservation = $reservation;
    }

    // This defines the "Room" where the pharmacist is waiting
    public function broadcastOn()
    {
        return new Channel('pharmacy.' . $this->reservation->idPharmacie);
    }

    public function broadcastAs()
    {
        return 'new-reservation';
    }

    public function broadcastWith()
    {
        // Include all reservation data in the broadcast
        return [
            'idReservation' => $this->reservation->idReservation,
            'idUtilisateur' => $this->reservation->idUtilisateur,
            'idStock' => $this->reservation->idStock,
            'idPharmacie' => $this->reservation->idPharmacie,
            'quantiteDemande' => $this->reservation->quantiteDemande,
            'statut' => $this->reservation->statut,
            'qr_code' => $this->reservation->qr_code,
            'dateReservation' => $this->reservation->dateReservation,
            'created_at' => $this->reservation->created_at,
        ];
    }
}