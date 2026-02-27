<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            background: linear-gradient(135deg, #10B981, #059669);
            color: white;
            padding: 30px;
            text-align: center;
            border-radius: 10px 10px 0 0;
        }
        .content {
            background: #f9fafb;
            padding: 30px;
            border-radius: 0 0 10px 10px;
        }
        .button {
            display: inline-block;
            padding: 12px 30px;
            background: #10B981;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            margin-top: 20px;
        }
        .footer {
            text-align: center;
            margin-top: 20px;
            color: #666;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>✅ Compte Approuvé!</h1>
    </div>
    <div class="content">
        <p>Bonjour {{ $user->nomComplet }},</p>
        
        <p>Bonne nouvelle! Votre compte pharmacien sur <strong>SmartPharma</strong> a été approuvé par notre équipe.</p>
        
        <p>Vous pouvez maintenant vous connecter à l'application et commencer à gérer votre pharmacie.</p>
        
        <p><strong>Votre email:</strong> {{ $user->email }}</p>
        
        <p style="margin-top: 30px;">
            Merci de faire confiance à SmartPharma!
        </p>
        
        <p>
            Cordialement,<br>
            <strong>L'équipe SmartPharma</strong>
        </p>
    </div>
    <div class="footer">
        <p>© 2026 SmartPharma. Tous droits réservés.</p>
    </div>
</body>
</html>
