<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class RegisterRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'nomComplet' => ['required', 'min:3', 'max:100', 'regex:/^[a-zA-Z\s\-]+$/'],
            'email' => 'required|email|unique:utilisateurs,email',
            'telephone' => 'required|string|max:20',
            'motDePasse' => ['required', 'confirmed', Password::min(8)->letters()->mixedCase()->numbers()->symbols()],
            'role' => 'required|in:client,pharmacien',
            'pharmacyName' => 'required_if:role,pharmacien|string|max:255',
            'pharmacyAddress' => 'required_if:role,pharmacien|string|max:255',
            'photo_licence' => 'required_if:role,pharmacien|file|image|max:5120',
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'nomComplet.required' => 'Le nom complet est requis',
            'nomComplet.min' => 'Le nom doit contenir au moins 3 caractères',
            'nomComplet.regex' => 'Le nom ne peut contenir que des lettres, espaces et tirets',
            'email.required' => 'L\'adresse email est requise',
            'email.email' => 'L\'adresse email doit être valide',
            'email.unique' => 'Cette adresse email est déjà utilisée',
            'telephone.required' => 'Le numéro de téléphone est requis',
            'motDePasse.required' => 'Le mot de passe est requis',
            'motDePasse.confirmed' => 'Les mots de passe ne correspondent pas',
        ];
    }

    /**
     * Get custom attribute names for validator errors.
     */
    public function attributes(): array
    {
        return [
            'motDePasse' => 'mot de passe',
            'nomComplet' => 'nom complet',
            'telephone' => 'téléphone',
        ];
    }

    /**
     * Handle a failed validation attempt.
     */
    protected function failedValidation(Validator $validator)
    {
        $errors = $validator->errors();
        
        // Add detailed password requirement messages if password validation failed
        if ($errors->has('motDePasse')) {
            $passwordErrors = [];
            $password = $this->input('motDePasse', '');
            
            if (strlen($password) < 8) {
                $passwordErrors[] = 'Minimum 8 caractères';
            }
            if (!preg_match('/[a-z]/', $password)) {
                $passwordErrors[] = 'Au moins une lettre minuscule';
            }
            if (!preg_match('/[A-Z]/', $password)) {
                $passwordErrors[] = 'Au moins une lettre majuscule';
            }
            if (!preg_match('/[0-9]/', $password)) {
                $passwordErrors[] = 'Au moins un chiffre';
            }
            if (!preg_match('/[@$!%*?&#]/', $password)) {
                $passwordErrors[] = 'Au moins un symbole (@$!%*?&#)';
            }
            
            if (!empty($passwordErrors)) {
                $errors->add('motDePasse', 'Le mot de passe doit contenir: ' . implode(', ', $passwordErrors));
            }
        }

        throw new HttpResponseException(
            response()->json([
                'message' => 'Erreur de validation',
                'errors' => $errors->toArray()
            ], 422)
        );
    }
}
