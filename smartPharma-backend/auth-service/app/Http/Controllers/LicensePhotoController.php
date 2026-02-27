<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Response;
use App\Models\User;

class LicensePhotoController extends Controller
{
    /**
     * Serve license photo for admin viewing
     */
    public function show(Request $request, $userId)
    {
        try {
            // Optional: Check if user is authenticated (but don't require it for image embedding)
            // This allows images to load in <img> tags while still having some basic validation
            
            $user = User::where('idUtilisateur', $userId)->first();

            if (!$user || !$user->photo_licence) {
                return response()->json(['message' => 'Photo non trouvée'], 404);
            }

            // Only allow viewing license photos for pharmacists
            if ($user->role !== 'pharmacien') {
                return response()->json(['message' => 'Non autorisé'], 403);
            }

            // Check if file exists
            if (!Storage::disk('local')->exists($user->photo_licence)) {
                return response()->json(['message' => 'Fichier non trouvé'], 404);
            }

            // Get file contents
            $file = Storage::disk('local')->get($user->photo_licence);
            $mimeType = Storage::disk('local')->mimeType($user->photo_licence);

            // Return file with proper headers
            return Response::make($file, 200, [
                'Content-Type' => $mimeType,
                'Content-Disposition' => 'inline; filename="' . basename($user->photo_licence) . '"'
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Erreur lors du chargement'], 500);
        }
    }

    /**
     * Download license photo
     */
    public function download(Request $request, $userId)
    {
        try {
            $user = User::where('idUtilisateur', $userId)->first();

            if (!$user || !$user->photo_licence) {
                return response()->json(['message' => 'Photo non trouvée'], 404);
            }

            // Only allow downloading license photos for pharmacists
            if ($user->role !== 'pharmacien') {
                return response()->json(['message' => 'Non autorisé'], 403);
            }

            // Check if file exists
            if (!Storage::disk('local')->exists($user->photo_licence)) {
                return response()->json(['message' => 'Fichier non trouvé'], 404);
            }

            // Get file path
            $filePath = Storage::disk('local')->path($user->photo_licence);

            // Return downloadable file
            return response()->download($filePath, basename($user->photo_licence));
        } catch (\Exception $e) {
            return response()->json(['message' => 'Erreur lors du téléchargement'], 500);
        }
    }
}
