<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotificationController extends Controller
{
    // --- 1. GET ALL NOTIFICATIONS (Read & Unread) ---
    public function index(Request $request)
    {
        $user = $request->user();

        // fetch ALL notifications for this user from local notifications table
        // We do NOT filter by 'lu' here, so they stay in the list
        $notifications = DB::table('notifications')
            ->where('idUtilisateur', $user->idUtilisateur)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json(['data' => $notifications]);
    }

    // --- 2. MARK AS READ (Update Only - DO NOT DELETE) ---
    public function markAsRead(Request $request)
    {
        $user = $request->user();

        // Only update 'lu' to 1. The row remains in the DB.
        DB::table('notifications')
            ->where('idUtilisateur', $user->idUtilisateur)
            ->where('lu', 0)
            ->update(['lu' => 1]);

        return response()->json(['message' => 'Tout marqué comme lu']);
    }

    // --- 3. DELETE ALL (Actually remove them) ---
    public function deleteAll(Request $request)
    {
        $user = $request->user();

        // This is the ONLY time we remove data
        DB::table('notifications')
            ->where('idUtilisateur', $user->idUtilisateur)
            ->delete();

        return response()->json(['message' => 'Notifications supprimées']);
    }
}