<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Stock;

class StockController extends Controller
{
    public function index(Request $request, $pharmacyId)
    {
        $stocks = DB::table('stock_pharmacies')
            ->join('medicaments', 'stock_pharmacies.idMedicament', '=', 'medicaments.idMedicament')
            ->where('stock_pharmacies.idPharmacie', $pharmacyId)
            ->select(
                'stock_pharmacies.idStock as id',
                'medicaments.nom as name',
                'stock_pharmacies.quantite as stock',
                'stock_pharmacies.prix as price',
                'stock_pharmacies.categorie as category',
                'stock_pharmacies.disponible as is_available',
                'medicaments.necessiteOrdonnance as requires_prescription'
            )
            ->get();

        return response()->json($stocks);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'stock' => 'required|integer|min:0',
            'price' => 'required|numeric|min:0',
            'is_available' => 'boolean'
        ]);

        DB::table('stock_pharmacies')
            ->where('idStock', $id)
            ->update([
                'quantite' => $request->stock,
                'prix' => $request->price,
                'disponible' => $request->is_available ? 1 : 0,
                'updated_at' => now()
            ]);

        return response()->json(['message' => 'Stock mis à jour']);
    }

    public function destroy($id)
    {
        DB::table('stock_pharmacies')->where('idStock', $id)->delete();
        return response()->json(['message' => 'Médicament retiré du stock']);
    }

    public function store(Request $request, $pharmacyId)
    {
        $request->validate([
            'name' => 'required_without:idMedicament|string',
            'category' => 'string|nullable',
            'requiresPrescription' => 'boolean',
            'idMedicament' => 'required_without:name|integer',
            'stock' => 'required|integer|min:0',
            'price' => 'required|numeric|min:0'
        ]);

        if ($request->has('name')) {
            $requiresPrescription = $request->boolean('requiresPrescription', $request->boolean('requires_prescription', false));
            $medicationId = DB::table('medicaments')->insertGetId([
                'nom' => $request->name,
                'necessiteOrdonnance' => $requiresPrescription ? 1 : 0,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        } else {
            $medicationId = $request->idMedicament;
        }

        $exists = DB::table('stock_pharmacies')
                    ->where('idPharmacie', $pharmacyId)
                    ->where('idMedicament', $medicationId)
                    ->exists();

        if ($exists) {
            return response()->json(['message' => 'Ce médicament est déjà dans votre stock'], 409);
        }

        $stockId = DB::table('stock_pharmacies')->insertGetId([
            'idPharmacie' => $pharmacyId,
            'idMedicament' => $medicationId,
            'quantite' => $request->stock,
            'prix' => $request->price,
            'categorie' => $request->category ?? null,
            'disponible' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'message' => 'Ajouté avec succès',
            'id' => $stockId,
            'idMedicament' => $medicationId
        ]);
    }
}
