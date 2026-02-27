<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Log;

class AdminClientController extends Controller
{
    /**
     * Get all clients with optional filters
     */
    public function index(Request $request)
    {
        try {
            $query = User::where('role', 'client');

            // Filter by status
            if ($request->has('statut')) {
                $query->where('statut', $request->statut);
            }

            // Search by name or email
            if ($request->has('search')) {
                $search = $request->search;
                $query->where(function($q) use ($search) {
                    $q->where('nomComplet', 'like', "%{$search}%")
                      ->orWhere('email', 'like', "%{$search}%");
                });
            }

            $clients = $query->orderBy('created_at', 'desc')->get();

            return response()->json([
                'clients' => $clients
            ]);
        } catch (\Exception $e) {
            Log::error('Fetch clients error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors du chargement'], 500);
        }
    }

    /**
     * Get client details
     */
    public function show($id)
    {
        try {
            $client = User::where('idUtilisateur', $id)
                ->where('role', 'client')
                ->first();

            if (!$client) {
                return response()->json(['message' => 'Client non trouvé'], 404);
            }

            return response()->json([
                'client' => $client
            ]);
        } catch (\Exception $e) {
            Log::error('Fetch client error: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur lors du chargement'], 500);
        }
    }
}
