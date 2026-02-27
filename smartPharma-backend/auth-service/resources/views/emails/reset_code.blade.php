<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
        .container { max-width: 500px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; text-align: center; }
        .code { font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #10B981; margin: 20px 0; }
        .footer { font-size: 12px; color: #888; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Mot de passe oublié ?</h2>
        <p>Utilisez le code ci-dessous pour réinitialiser votre mot de passe sur l'application SmartPharma.</p>
        
        <div class="code">{{ $code }}</div>
        
        <p>Ce code expire dans 15 minutes.</p>
        <p class="footer">Si vous n'avez pas demandé ce code, ignorez cet email.</p>
    </div>
</body>
</html>