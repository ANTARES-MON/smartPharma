<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Compte en cours de vérification</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f7fa;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            padding: 40px 30px;
            text-align: center;
        }
        .header h1 {
            color: #ffffff;
            margin: 0;
            font-size: 28px;
            font-weight: 600;
        }
        .content {
            padding: 40px 30px;
        }
        .greeting {
            font-size: 18px;
            color: #1f2937;
            margin-bottom: 20px;
        }
        .message {
            font-size: 16px;
            color: #4b5563;
            line-height: 1.6;
            margin-bottom: 20px;
        }
        .info-box {
            background-color: #f0fdf4;
            border-left: 4px solid: #10b981;
            padding: 20px;
            margin: 25px 0;
            border-radius: 6px;
        }
        .info-box p {
            margin: 8px 0;
            color: #065f46;
            font-size: 15px;
        }
        .info-box strong {
            color: #047857;
        }
        .footer {
            background-color: #f9fafb;
            padding: 25px 30px;
            text-align: center;
            border-top: 1px solid #e5e7eb;
        }
        .footer p {
            color: #6b7280;
            font-size: 14px;
            margin: 5px 0;
        }
        .icon {
            font-size: 48px;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="icon">⏳</div>
            <h1>SmartPharma</h1>
        </div>
        
        <div class="content">
            <p class="greeting">Bonjour {{ $pharmacist->nomComplet }},</p>
            
            <p class="message">
                Merci d'avoir créé votre compte pharmacien sur <strong>SmartPharma</strong>.
            </p>
            
            <p class="message">
                Votre demande d'inscription est actuellement <strong>en cours de vérification</strong> par notre équipe administrative.
            </p>
            
            <div class="info-box">
                <p><strong>📧 Email:</strong> {{ $pharmacist->email }}</p>
                <p><strong>🏥 Pharmacie:</strong> {{ $pharmacy->nom ?? 'Non spécifiée' }}</p>
                <p><strong>📍 Ville:</strong> {{ $pharmacist->ville }}</p>
            </div>
            
            <p class="message">
                Nous examinons attentivement votre licence professionnelle et les informations fournies. 
                Ce processus prend généralement <strong>24 à 48 heures</strong>.
            </p>
            
            <p class="message">
                Vous recevrez un email de notification dès que votre compte sera approuvé ou si nous avons besoin d'informations complémentaires.
            </p>
            
            <p class="message" style="margin-top: 30px; color: #059669; font-weight: 500;">
                Merci pour votre patience ! 🙏
            </p>
        </div>
        
        <div class="footer">
            <p><strong>SmartPharma</strong></p>
            <p>Votre plateforme de gestion pharmaceutique</p>
            <p style="margin-top: 15px; font-size: 12px;">
                © 2026 SmartPharma. Tous droits réservés.
            </p>
        </div>
    </div>
</body>
</html>
