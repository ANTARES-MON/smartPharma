// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'سمارت فارما';

  @override
  String get home => 'الرئيسية';

  @override
  String get favorites => 'المفضلة';

  @override
  String get history => 'السجل';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get search => 'بحث';

  @override
  String get searchPharmacies => 'البحث عن الصيدليات...';

  @override
  String get searchMedications => 'البحث عن الأدوية...';

  @override
  String get pharmacies => 'الصيدليات';

  @override
  String get onCallPharmacies => 'صيدليات المناوبة';

  @override
  String get nearbyPharmacies => 'الصيدليات القريبة';

  @override
  String get allPharmacies => 'الكل';

  @override
  String get reserve => 'حجز';

  @override
  String get directions => 'الاتجاهات';

  @override
  String get call => 'اتصال';

  @override
  String get details => 'التفاصيل';

  @override
  String get openNow => 'مفتوحة الآن';

  @override
  String get closed => 'مغلق';

  @override
  String opensAt(String time) {
    return 'تفتح الساعة $time';
  }

  @override
  String get monday => 'الاثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get openingHours => 'ساعات العمل';

  @override
  String get address => 'العنوان';

  @override
  String get phone => 'الهاتف';

  @override
  String get myReservations => 'حجوزاتي';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get confirmed => 'مؤكدة';

  @override
  String get ready => 'جاهز';

  @override
  String get completed => 'منتهية';

  @override
  String get cancelled => 'ملغاة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get language => 'اللغة';

  @override
  String get security => 'الأمان';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get privacy => 'سياسة الخصوصية';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'العربية';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get languageChanged => 'تم تغيير اللغة بنجاح';

  @override
  String get name => 'الاسم';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get remove => 'إزالة';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get orContinueWith => 'أو المتابعة مع';

  @override
  String get googleSignIn => 'المتابعة مع Google';

  @override
  String get facebookSignIn => 'المتابعة مع Facebook';

  @override
  String get pharmacyName => 'اسم الصيدلية';

  @override
  String get pharmacyAddress => 'عنوان الصيدلية';

  @override
  String get pharmacyPhone => 'هاتف الصيدلية';

  @override
  String get medicationName => 'اسم الدواء';

  @override
  String get medicationStock => 'المخزون';

  @override
  String get medicationPrice => 'السعر';

  @override
  String get reservation => 'الحجز';

  @override
  String get reservationDate => 'تاريخ الحجز';

  @override
  String get reservationTime => 'وقت الحجز';

  @override
  String get reservationStatus => 'الحالة';

  @override
  String get scanQRCode => 'مسح رمز QR';

  @override
  String get qrCodeScanned => 'تم مسح رمز QR بنجاح';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get pleaseWait => 'يرجى الانتظار...';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'حسناً';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get support => 'الدعم';

  @override
  String get account => 'الحساب';

  @override
  String get welcome => 'مرحبا';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get client => 'عميل';

  @override
  String get pharmacist => 'صيدلي';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get passwordMismatch => 'كلمات المرور غير متطابقة';

  @override
  String get fillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get pharmacyNameRequired => 'اسم الصيدلية مطلوب';

  @override
  String get addressRequired => 'العنوان مطلوب';

  @override
  String get licensePhoto => 'صورة الرخصة';

  @override
  String get uploadPhoto => 'تحميل الصورة';

  @override
  String get uploadLicense => 'يرجى تحميل صورة رخصتك';

  @override
  String get yourNameAndSurname => 'اسمك الكامل';

  @override
  String get confirmationRequired => 'التأكيد مطلوب';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get city => 'المدينة';

  @override
  String get unknown => 'غير معروف';

  @override
  String get notProvided => 'غير محدد';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get location => 'الموقع';

  @override
  String get all => 'الكل';

  @override
  String get orderAgain => 'اطلب مرة أخرى';

  @override
  String get cancelRequest => 'إلغاء الطلب';

  @override
  String get noOrders => 'لا توجد طلبات';

  @override
  String get confirmReservation => 'تأكيد الحجز';

  @override
  String get time => 'الوقت';

  @override
  String get orderCancelled => 'تم إلغاء الطلب';

  @override
  String get cancellationError => 'خطأ في الإلغاء';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get popularSearches => 'عمليات البحث الشائعة';

  @override
  String get searchMedicine => 'البحث عن دواء';

  @override
  String get sortedByDistance => 'مرتب حسب المسافة';

  @override
  String get locationUnknown => 'الموقع غير معروف';

  @override
  String get noFavorites => 'لا توجد مفضلات';

  @override
  String get savedPharmacies => 'صيدلياتك المحفوظة';

  @override
  String get clear => 'مسح';

  @override
  String get reportProblem => 'الإبلاغ عن مشكلة';

  @override
  String get sendEmail => 'إرسال بريد إلكتروني';

  @override
  String get callSupport => 'اتصل بالدعم';

  @override
  String get accountSecurity => 'أمان الحساب';

  @override
  String get inDevelopment => 'قيد التطوير';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get back => 'رجوع';

  @override
  String get passwordUpdated => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get error => 'خطأ';

  @override
  String get reservedForClients => 'مخصص للعملاء';

  @override
  String get incorrectCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get verificationStep => 'التحقق';

  @override
  String get newPasswordStep => 'كلمة المرور الجديدة';

  @override
  String get doneStep => 'تم';

  @override
  String get yourSmartPharmacy => 'صيدليتك الذكية';

  @override
  String get chooseLocation => 'اختيار الموقع';

  @override
  String get yourPharmacy => 'صيدليتك';

  @override
  String get confirmPosition => 'تأكيد الموضع';

  @override
  String get dashboard => 'لوحة القيادة';

  @override
  String get validate => 'تأكيد';

  @override
  String get pharmacyInfo => 'معلومات الصيدلية';

  @override
  String get scanMedication => 'مسح دواء';

  @override
  String get placeBarcode => 'ضع الباركود في الإطار';

  @override
  String get medicationsAvailable => 'الأدوية المتوفرة';

  @override
  String get outOfStock => 'غير متوفر';

  @override
  String get reservations => 'الحجوزات';

  @override
  String get clientSpace => 'مساحة العميل';

  @override
  String get pharmacistSpace => 'مساحة الصيدلي';

  @override
  String get or => 'أو';

  @override
  String get noAccountYet => 'ليس لديك حساب بعد؟ ';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟ ';

  @override
  String get joinSmartPharmaToday => 'انضم إلى SmartPharma اليوم';

  @override
  String get iAcceptThe => 'أوافق على ';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get phoneNumberPlaceholder => '+212...';

  @override
  String get enterEmailToReceive =>
      'أدخل بريدك الإلكتروني لتلقي رمز إعادة التعيين';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get searchPharmacy => 'البحث عن صيدلية';

  @override
  String get medications => 'الأدوية';

  @override
  String get map => 'خريطة';

  @override
  String get list => 'قائمة';

  @override
  String get km => 'كم';

  @override
  String get today => 'اليوم';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get myFavorites => 'المفضلة';

  @override
  String get addPharmaciesToList => 'أضف الصيدليات إلى قائمتك\nللوصول السريع.';

  @override
  String get searchMedicationAvailability => 'البحث عن توفر الدواء...';

  @override
  String get update => 'تحديث';

  @override
  String get orderSent => 'تم إرسال الطلب';

  @override
  String get yourOrder => 'طلبك';

  @override
  String get newOrder => 'طلب جديد';

  @override
  String get youHaveReceived => 'لقد استلمت';

  @override
  String get accepted => 'مقبول';

  @override
  String get rejected => 'مرفوض';

  @override
  String get canceled => 'ملغى';

  @override
  String get february => 'فبراير';

  @override
  String get january => 'يناير';

  @override
  String get march => 'مارس';

  @override
  String get april => 'أبريل';

  @override
  String get may => 'مايو';

  @override
  String get june => 'يونيو';

  @override
  String get july => 'يوليو';

  @override
  String get august => 'أغسطس';

  @override
  String get september => 'سبتمبر';

  @override
  String get october => 'أكتوبر';

  @override
  String get november => 'نوفمبر';

  @override
  String get december => 'ديسمبر';

  @override
  String get searchMedication => 'ابحت عن دواء...';

  @override
  String get lowStock => 'مخزون منخفض';

  @override
  String get total => 'المجموع';

  @override
  String get newReservation => 'حجز جديد';

  @override
  String get filterByCategory => 'تصفية حسب الفئة';

  @override
  String get applyFilter => 'تطبيق التصفية';

  @override
  String get prescription => 'وصفة طبية';

  @override
  String get searchClientOrMedication => 'البحث عن عميل أو دواء...';

  @override
  String get noPendingRequests => 'لا توجد طلبات معلقة';

  @override
  String get refuse => 'رفض';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get onCallMode => 'وضع الحراسة';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get managePharmacyInfo => 'إدارة معلومات صيدليتك';

  @override
  String get pharmacistName => 'اسم الصيدلي';

  @override
  String get category => 'الفئة';

  @override
  String get price => 'السعر';

  @override
  String get stock => 'المخزون';

  @override
  String get requiresPrescription => 'يتطلب وصفة طبية';

  @override
  String get barcode => 'الباركود';

  @override
  String get addMedication => 'إضافة دواء';

  @override
  String get editMedication => 'تعديل الدواء';

  @override
  String get deleteMedication => 'حذف الدواء';

  @override
  String get signUp => 'التسجيل';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get nearby => 'قريب';

  @override
  String get open => 'مفتوحة';

  @override
  String get forgotPasswordQuestion => 'هل نسيت كلمة المرور؟';

  @override
  String get reservationsCount => 'الحجوزات';

  @override
  String get searchMedicationPlaceholder => 'البحث عن دواء...';

  @override
  String get addPharmaciesTo => 'أضف الصيدليات إلى قائمتك\nللوصول السريع.';

  @override
  String get quantity => 'الكمية';

  @override
  String get notes => 'ملاحظات';

  @override
  String get submit => 'إرسال';

  @override
  String get helpCenterTitle => 'مركز المساعدة';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get supportPhone => 'هاتف الدعم';

  @override
  String get supportEmail => 'بريد الدعم';

  @override
  String get faqAndSupport => 'مركز المساعدة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get editPharmacyInfo => 'تعديل معلومات الصيدلية';

  @override
  String get searchClientOrMed => 'البحث عن عميل أو دواء...';

  @override
  String get noHistory => 'لا يوجد سجل';

  @override
  String get viewPrescription => 'عرض الوصفة';

  @override
  String get howCanWeHelpYou => 'كيف يمكننا مساعدتك اليوم؟';

  @override
  String get reportBugDescription => 'خطأ؟ مشكلة؟ أخبرنا.';

  @override
  String get emailSupportDescription => 'لأي سؤال أو طلب آخر.';

  @override
  String get callSupportDescription => 'عاجل؟ اتصل بنا مباشرة.';

  @override
  String get frequentQuestions => 'الأسئلة الشائعة';

  @override
  String get howToCancelOrder => 'كيف ألغي طلب؟';

  @override
  String get howToCancelOrderAnswer =>
      'انتقل إلى سجلك، حدد الطلب وانقر على \'إلغاء\'.';

  @override
  String get manageMyInfo => 'إدارة معلوماتي؟';

  @override
  String get manageMyInfoAnswer =>
      'يمكنك تعديل بياناتك من علامة التبويب الملف الشخصي > تعديل الملف الشخصي.';

  @override
  String get accountSecurityAnswer =>
      'لتغيير كلمة المرور، انتقل إلى الملف الشخصي > الأمان.';

  @override
  String get closedCaps => 'مغلق';

  @override
  String get informations => 'معلومات';

  @override
  String get boxes => 'علبة(ات)';

  @override
  String get date => 'التاريخ';

  @override
  String get summary => 'ملخص';

  @override
  String get medication => 'دواء';

  @override
  String get pharmacy => 'صيدلية';

  @override
  String get totalToPay => 'الإجمالي للدفع';

  @override
  String get goBack => 'عودة';

  @override
  String get reservationConfirmed => 'تم تأكيد الحجز!';

  @override
  String get orderTransmitted => 'تم إرسال طلبك إلى الصيدلية.';

  @override
  String get downloadReceipt => 'تحميل الإيصال (PDF)';

  @override
  String get finish => 'إنهاء';

  @override
  String get reservationReceipt => 'إيصال الحجز';

  @override
  String get pharmacyCaps => 'صيدلية';

  @override
  String get clientCaps => 'عميل';

  @override
  String get designation => 'التعيين';

  @override
  String get qty => 'الكمية';

  @override
  String get unitPrice => 'سعر الوحدة';

  @override
  String get estimatedTotal => 'الإجمالي التقديري:';

  @override
  String get ordersSent => 'الطلبات المرسلة';

  @override
  String get newMedication => 'دواء جديد';

  @override
  String get modify => 'تعديل';

  @override
  String get medicationNamePlaceholder => 'اسم الدواء';

  @override
  String get pricePlaceholder => '...السعر (درهم)';

  @override
  String get prescriptionRequired => 'وصفة طبية مطلوبة';

  @override
  String get searchPatientOrMed => 'بحث (مريض أو دواء)...';

  @override
  String get license => 'الترخيص:';

  @override
  String get pharmacySettings => 'إعدادات الصيدلية';

  @override
  String get pharmacyInformation => 'معلومات الصيدلية';

  @override
  String get reservationFound => 'تم العثور على الحجز';

  @override
  String get patient => 'مريض';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get pharmaciesFound => 'صيدليات متوفرة';

  @override
  String get inStock => 'متوفر';

  @override
  String get hoursNotAvailable => 'الساعات غير متوفرة';

  @override
  String get noResultsFor => 'لا توجد نتائج لـ';

  @override
  String get noPharmacyFound => 'لم يتم العثور على صيدلية';

  @override
  String get onCall => 'في وضع الحراسة';

  @override
  String get openPharmacies => 'مفتوحة';

  @override
  String get findNearbyPharmacies => 'ابحث عن صيدليات قريبة';

  @override
  String get yourOrderFor => 'طلبك لـ';

  @override
  String get isPending => 'قيد الانتظار';

  @override
  String get updateTitle => 'تحديث';

  @override
  String get isRejected => 'مرفوض';

  @override
  String get isAccepted => 'مقبول';

  @override
  String get readyPickedUp => 'جاهز / تم استلامه';

  @override
  String get pendingCaps => 'قيد الانتظار';

  @override
  String get cancelledCaps => 'ملغى';

  @override
  String get qtyLabel => 'الكمية:';

  @override
  String get searching => 'بحث...';

  @override
  String get searchMedicationCaps => 'ابحث عن دواء';

  @override
  String get searchPatientOrMedication => 'بحث (مريض أو دواء)...';

  @override
  String get agoTime => 'منذ';

  @override
  String get refused => 'مرفوضة';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get hoursLabel => 'الساعات';

  @override
  String get locationLabel => 'الموقع';

  @override
  String get needHelpPharmacy => 'هل تحتاج مساعدة مع مساحة الصيدلية؟';

  @override
  String get youReceivedOrder => 'لقد تلقيت طلبًا:';

  @override
  String get minUnit => 'د';

  @override
  String get hourUnit => 'س';

  @override
  String get justNow => 'الآن';

  @override
  String get noMedicationFound => 'لم يتم العثور على دواء';

  @override
  String get ordered => 'طلب';

  @override
  String get boxUnit => 'علبة';

  @override
  String get reservationNotFound => 'لم يتم العثور على الحجز';

  @override
  String get reservationNotAccepted =>
      'هذا الحجز لم يتم قبوله بعد أو غير موجود.';

  @override
  String get scanBarcode => 'مسح الباركود';

  @override
  String get barcodeNotFound => 'لم يتم العثور على دواء بهذا الباركود';

  @override
  String get barcodeOptional => 'اختياري';
}
