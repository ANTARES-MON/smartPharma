// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SmartPharma';

  @override
  String get home => 'Accueil';

  @override
  String get favorites => 'Favoris';

  @override
  String get history => 'Historique';

  @override
  String get profile => 'Profil';

  @override
  String get search => 'Rechercher';

  @override
  String get searchPharmacies => 'Rechercher des pharmacies...';

  @override
  String get searchMedications => 'Rechercher des médicaments...';

  @override
  String get pharmacies => 'Pharmacies';

  @override
  String get onCallPharmacies => 'Pharmacies de Garde';

  @override
  String get nearbyPharmacies => 'Pharmacies à Proximité';

  @override
  String get allPharmacies => 'Toutes';

  @override
  String get reserve => 'Réserver';

  @override
  String get directions => 'Itinéraire';

  @override
  String get call => 'Appeler';

  @override
  String get details => 'Détails';

  @override
  String get openNow => 'OUVERTE MAINTENANT';

  @override
  String get closed => 'Fermé';

  @override
  String opensAt(String time) {
    return 'Ouvre à $time';
  }

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get openingHours => 'Horaire d\'ouverture';

  @override
  String get address => 'Adresse';

  @override
  String get phone => 'Téléphone';

  @override
  String get myReservations => 'Mes Réservations';

  @override
  String get pending => 'En attente';

  @override
  String get confirmed => 'Confirmée';

  @override
  String get ready => 'Prêt';

  @override
  String get completed => 'Terminées';

  @override
  String get cancelled => 'Annulées';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get settings => 'Paramètres';

  @override
  String get editProfile => 'Modifier le Profil';

  @override
  String get changePassword => 'Changer le Mot de Passe';

  @override
  String get language => 'Langue';

  @override
  String get security => 'Sécurité';

  @override
  String get helpCenter => 'Centre d\'aide';

  @override
  String get privacy => 'Politique de Confidentialité';

  @override
  String get logout => 'Déconnexion';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'العربية';

  @override
  String get selectLanguage => 'Sélectionner la Langue';

  @override
  String get languageChanged => 'Langue modifiée avec succès';

  @override
  String get name => 'Nom';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de Passe';

  @override
  String get confirmPassword => 'Confirmer le Mot de Passe';

  @override
  String get currentPassword => 'Mot de Passe Actuel';

  @override
  String get newPassword => 'Nouveau Mot de Passe';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get remove => 'Retirer';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get orContinueWith => 'Ou continuer avec';

  @override
  String get googleSignIn => 'Continuer avec Google';

  @override
  String get facebookSignIn => 'Continuer avec Facebook';

  @override
  String get pharmacyName => 'Nom de la pharmacie';

  @override
  String get pharmacyAddress => 'Adresse de la pharmacie';

  @override
  String get pharmacyPhone => 'Téléphone de la pharmacie';

  @override
  String get medicationName => 'Nom du médicament';

  @override
  String get medicationStock => 'Stock';

  @override
  String get medicationPrice => 'Prix';

  @override
  String get reservation => 'Réservation';

  @override
  String get reservationDate => 'Date de Réservation';

  @override
  String get reservationTime => 'Heure de Réservation';

  @override
  String get reservationStatus => 'Statut';

  @override
  String get scanQRCode => 'Scanner le Code QR';

  @override
  String get qrCodeScanned => 'Code QR scanné avec succès';

  @override
  String get errorOccurred => 'Une erreur s\'est produite';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get noInternetConnection => 'Pas de connexion Internet';

  @override
  String get loading => 'Chargement...';

  @override
  String get pleaseWait => 'Veuillez patienter...';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get ok => 'OK';

  @override
  String get preferences => 'Préférences';

  @override
  String get support => 'Support';

  @override
  String get account => 'Compte';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get client => 'Client';

  @override
  String get pharmacist => 'Pharmacien';

  @override
  String get fullName => 'Nom complet';

  @override
  String get rememberMe => 'Se souvenir';

  @override
  String get signIn => 'Se connecter';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get invalidEmail => 'Email invalide';

  @override
  String get emailRequired => 'Email requis';

  @override
  String get passwordRequired => 'Mot de passe requis';

  @override
  String get nameRequired => 'Nom requis';

  @override
  String get phoneRequired => 'Téléphone requis';

  @override
  String get pharmacyNameRequired => 'Nom de pharmacie requis';

  @override
  String get addressRequired => 'Adresse requise';

  @override
  String get licensePhoto => 'Photo de licence';

  @override
  String get uploadPhoto => 'Télécharger la photo';

  @override
  String get uploadLicense => 'Veuillez télécharger une photo de votre licence';

  @override
  String get yourNameAndSurname => 'Votre nom et prénom';

  @override
  String get confirmationRequired => 'Confirmation requise';

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get city => 'Ville';

  @override
  String get unknown => 'Inconnu';

  @override
  String get notProvided => 'Non renseigné';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get location => 'Localisation';

  @override
  String get all => 'Tous';

  @override
  String get orderAgain => 'Commander à nouveau';

  @override
  String get cancelRequest => 'Annuler la demande';

  @override
  String get noOrders => 'Aucune commande';

  @override
  String get confirmReservation => 'Confirmer la réservation';

  @override
  String get time => 'Heure';

  @override
  String get orderCancelled => 'Commande annulée';

  @override
  String get cancellationError => 'Erreur lors de l\'annulation';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get popularSearches => 'Recherches populaires';

  @override
  String get searchMedicine => 'Rechercher un médicament';

  @override
  String get sortedByDistance => 'Trié par distance';

  @override
  String get locationUnknown => 'Localisation inconnue';

  @override
  String get noFavorites => 'Aucun favori';

  @override
  String get savedPharmacies => 'Vos pharmacies enregistrées';

  @override
  String get clear => 'Effacer';

  @override
  String get reportProblem => 'Signaler un problème';

  @override
  String get sendEmail => 'Envoyer un email';

  @override
  String get callSupport => 'Appeler le support';

  @override
  String get accountSecurity => 'أمان الحساب';

  @override
  String get inDevelopment => 'En cours de développement';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get back => 'Retour';

  @override
  String get passwordUpdated => 'Mot de passe modifié avec succès';

  @override
  String get error => 'Erreur';

  @override
  String get reservedForClients => 'Réservé aux clients';

  @override
  String get incorrectCredentials => 'Email ou mot de passe incorrect';

  @override
  String get verificationStep => 'Vérification';

  @override
  String get newPasswordStep => 'Nouveau mot de passe';

  @override
  String get doneStep => 'Terminé';

  @override
  String get yourSmartPharmacy => 'Votre pharmacie intelligente';

  @override
  String get chooseLocation => 'Choisir l\'emplacement';

  @override
  String get yourPharmacy => 'Votre pharmacie';

  @override
  String get confirmPosition => 'Confirmer la position';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get validate => 'Valider';

  @override
  String get pharmacyInfo => 'Informations de la pharmacie';

  @override
  String get scanMedication => 'Scanner un médicament';

  @override
  String get placeBarcode => 'Placez le code-barres dans le cadre';

  @override
  String get medicationsAvailable => 'Médicaments Disponibles';

  @override
  String get outOfStock => 'Rupture de stock';

  @override
  String get reservations => 'Les Réservations';

  @override
  String get clientSpace => 'Espace Client';

  @override
  String get pharmacistSpace => 'Espace Pharmacien';

  @override
  String get or => 'OU';

  @override
  String get noAccountYet => 'Pas encore de compte? ';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte? ';

  @override
  String get joinSmartPharmaToday => 'Rejoignez SmartPharma aujourd\'hui';

  @override
  String get iAcceptThe => 'J\'accepte les ';

  @override
  String get termsAndConditions => 'conditions générales';

  @override
  String get phoneNumberPlaceholder => '+212...';

  @override
  String get enterEmailToReceive =>
      'Entrez votre email pour recevoir un code de réinitialisation';

  @override
  String get emailAddress => 'Adresse email';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get searchPharmacy => 'Rechercher une pharmacie';

  @override
  String get medications => 'Médicaments';

  @override
  String get map => 'Carte';

  @override
  String get list => 'Liste';

  @override
  String get km => 'km';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get myFavorites => 'Mes favoris';

  @override
  String get addPharmaciesToList =>
      'Ajoutez des pharmacies à votre liste\npour y accéder rapidement.';

  @override
  String get searchMedicationAvailability =>
      'Recherchez la disponibilité d\'un médicament...';

  @override
  String get update => 'Mise à jour';

  @override
  String get orderSent => 'Commande envoyée';

  @override
  String get yourOrder => 'Votre commande';

  @override
  String get newOrder => 'Nouvelle Commande';

  @override
  String get youHaveReceived => 'Vous avez reçu';

  @override
  String get accepted => 'Accepté';

  @override
  String get rejected => 'Refusé';

  @override
  String get canceled => 'Annulé';

  @override
  String get february => 'Février';

  @override
  String get january => 'Janvier';

  @override
  String get march => 'Mars';

  @override
  String get april => 'Avril';

  @override
  String get may => 'Mai';

  @override
  String get june => 'Juin';

  @override
  String get july => 'Juillet';

  @override
  String get august => 'Août';

  @override
  String get september => 'Septembre';

  @override
  String get october => 'Octobre';

  @override
  String get november => 'Novembre';

  @override
  String get december => 'Décembre';

  @override
  String get searchMedication => 'Rechercher un médicament...';

  @override
  String get lowStock => 'Stock bas';

  @override
  String get total => 'Total';

  @override
  String get newReservation => 'Nouvelle réservation';

  @override
  String get filterByCategory => 'Filtrer par catégorie';

  @override
  String get applyFilter => 'Appliquer filtre';

  @override
  String get prescription => 'Ordonnance';

  @override
  String get searchClientOrMedication => 'Chercher client ou médicament...';

  @override
  String get noPendingRequests => 'Aucune demande en attente';

  @override
  String get refuse => 'Refuser';

  @override
  String get myProfile => 'Mon Profil';

  @override
  String get onCallMode => 'Mode Garde';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get managePharmacyInfo => 'Gérez vos informations d\'officine';

  @override
  String get pharmacistName => 'Nom du pharmacien';

  @override
  String get category => 'Catégorie';

  @override
  String get price => 'Prix';

  @override
  String get stock => 'Stock';

  @override
  String get requiresPrescription => 'Nécessite une ordonnance';

  @override
  String get barcode => 'Code-barres';

  @override
  String get addMedication => 'Ajouter médicament';

  @override
  String get editMedication => 'Modifier médicament';

  @override
  String get deleteMedication => 'Supprimer médicament';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get nearby => 'À proximité';

  @override
  String get open => 'OUVERTE';

  @override
  String get forgotPasswordQuestion => 'Mot de passe oublié?';

  @override
  String get reservationsCount => 'Réservations';

  @override
  String get searchMedicationPlaceholder => 'Rechercher un médicament...';

  @override
  String get addPharmaciesTo =>
      'Ajoutez des pharmacies à votre liste\npour y accéder rapidement.';

  @override
  String get quantity => 'Quantité';

  @override
  String get notes => 'Notes';

  @override
  String get submit => 'Soumettre';

  @override
  String get helpCenterTitle => 'Centre d\'aide';

  @override
  String get contactUs => 'Contactez-nous';

  @override
  String get supportPhone => 'Téléphone support';

  @override
  String get supportEmail => 'Email support';

  @override
  String get faqAndSupport => 'FAQ et Support technique';

  @override
  String get privacyPolicy => 'Politique de données';

  @override
  String get editPharmacyInfo => 'Modifier les informations de la pharmacie';

  @override
  String get searchClientOrMed => 'Chercher client ou médicament...';

  @override
  String get noHistory => 'Aucun historique';

  @override
  String get viewPrescription => 'Voir l\'ordonnance';

  @override
  String get howCanWeHelpYou =>
      'Comment pouvons-nous vous aider aujourd\'hui ?';

  @override
  String get reportBugDescription => 'Un bug ? Une erreur ? Dites-le nous.';

  @override
  String get emailSupportDescription => 'Pour toute autre question ou demande.';

  @override
  String get callSupportDescription => 'Urgent ? Appelez-nous directement.';

  @override
  String get frequentQuestions => 'Questions Fréquentes';

  @override
  String get howToCancelOrder => 'Comment annuler une commande ?';

  @override
  String get howToCancelOrderAnswer =>
      'Allez dans votre historique, sélectionnez la commande et cliquez sur \'Annuler\'.';

  @override
  String get manageMyInfo => 'Gérer mes informations ?';

  @override
  String get manageMyInfoAnswer =>
      'Vous pouvez modifier vos données depuis l\'onglet Profil > Modifier le profil.';

  @override
  String get accountSecurityAnswer =>
      'Pour changer votre mot de passe, rendez-vous dans Profil > Sécurité.';

  @override
  String get closedCaps => 'FERMÉE';

  @override
  String get informations => 'Informations';

  @override
  String get boxes => 'boîte(s)';

  @override
  String get date => 'Date';

  @override
  String get summary => 'Récapitulatif';

  @override
  String get medication => 'Médicament';

  @override
  String get pharmacy => 'Pharmacie';

  @override
  String get totalToPay => 'Total à payer';

  @override
  String get goBack => 'Retour';

  @override
  String get reservationConfirmed => 'Réservation Confirmée !';

  @override
  String get orderTransmitted =>
      'Votre commande a été transmise à la pharmacie.';

  @override
  String get downloadReceipt => 'Télécharger le reçu (PDF)';

  @override
  String get finish => 'Terminer';

  @override
  String get reservationReceipt => 'Reçu de Réservation';

  @override
  String get pharmacyCaps => 'PHARMACIE';

  @override
  String get clientCaps => 'CLIENT';

  @override
  String get designation => 'Désignation';

  @override
  String get qty => 'Qté';

  @override
  String get unitPrice => 'Prix Unit.';

  @override
  String get estimatedTotal => 'Total Estimé:';

  @override
  String get ordersSent => 'commandes passées';

  @override
  String get newMedication => 'Nouveau médicament';

  @override
  String get modify => 'Modifier';

  @override
  String get medicationNamePlaceholder => 'Nom du médicament';

  @override
  String get pricePlaceholder => '...Prix (MAD)';

  @override
  String get prescriptionRequired => 'Ordonnance requise';

  @override
  String get searchPatientOrMed => 'Chercher (Patient ou Médicament)...';

  @override
  String get license => 'Licence :';

  @override
  String get pharmacySettings => 'PARAMÈTRES DE L\'OFFICINE';

  @override
  String get pharmacyInformation => 'Informations Pharmacie';

  @override
  String get reservationFound => 'Réservation Trouvée';

  @override
  String get patient => 'Patient';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get pharmaciesFound => 'pharmacies trouvées';

  @override
  String get inStock => 'EN STOCK';

  @override
  String get hoursNotAvailable => 'Horaires non disponibles';

  @override
  String get noResultsFor => 'Aucun résultat pour';

  @override
  String get noPharmacyFound => 'Aucune pharmacie trouvée';

  @override
  String get onCall => 'De garde';

  @override
  String get openPharmacies => 'Ouvertes';

  @override
  String get findNearbyPharmacies => 'Trouvez les pharmacies à proximité';

  @override
  String get yourOrderFor => 'Votre commande pour';

  @override
  String get isPending => 'est en attente';

  @override
  String get updateTitle => 'Mise à jour';

  @override
  String get isRejected => 'est Refusée';

  @override
  String get isAccepted => 'est Acceptée';

  @override
  String get readyPickedUp => 'PRÊT / RÉCUPÉRÉ';

  @override
  String get pendingCaps => 'EN ATTENTE';

  @override
  String get cancelledCaps => 'ANNULÉ';

  @override
  String get qtyLabel => 'Qté:';

  @override
  String get searching => 'Rechercher...';

  @override
  String get searchMedicationCaps => 'RECHERCHER UN MÉDICAMENT';

  @override
  String get searchPatientOrMedication => 'Chercher (Patient ou Médicament)...';

  @override
  String get agoTime => 'Il y a';

  @override
  String get refused => 'Refusée';

  @override
  String get addressLabel => 'Adresse';

  @override
  String get hoursLabel => 'Horaires';

  @override
  String get locationLabel => 'Localisation';

  @override
  String get needHelpPharmacy => 'Besoin d\'aide avec votre espace officine ?';

  @override
  String get youReceivedOrder => 'Vous avez reçu une commande :';

  @override
  String get minUnit => 'min';

  @override
  String get hourUnit => 'h';

  @override
  String get justNow => 'À l\'instant';

  @override
  String get noMedicationFound => 'Aucun médicament trouvé';

  @override
  String get ordered => 'a commandé';

  @override
  String get boxUnit => 'boîte(s)';

  @override
  String get reservationNotFound => 'Réservation Non Trouvée';

  @override
  String get reservationNotAccepted =>
      'Cette réservation n\'est pas encore acceptée ou n\'existe pas.';

  @override
  String get scanBarcode => 'Scanner Code-barres';

  @override
  String get barcodeNotFound => 'Aucun médicament trouvé avec ce code-barres';

  @override
  String get barcodeOptional => 'Facultatif';
}
