<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Fallback for storage images if Nginx fails to serve them
Route::get('/storage/{path}', function ($path) {
    if (Illuminate\Support\Facades\Storage::disk('public')->exists($path)) {
        return Illuminate\Support\Facades\Storage::disk('public')->response($path);
    }
    return response()->json(['message' => 'Image not found'], 404);
})->where('path', '.*');
