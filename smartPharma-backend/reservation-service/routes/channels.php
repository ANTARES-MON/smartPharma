<?php

use Illuminate\Support\Facades\Broadcast;

// 🟢 FIX: We use 'idUtilisateur' because that is your User model's key.
Broadcast::channel('user.{id}', function ($user, $id) {
    return (int) $user->idUtilisateur === (int) $id;
});

Broadcast::channel('pharmacy.{id}', function ($user, $id) {
    // Assuming pharmacy ID logic is similar, adjust if needed
    return (int) $user->idPharmacie === (int) $id; 
});