// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SmartPharma';

  @override
  String get home => 'Home';

  @override
  String get favorites => 'Favorites';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String get search => 'Search';

  @override
  String get searchPharmacies => 'Search pharmacies...';

  @override
  String get searchMedications => 'Search medications...';

  @override
  String get pharmacies => 'Pharmacies';

  @override
  String get onCallPharmacies => 'On-Call Pharmacies';

  @override
  String get nearbyPharmacies => 'Nearby Pharmacies';

  @override
  String get allPharmacies => 'All';

  @override
  String get reserve => 'Reserve';

  @override
  String get directions => 'Directions';

  @override
  String get call => 'Call';

  @override
  String get details => 'Details';

  @override
  String get openNow => 'OPEN NOW';

  @override
  String get closed => 'Closed';

  @override
  String opensAt(String time) {
    return 'Opens at $time';
  }

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get openingHours => 'Opening hours';

  @override
  String get address => 'Address';

  @override
  String get phone => 'Phone';

  @override
  String get myReservations => 'My Reservations';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get ready => 'Ready';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get clearAll => 'Clear all';

  @override
  String get settings => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get language => 'Language';

  @override
  String get security => 'Security';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get logout => 'Logout';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'العربية';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get googleSignIn => 'Continue with Google';

  @override
  String get facebookSignIn => 'Continue with Facebook';

  @override
  String get pharmacyName => 'Pharmacy name';

  @override
  String get pharmacyAddress => 'Pharmacy address';

  @override
  String get pharmacyPhone => 'Pharmacy phone';

  @override
  String get medicationName => 'Medication Name';

  @override
  String get medicationStock => 'Stock';

  @override
  String get medicationPrice => 'Price';

  @override
  String get reservation => 'Reservation';

  @override
  String get reservationDate => 'Reservation Date';

  @override
  String get reservationTime => 'Reservation Time';

  @override
  String get reservationStatus => 'Status';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get qrCodeScanned => 'QR Code scanned successfully';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get tryAgain => 'Try again';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get loading => 'Loading...';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get preferences => 'Preferences';

  @override
  String get support => 'Support';

  @override
  String get account => 'Account';

  @override
  String get welcome => 'Welcome';

  @override
  String get createAccount => 'Create Account';

  @override
  String get client => 'Client';

  @override
  String get pharmacist => 'Pharmacist';

  @override
  String get fullName => 'Full name';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get signIn => 'Sign in';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get emailRequired => 'Email required';

  @override
  String get passwordRequired => 'Password required';

  @override
  String get nameRequired => 'Name required';

  @override
  String get phoneRequired => 'Phone required';

  @override
  String get pharmacyNameRequired => 'Pharmacy name required';

  @override
  String get addressRequired => 'Address required';

  @override
  String get licensePhoto => 'License Photo';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get uploadLicense => 'Please upload a license photo';

  @override
  String get yourNameAndSurname => 'Your name and surname';

  @override
  String get confirmationRequired => 'Confirmation required';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get city => 'City';

  @override
  String get unknown => 'Unknown';

  @override
  String get notProvided => 'Not provided';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get location => 'Location';

  @override
  String get all => 'All';

  @override
  String get orderAgain => 'Order Again';

  @override
  String get cancelRequest => 'Cancel Request';

  @override
  String get noOrders => 'No Orders';

  @override
  String get confirmReservation => 'Confirm Reservation';

  @override
  String get time => 'Time';

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String get cancellationError => 'Error during cancellation';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get popularSearches => 'Popular Searches';

  @override
  String get searchMedicine => 'Search Medicine';

  @override
  String get sortedByDistance => 'Sorted by distance';

  @override
  String get locationUnknown => 'Location unknown';

  @override
  String get noFavorites => 'No Favorites';

  @override
  String get savedPharmacies => 'Your saved pharmacies';

  @override
  String get clear => 'Clear';

  @override
  String get reportProblem => 'Report a Problem';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get callSupport => 'Call Support';

  @override
  String get accountSecurity => 'Account security';

  @override
  String get inDevelopment => 'In Development';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get back => 'Back';

  @override
  String get passwordUpdated => 'Password updated successfully';

  @override
  String get error => 'Error';

  @override
  String get reservedForClients => 'Reserved for clients';

  @override
  String get incorrectCredentials => 'Incorrect email or password';

  @override
  String get verificationStep => 'Verification';

  @override
  String get newPasswordStep => 'New Password';

  @override
  String get doneStep => 'Done';

  @override
  String get yourSmartPharmacy => 'Your smart pharmacy';

  @override
  String get chooseLocation => 'Choose location';

  @override
  String get yourPharmacy => 'Your pharmacy';

  @override
  String get confirmPosition => 'Confirm position';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get validate => 'Validate';

  @override
  String get pharmacyInfo => 'Pharmacy Information';

  @override
  String get scanMedication => 'Scan medication';

  @override
  String get placeBarcode => 'Place barcode in frame';

  @override
  String get medicationsAvailable => 'Medications Available';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get reservations => 'Reservations';

  @override
  String get clientSpace => 'Client Space';

  @override
  String get pharmacistSpace => 'Pharmacist Space';

  @override
  String get or => 'OR';

  @override
  String get noAccountYet => 'Don\'t have an account yet? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get joinSmartPharmaToday => 'Join SmartPharma today';

  @override
  String get iAcceptThe => 'I accept the ';

  @override
  String get termsAndConditions => 'terms and conditions';

  @override
  String get phoneNumberPlaceholder => '+212...';

  @override
  String get enterEmailToReceive => 'Enter your email to receive a reset code';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get sendCode => 'Send Code';

  @override
  String get searchPharmacy => 'Search pharmacy';

  @override
  String get medications => 'Medications';

  @override
  String get map => 'Map';

  @override
  String get list => 'List';

  @override
  String get km => 'km';

  @override
  String get today => 'Today';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get addPharmaciesToList =>
      'Add pharmacies to your list\nfor quick access.';

  @override
  String get searchMedicationAvailability =>
      'Search for medication availability...';

  @override
  String get update => 'Update';

  @override
  String get orderSent => 'Order sent';

  @override
  String get yourOrder => 'Your order';

  @override
  String get newOrder => 'New Order';

  @override
  String get youHaveReceived => 'You have received';

  @override
  String get accepted => 'Accepted';

  @override
  String get rejected => 'Rejected';

  @override
  String get canceled => 'Canceled';

  @override
  String get february => 'February';

  @override
  String get january => 'January';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get searchMedication => 'Search a medication...';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get total => 'Total';

  @override
  String get newReservation => 'New Reservation';

  @override
  String get filterByCategory => 'Filter by category';

  @override
  String get applyFilter => 'Apply Filter';

  @override
  String get prescription => 'Prescription';

  @override
  String get searchClientOrMedication => 'Search client or medication...';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get refuse => 'Refuse';

  @override
  String get myProfile => 'My Profile';

  @override
  String get onCallMode => 'On-Call Mode';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get managePharmacyInfo => 'Manage your pharmacy information';

  @override
  String get pharmacistName => 'Pharmacist Name';

  @override
  String get category => 'Category';

  @override
  String get price => 'Price';

  @override
  String get stock => 'Stock';

  @override
  String get requiresPrescription => 'Requires Prescription';

  @override
  String get barcode => 'Barcode';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get editMedication => 'Edit Medication';

  @override
  String get deleteMedication => 'Delete Medication';

  @override
  String get signUp => 'Sign up';

  @override
  String get seeAll => 'See all';

  @override
  String get nearby => 'Nearby';

  @override
  String get open => 'OPEN';

  @override
  String get forgotPasswordQuestion => 'Forgot password?';

  @override
  String get reservationsCount => 'Reservations';

  @override
  String get searchMedicationPlaceholder => 'Search medication...';

  @override
  String get addPharmaciesTo =>
      'Add pharmacies to your list\nfor quick access.';

  @override
  String get quantity => 'Quantity';

  @override
  String get notes => 'Notes';

  @override
  String get submit => 'Submit';

  @override
  String get helpCenterTitle => 'Help Center';

  @override
  String get contactUs => 'Contact us';

  @override
  String get supportPhone => 'Support phone';

  @override
  String get supportEmail => 'Support email';

  @override
  String get faqAndSupport => 'FAQ & Support';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get editPharmacyInfo => 'Edit pharmacy information';

  @override
  String get searchClientOrMed => 'Search client or medication...';

  @override
  String get noHistory => 'No history';

  @override
  String get viewPrescription => 'View prescription';

  @override
  String get howCanWeHelpYou => 'How can we help you today?';

  @override
  String get reportBugDescription => 'A bug? An error? Let us know.';

  @override
  String get emailSupportDescription => 'For any other question or request.';

  @override
  String get callSupportDescription => 'Urgent? Call us directly.';

  @override
  String get frequentQuestions => 'Frequently Asked Questions';

  @override
  String get howToCancelOrder => 'How to cancel an order?';

  @override
  String get howToCancelOrderAnswer =>
      'Go to your history, select the order and click \'Cancel\'.';

  @override
  String get manageMyInfo => 'Manage my information?';

  @override
  String get manageMyInfoAnswer =>
      'You can modify your data from the Profile > Edit profile tab.';

  @override
  String get accountSecurityAnswer =>
      'To change your password, go to Profile > Security.';

  @override
  String get closedCaps => 'CLOSED';

  @override
  String get informations => 'Informations';

  @override
  String get boxes => 'box(es)';

  @override
  String get date => 'Date';

  @override
  String get summary => 'Summary';

  @override
  String get medication => 'Medication';

  @override
  String get pharmacy => 'Pharmacy';

  @override
  String get totalToPay => 'Total to pay';

  @override
  String get goBack => 'Return';

  @override
  String get reservationConfirmed => 'Reservation Confirmed!';

  @override
  String get orderTransmitted =>
      'Your order has been transmitted to the pharmacy.';

  @override
  String get downloadReceipt => 'Download receipt (PDF)';

  @override
  String get finish => 'Finish';

  @override
  String get reservationReceipt => 'Reservation Receipt';

  @override
  String get pharmacyCaps => 'PHARMACY';

  @override
  String get clientCaps => 'CLIENT';

  @override
  String get designation => 'Designation';

  @override
  String get qty => 'Qty';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get estimatedTotal => 'Estimated Total:';

  @override
  String get ordersSent => 'orders sent';

  @override
  String get newMedication => 'New Medication';

  @override
  String get modify => 'Modify';

  @override
  String get medicationNamePlaceholder => 'Medication name';

  @override
  String get pricePlaceholder => '...Price (MAD)';

  @override
  String get prescriptionRequired => 'Prescription required';

  @override
  String get searchPatientOrMed => 'Search (Patient or Medication)...';

  @override
  String get license => 'License :';

  @override
  String get pharmacySettings => 'PHARMACY SETTINGS';

  @override
  String get pharmacyInformation => 'Pharmacy Information';

  @override
  String get reservationFound => 'Reservation Found';

  @override
  String get patient => 'Patient';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get pharmaciesFound => 'pharmacies found';

  @override
  String get inStock => 'IN STOCK';

  @override
  String get hoursNotAvailable => 'Hours not available';

  @override
  String get noResultsFor => 'No results for';

  @override
  String get noPharmacyFound => 'No pharmacy found';

  @override
  String get onCall => 'On Call';

  @override
  String get openPharmacies => 'Open';

  @override
  String get findNearbyPharmacies => 'Find nearby pharmacies';

  @override
  String get yourOrderFor => 'Your order for';

  @override
  String get isPending => 'is pending';

  @override
  String get updateTitle => 'Update';

  @override
  String get isRejected => 'is Rejected';

  @override
  String get isAccepted => 'is Accepted';

  @override
  String get readyPickedUp => 'READY / PICKED UP';

  @override
  String get pendingCaps => 'PENDING';

  @override
  String get cancelledCaps => 'CANCELLED';

  @override
  String get qtyLabel => 'Qty:';

  @override
  String get searching => 'Searching...';

  @override
  String get searchMedicationCaps => 'SEARCH A MEDICATION';

  @override
  String get searchPatientOrMedication => 'Search (Patient or Medication)...';

  @override
  String get agoTime => 'ago';

  @override
  String get refused => 'Refused';

  @override
  String get addressLabel => 'Address';

  @override
  String get hoursLabel => 'Hours';

  @override
  String get locationLabel => 'Location';

  @override
  String get needHelpPharmacy => 'Need help with your pharmacy space?';

  @override
  String get youReceivedOrder => 'You have received an order:';

  @override
  String get minUnit => 'min';

  @override
  String get hourUnit => 'h';

  @override
  String get justNow => 'Just now';

  @override
  String get noMedicationFound => 'No medication found';

  @override
  String get ordered => 'ordered';

  @override
  String get boxUnit => 'box(es)';

  @override
  String get reservationNotFound => 'Reservation Not Found';

  @override
  String get reservationNotAccepted =>
      'This reservation is not yet accepted or does not exist.';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get barcodeNotFound => 'No medication found with this barcode';

  @override
  String get barcodeOptional => 'Optional';
}
