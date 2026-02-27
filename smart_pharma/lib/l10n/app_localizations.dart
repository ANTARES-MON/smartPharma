import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'SmartPharma'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Search pharmacies...'**
  String get searchPharmacies;

  /// No description provided for @searchMedications.
  ///
  /// In en, this message translates to:
  /// **'Search medications...'**
  String get searchMedications;

  /// No description provided for @pharmacies.
  ///
  /// In en, this message translates to:
  /// **'Pharmacies'**
  String get pharmacies;

  /// No description provided for @onCallPharmacies.
  ///
  /// In en, this message translates to:
  /// **'On-Call Pharmacies'**
  String get onCallPharmacies;

  /// No description provided for @nearbyPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Nearby Pharmacies'**
  String get nearbyPharmacies;

  /// No description provided for @allPharmacies.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allPharmacies;

  /// No description provided for @reserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserve;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'OPEN NOW'**
  String get openNow;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @opensAt.
  ///
  /// In en, this message translates to:
  /// **'Opens at {time}'**
  String opensAt(String time);

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get openingHours;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @myReservations.
  ///
  /// In en, this message translates to:
  /// **'My Reservations'**
  String get myReservations;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googleSignIn;

  /// No description provided for @facebookSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get facebookSignIn;

  /// No description provided for @pharmacyName.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy name'**
  String get pharmacyName;

  /// No description provided for @pharmacyAddress.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy address'**
  String get pharmacyAddress;

  /// No description provided for @pharmacyPhone.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy phone'**
  String get pharmacyPhone;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get medicationName;

  /// No description provided for @medicationStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get medicationStock;

  /// No description provided for @medicationPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get medicationPrice;

  /// No description provided for @reservation.
  ///
  /// In en, this message translates to:
  /// **'Reservation'**
  String get reservation;

  /// No description provided for @reservationDate.
  ///
  /// In en, this message translates to:
  /// **'Reservation Date'**
  String get reservationDate;

  /// No description provided for @reservationTime.
  ///
  /// In en, this message translates to:
  /// **'Reservation Time'**
  String get reservationTime;

  /// No description provided for @reservationStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get reservationStatus;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// No description provided for @qrCodeScanned.
  ///
  /// In en, this message translates to:
  /// **'QR Code scanned successfully'**
  String get qrCodeScanned;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @pharmacist.
  ///
  /// In en, this message translates to:
  /// **'Pharmacist'**
  String get pharmacist;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get passwordRequired;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name required'**
  String get nameRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone required'**
  String get phoneRequired;

  /// No description provided for @pharmacyNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy name required'**
  String get pharmacyNameRequired;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address required'**
  String get addressRequired;

  /// No description provided for @licensePhoto.
  ///
  /// In en, this message translates to:
  /// **'License Photo'**
  String get licensePhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @uploadLicense.
  ///
  /// In en, this message translates to:
  /// **'Please upload a license photo'**
  String get uploadLicense;

  /// No description provided for @yourNameAndSurname.
  ///
  /// In en, this message translates to:
  /// **'Your name and surname'**
  String get yourNameAndSurname;

  /// No description provided for @confirmationRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirmation required'**
  String get confirmationRequired;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @orderAgain.
  ///
  /// In en, this message translates to:
  /// **'Order Again'**
  String get orderAgain;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No Orders'**
  String get noOrders;

  /// No description provided for @confirmReservation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reservation'**
  String get confirmReservation;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled;

  /// No description provided for @cancellationError.
  ///
  /// In en, this message translates to:
  /// **'Error during cancellation'**
  String get cancellationError;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @popularSearches.
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get popularSearches;

  /// No description provided for @searchMedicine.
  ///
  /// In en, this message translates to:
  /// **'Search Medicine'**
  String get searchMedicine;

  /// No description provided for @sortedByDistance.
  ///
  /// In en, this message translates to:
  /// **'Sorted by distance'**
  String get sortedByDistance;

  /// No description provided for @locationUnknown.
  ///
  /// In en, this message translates to:
  /// **'Location unknown'**
  String get locationUnknown;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No Favorites'**
  String get noFavorites;

  /// No description provided for @savedPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Your saved pharmacies'**
  String get savedPharmacies;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get reportProblem;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @callSupport.
  ///
  /// In en, this message translates to:
  /// **'Call Support'**
  String get callSupport;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account security'**
  String get accountSecurity;

  /// No description provided for @inDevelopment.
  ///
  /// In en, this message translates to:
  /// **'In Development'**
  String get inDevelopment;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdated;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @reservedForClients.
  ///
  /// In en, this message translates to:
  /// **'Reserved for clients'**
  String get reservedForClients;

  /// No description provided for @incorrectCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get incorrectCredentials;

  /// No description provided for @verificationStep.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationStep;

  /// No description provided for @newPasswordStep.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordStep;

  /// No description provided for @doneStep.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneStep;

  /// No description provided for @yourSmartPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Your smart pharmacy'**
  String get yourSmartPharmacy;

  /// No description provided for @chooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose location'**
  String get chooseLocation;

  /// No description provided for @yourPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Your pharmacy'**
  String get yourPharmacy;

  /// No description provided for @confirmPosition.
  ///
  /// In en, this message translates to:
  /// **'Confirm position'**
  String get confirmPosition;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @pharmacyInfo.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Information'**
  String get pharmacyInfo;

  /// No description provided for @scanMedication.
  ///
  /// In en, this message translates to:
  /// **'Scan medication'**
  String get scanMedication;

  /// No description provided for @placeBarcode.
  ///
  /// In en, this message translates to:
  /// **'Place barcode in frame'**
  String get placeBarcode;

  /// No description provided for @medicationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Medications Available'**
  String get medicationsAvailable;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @reservations.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get reservations;

  /// No description provided for @clientSpace.
  ///
  /// In en, this message translates to:
  /// **'Client Space'**
  String get clientSpace;

  /// No description provided for @pharmacistSpace.
  ///
  /// In en, this message translates to:
  /// **'Pharmacist Space'**
  String get pharmacistSpace;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet? '**
  String get noAccountYet;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @joinSmartPharmaToday.
  ///
  /// In en, this message translates to:
  /// **'Join SmartPharma today'**
  String get joinSmartPharmaToday;

  /// No description provided for @iAcceptThe.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get iAcceptThe;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'terms and conditions'**
  String get termsAndConditions;

  /// No description provided for @phoneNumberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'+212...'**
  String get phoneNumberPlaceholder;

  /// No description provided for @enterEmailToReceive.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset code'**
  String get enterEmailToReceive;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @searchPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Search pharmacy'**
  String get searchPharmacy;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// No description provided for @addPharmaciesToList.
  ///
  /// In en, this message translates to:
  /// **'Add pharmacies to your list\nfor quick access.'**
  String get addPharmaciesToList;

  /// No description provided for @searchMedicationAvailability.
  ///
  /// In en, this message translates to:
  /// **'Search for medication availability...'**
  String get searchMedicationAvailability;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @orderSent.
  ///
  /// In en, this message translates to:
  /// **'Order sent'**
  String get orderSent;

  /// No description provided for @yourOrder.
  ///
  /// In en, this message translates to:
  /// **'Your order'**
  String get yourOrder;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get newOrder;

  /// No description provided for @youHaveReceived.
  ///
  /// In en, this message translates to:
  /// **'You have received'**
  String get youHaveReceived;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @searchMedication.
  ///
  /// In en, this message translates to:
  /// **'Search a medication...'**
  String get searchMedication;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @newReservation.
  ///
  /// In en, this message translates to:
  /// **'New Reservation'**
  String get newReservation;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by category'**
  String get filterByCategory;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// No description provided for @prescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get prescription;

  /// No description provided for @searchClientOrMedication.
  ///
  /// In en, this message translates to:
  /// **'Search client or medication...'**
  String get searchClientOrMedication;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @refuse.
  ///
  /// In en, this message translates to:
  /// **'Refuse'**
  String get refuse;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @onCallMode.
  ///
  /// In en, this message translates to:
  /// **'On-Call Mode'**
  String get onCallMode;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @managePharmacyInfo.
  ///
  /// In en, this message translates to:
  /// **'Manage your pharmacy information'**
  String get managePharmacyInfo;

  /// No description provided for @pharmacistName.
  ///
  /// In en, this message translates to:
  /// **'Pharmacist Name'**
  String get pharmacistName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @requiresPrescription.
  ///
  /// In en, this message translates to:
  /// **'Requires Prescription'**
  String get requiresPrescription;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @editMedication.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get editMedication;

  /// No description provided for @deleteMedication.
  ///
  /// In en, this message translates to:
  /// **'Delete Medication'**
  String get deleteMedication;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get open;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @reservationsCount.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get reservationsCount;

  /// No description provided for @searchMedicationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search medication...'**
  String get searchMedicationPlaceholder;

  /// No description provided for @addPharmaciesTo.
  ///
  /// In en, this message translates to:
  /// **'Add pharmacies to your list\nfor quick access.'**
  String get addPharmaciesTo;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @helpCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenterTitle;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @supportPhone.
  ///
  /// In en, this message translates to:
  /// **'Support phone'**
  String get supportPhone;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'Support email'**
  String get supportEmail;

  /// No description provided for @faqAndSupport.
  ///
  /// In en, this message translates to:
  /// **'FAQ & Support'**
  String get faqAndSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @editPharmacyInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit pharmacy information'**
  String get editPharmacyInfo;

  /// No description provided for @searchClientOrMed.
  ///
  /// In en, this message translates to:
  /// **'Search client or medication...'**
  String get searchClientOrMed;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history'**
  String get noHistory;

  /// No description provided for @viewPrescription.
  ///
  /// In en, this message translates to:
  /// **'View prescription'**
  String get viewPrescription;

  /// No description provided for @howCanWeHelpYou.
  ///
  /// In en, this message translates to:
  /// **'How can we help you today?'**
  String get howCanWeHelpYou;

  /// No description provided for @reportBugDescription.
  ///
  /// In en, this message translates to:
  /// **'A bug? An error? Let us know.'**
  String get reportBugDescription;

  /// No description provided for @emailSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'For any other question or request.'**
  String get emailSupportDescription;

  /// No description provided for @callSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Urgent? Call us directly.'**
  String get callSupportDescription;

  /// No description provided for @frequentQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentQuestions;

  /// No description provided for @howToCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'How to cancel an order?'**
  String get howToCancelOrder;

  /// No description provided for @howToCancelOrderAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to your history, select the order and click \'Cancel\'.'**
  String get howToCancelOrderAnswer;

  /// No description provided for @manageMyInfo.
  ///
  /// In en, this message translates to:
  /// **'Manage my information?'**
  String get manageMyInfo;

  /// No description provided for @manageMyInfoAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can modify your data from the Profile > Edit profile tab.'**
  String get manageMyInfoAnswer;

  /// No description provided for @accountSecurityAnswer.
  ///
  /// In en, this message translates to:
  /// **'To change your password, go to Profile > Security.'**
  String get accountSecurityAnswer;

  /// No description provided for @closedCaps.
  ///
  /// In en, this message translates to:
  /// **'CLOSED'**
  String get closedCaps;

  /// No description provided for @informations.
  ///
  /// In en, this message translates to:
  /// **'Informations'**
  String get informations;

  /// No description provided for @boxes.
  ///
  /// In en, this message translates to:
  /// **'box(es)'**
  String get boxes;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @pharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get pharmacy;

  /// No description provided for @totalToPay.
  ///
  /// In en, this message translates to:
  /// **'Total to pay'**
  String get totalToPay;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get goBack;

  /// No description provided for @reservationConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Reservation Confirmed!'**
  String get reservationConfirmed;

  /// No description provided for @orderTransmitted.
  ///
  /// In en, this message translates to:
  /// **'Your order has been transmitted to the pharmacy.'**
  String get orderTransmitted;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download receipt (PDF)'**
  String get downloadReceipt;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @reservationReceipt.
  ///
  /// In en, this message translates to:
  /// **'Reservation Receipt'**
  String get reservationReceipt;

  /// No description provided for @pharmacyCaps.
  ///
  /// In en, this message translates to:
  /// **'PHARMACY'**
  String get pharmacyCaps;

  /// No description provided for @clientCaps.
  ///
  /// In en, this message translates to:
  /// **'CLIENT'**
  String get clientCaps;

  /// No description provided for @designation.
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get designation;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @estimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated Total:'**
  String get estimatedTotal;

  /// No description provided for @ordersSent.
  ///
  /// In en, this message translates to:
  /// **'orders sent'**
  String get ordersSent;

  /// No description provided for @newMedication.
  ///
  /// In en, this message translates to:
  /// **'New Medication'**
  String get newMedication;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modify;

  /// No description provided for @medicationNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Medication name'**
  String get medicationNamePlaceholder;

  /// No description provided for @pricePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'...Price (MAD)'**
  String get pricePlaceholder;

  /// No description provided for @prescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Prescription required'**
  String get prescriptionRequired;

  /// No description provided for @searchPatientOrMed.
  ///
  /// In en, this message translates to:
  /// **'Search (Patient or Medication)...'**
  String get searchPatientOrMed;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License :'**
  String get license;

  /// No description provided for @pharmacySettings.
  ///
  /// In en, this message translates to:
  /// **'PHARMACY SETTINGS'**
  String get pharmacySettings;

  /// No description provided for @pharmacyInformation.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Information'**
  String get pharmacyInformation;

  /// No description provided for @reservationFound.
  ///
  /// In en, this message translates to:
  /// **'Reservation Found'**
  String get reservationFound;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @pharmaciesFound.
  ///
  /// In en, this message translates to:
  /// **'pharmacies found'**
  String get pharmaciesFound;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'IN STOCK'**
  String get inStock;

  /// No description provided for @hoursNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Hours not available'**
  String get hoursNotAvailable;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for'**
  String get noResultsFor;

  /// No description provided for @noPharmacyFound.
  ///
  /// In en, this message translates to:
  /// **'No pharmacy found'**
  String get noPharmacyFound;

  /// No description provided for @onCall.
  ///
  /// In en, this message translates to:
  /// **'On Call'**
  String get onCall;

  /// No description provided for @openPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openPharmacies;

  /// No description provided for @findNearbyPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Find nearby pharmacies'**
  String get findNearbyPharmacies;

  /// No description provided for @yourOrderFor.
  ///
  /// In en, this message translates to:
  /// **'Your order for'**
  String get yourOrderFor;

  /// No description provided for @isPending.
  ///
  /// In en, this message translates to:
  /// **'is pending'**
  String get isPending;

  /// No description provided for @updateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateTitle;

  /// No description provided for @isRejected.
  ///
  /// In en, this message translates to:
  /// **'is Rejected'**
  String get isRejected;

  /// No description provided for @isAccepted.
  ///
  /// In en, this message translates to:
  /// **'is Accepted'**
  String get isAccepted;

  /// No description provided for @readyPickedUp.
  ///
  /// In en, this message translates to:
  /// **'READY / PICKED UP'**
  String get readyPickedUp;

  /// No description provided for @pendingCaps.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pendingCaps;

  /// No description provided for @cancelledCaps.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get cancelledCaps;

  /// No description provided for @qtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty:'**
  String get qtyLabel;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @searchMedicationCaps.
  ///
  /// In en, this message translates to:
  /// **'SEARCH A MEDICATION'**
  String get searchMedicationCaps;

  /// No description provided for @searchPatientOrMedication.
  ///
  /// In en, this message translates to:
  /// **'Search (Patient or Medication)...'**
  String get searchPatientOrMedication;

  /// No description provided for @agoTime.
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get agoTime;

  /// No description provided for @refused.
  ///
  /// In en, this message translates to:
  /// **'Refused'**
  String get refused;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @hoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hoursLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @needHelpPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Need help with your pharmacy space?'**
  String get needHelpPharmacy;

  /// No description provided for @youReceivedOrder.
  ///
  /// In en, this message translates to:
  /// **'You have received an order:'**
  String get youReceivedOrder;

  /// No description provided for @minUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minUnit;

  /// No description provided for @hourUnit.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hourUnit;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @noMedicationFound.
  ///
  /// In en, this message translates to:
  /// **'No medication found'**
  String get noMedicationFound;

  /// No description provided for @ordered.
  ///
  /// In en, this message translates to:
  /// **'ordered'**
  String get ordered;

  /// No description provided for @boxUnit.
  ///
  /// In en, this message translates to:
  /// **'box(es)'**
  String get boxUnit;

  /// No description provided for @reservationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Reservation Not Found'**
  String get reservationNotFound;

  /// No description provided for @reservationNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'This reservation is not yet accepted or does not exist.'**
  String get reservationNotAccepted;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @barcodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'No medication found with this barcode'**
  String get barcodeNotFound;

  /// No description provided for @barcodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get barcodeOptional;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
