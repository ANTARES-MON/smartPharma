<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SearchController extends Controller
{
    public function search(Request $request)
    {
        $query = $request->get('q');

        if (!$query) {
            return response()->json([]);
        }

        $results = DB::table('stock_pharmacies')
            ->join('medicaments', 'stock_pharmacies.idMedicament', '=', 'medicaments.idMedicament')
            ->join('pharmacies', 'stock_pharmacies.idPharmacie', '=', 'pharmacies.idPharmacie')
            ->where('medicaments.nom', 'LIKE', "%{$query}%")
            ->where('stock_pharmacies.quantite', '>', 0)
            ->select(
                'pharmacies.idPharmacie as id',
                'pharmacies.nom as name',
                'pharmacies.adresse as address',
                'pharmacies.latitude as lat',
                'pharmacies.longitude as lng',
                'pharmacies.telephone as phone',
                'stock_pharmacies.prix as price',
                'medicaments.nom as matched_medication'
            )
            ->get();
            
        $formatted = $results->map(function($item) {
             return [
                 'id' => (string) $item->id,
                 'name' => $item->name,
                 'address' => $item->address,
                 'lat' => (double) $item->lat,
                 'lng' => (double) $item->lng,
                 'phone' => $item->phone,
                 'distance_fallback' => 'Calculated in App',
                 'medications' => [$item->matched_medication],
                 'schedule' => [],
                 'search_price' => $item->price
             ];
        });

        return response()->json(['data' => $formatted]);
    }
}