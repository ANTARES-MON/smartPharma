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
            background: linear-gradient(135deg, #EF4444, #DC2626);
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
        .footer {
            text-align: center;
            margin-top: 20px;
            color: #666;
            font-size: 12px;
        }
        .reason-box {
            background: #FEE2E2;
            border-left: 4px solid #EF4444;
            padding: 15px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>❌ Compte Suspendu</h1>
    </div>
    <div class="content">
        <p>Bonjour {{ $user->nomComplet }},</p>
        
        <p>Nous vous informons que votre compte pharmacien sur <strong>SmartPharma</strong> a été suspendu.</p>
        
        @if ($reason)
        <div class="reason-box">
            <strong>Raison:</strong><br>
            {{ $reason }}
        </div>
        @endif
        
        <p>Si vous pensez qu'il s'agit d'une erreur ou si vous souhaitez plus d'informations, veuillez nous contacter à <a href="mailto:support@smartpharma.com">support@smartpharma.com</a>.</p>
        
        <p style="margin-top: 30px;">
            Cordialement,<br>
            <strong>L'équipe SmartPharma</strong>
        </p>
    </div>
    <div class="footer">
        <p>© 2026 SmartPharma. Tous droits réservés.</p>
    </div>
</body>
</html>
