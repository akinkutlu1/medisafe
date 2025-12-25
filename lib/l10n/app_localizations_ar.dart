// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'MediSafe';

  @override
  String get settings => 'الإعدادات';

  @override
  String get theme => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get lightTheme => 'المظهر الفاتح';

  @override
  String get darkTheme => 'المظهر الداكن';

  @override
  String get systemTheme => 'مظهر النظام';

  @override
  String get turkish => 'التركية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get russian => 'الروسية';

  @override
  String get arabic => 'العربية';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get remindersAndAlerts => 'التذكيرات والتنبيهات';

  @override
  String get backgroundPermissions => 'أذونات الخلفية';

  @override
  String get batteryOptimization => 'تحسين البطارية';

  @override
  String get notificationPermission => 'إذن الإشعارات';

  @override
  String get exactAlarmPermission => 'إذن المنبه الدقيق';

  @override
  String get physicalDeviceAlarms => 'منبهات الأجهزة الفعلية';

  @override
  String get batteryOptInfo =>
      'لعمل المنبهات:\n• أوقف تحسين البطارية\n• فعّل أذونات الإشعارات\n• أضف التطبيق إلى قائمة \"التطبيقات المحمية\"\n• أوقف قيود خلفية الجهاز';

  @override
  String get appAbout => 'حول التطبيق';

  @override
  String get version => 'MediSafe v1.0.0';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutConfirm =>
      'هل أنت متأكد من أنك تريد تسجيل الخروج من حسابك؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get guest => 'ضيف';

  @override
  String get notLoggedIn => 'لم تسجل الدخول';

  @override
  String get errorSigningOut => 'حدث خطأ أثناء تسجيل الخروج';

  @override
  String get off => 'مغلق';

  @override
  String get on => 'مفتوح';

  @override
  String get recommended => 'مُوصى به';

  @override
  String get alarmsWontWork => 'قد لا تعمل المنبهات';

  @override
  String get alarmsMayDelay => 'قد تتأخر المنبهات';

  @override
  String get medicineNotFound => 'لم يتم العثور على معلومات الدواء';

  @override
  String get cannotOpenAlarm => 'لا يمكن فتح شاشة المنبه';

  @override
  String get goBack => 'العودة';

  @override
  String get manageMedicines => 'إدارة الأدوية';

  @override
  String get manageMedicinesDescription =>
      'أضف أدويتك واحصل على تذكيرات في الوقت المناسب وتتبع صحتك.';

  @override
  String get home => 'الرئيسية';

  @override
  String get addMedicine => 'إضافة دواء';

  @override
  String get history => 'التاريخ';

  @override
  String get healthyLiving => 'الحياة الصحية';

  @override
  String get medicines => 'الأدوية';

  @override
  String get addNewMedicine => 'إضافة دواء جديد';

  @override
  String get fillInfoAndSave => 'املأ المعلومات واحفظ';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get name => 'الاسم';

  @override
  String get enterMedicineName => 'أدخل اسم الدواء';

  @override
  String get required => 'مطلوب';

  @override
  String get type => 'النوع';

  @override
  String get selectType => 'اختر نوع';

  @override
  String get tablet => 'قرص';

  @override
  String get syrup => 'شراب';

  @override
  String get capsule => 'كبسولة';

  @override
  String get injection => 'حقنة';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get hourly => 'كل ساعة';

  @override
  String get mealBased => 'حسب الوجبة';

  @override
  String get interval => 'الفترة';

  @override
  String get hours => 'س';

  @override
  String get mealTimes => 'أوقات الوجبات';

  @override
  String get morning => 'الصباح';

  @override
  String get afternoon => 'بعد الظهر';

  @override
  String get evening => 'المساء';

  @override
  String get alarmEnabled => 'المنبه مفعل';

  @override
  String get save => 'حفظ';

  @override
  String get scanFromCamera => 'مسح من الكاميرا';

  @override
  String get textNotDetected => 'لم يتم اكتشاف النص';

  @override
  String get cameraReadFailed => 'فشلت قراءة الكاميرا';

  @override
  String get sessionRequired => 'مطلوب جلسة';

  @override
  String get selectAtLeastOneMeal => 'اختر وجبة واحدة على الأقل';

  @override
  String get endDateCannotBeBeforeStart =>
      'تاريخ النهاية لا يمكن أن يكون قبل تاريخ البداية';

  @override
  String get settingUpAlarm => 'جاري إعداد المنبه...';

  @override
  String get medicineSaved => 'تم حفظ الدواء';

  @override
  String get couldNotSave => 'لا يمكن الحفظ';

  @override
  String get takeMedicine => 'تناول دواءك';

  @override
  String get takeAfterMeal => 'تناول بعد الوجبة';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get register => 'تسجيل';

  @override
  String get registerNow => 'سجل الآن';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get loginNow => 'سجل دخول الآن';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get signInWithGoogle => 'تسجيل الدخول بحساب Google';

  @override
  String get welcome => 'مرحباً';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get next => 'التالي';

  @override
  String get done => 'تم';

  @override
  String get skip => 'تخطي';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get emailAndPasswordEmpty =>
      'لا يمكن أن تكون حقول البريد الإلكتروني وكلمة المرور فارغة';

  @override
  String get loginError => 'حدث خطأ أثناء تسجيل الدخول';

  @override
  String get userNotFound =>
      'لم يتم العثور على مستخدم بهذا عنوان البريد الإلكتروني';

  @override
  String get wrongPassword => 'كلمة مرور غير صحيحة';

  @override
  String get invalidEmail => 'عنوان بريد إلكتروني غير صالح';

  @override
  String get userDisabled => 'تم تعطيل هذا الحساب';

  @override
  String get tooManyRequests =>
      'محاولات تسجيل دخول فاشلة كثيرة جداً. يرجى المحاولة مرة أخرى لاحقاً';

  @override
  String get alarms => 'المنبهات';

  @override
  String get addNewMedicineButton => 'إضافة دواء جديد';

  @override
  String get loginRequired => 'مطلوب تسجيل الدخول';

  @override
  String get historyTitle => 'التاريخ';

  @override
  String get options => 'خيارات';

  @override
  String get clear => 'مسح';

  @override
  String get viewAll => 'عرض كامل التاريخ';

  @override
  String get healthyLivingTitle => 'الحياة الصحية';

  @override
  String get dailyTips => 'نصائح يومية';

  @override
  String get currentNews => 'الأخبار الحالية';

  @override
  String get healthyLivingMessage =>
      'اتخذ خطوات صغيرة لحياة أفضل. اعتن بنفسك اليوم!';

  @override
  String get increaseWaterIntake => 'زيادة شرب الماء';

  @override
  String get waterIntakeDescription =>
      'شرب 6-8 أكواب من الماء يومياً يحسن الأداء العقلي والجسدي.';

  @override
  String get thirtyMinutesExercise => '30 دقيقة حركة';

  @override
  String get exerciseDescription => 'المشي اليومي بوتيرة خفيفة يدعم صحة القلب.';

  @override
  String get regularSleep => 'نوم منتظم';

  @override
  String get sleepDescription => '7-8 ساعات من النوم تقوي جهاز المناعة.';

  @override
  String get vegetablesAndFruits => 'الخضار والفواكه';

  @override
  String get vegetablesDescription =>
      'الأطباق الملونة توفر المزيد من الفيتامينات والألياف.';

  @override
  String get whoPhysicalActivityUpdate =>
      'منظمة الصحة العالمية: تحديث إرشادات النشاط البدني';

  @override
  String get smartWatchSleep =>
      'تتبع النوم بالساعات الذكية: ما يجب الانتباه إليه؟';

  @override
  String get omega3HeartHealth => 'تحليل جديد حول أوميغا-3 وصحة القلب';

  @override
  String get currentHealthSource => 'الصحة الحالية';

  @override
  String get techHealthSource => 'التقنية الصحية';

  @override
  String get medicalWorldSource => 'العالم الطبي';

  @override
  String readingTime(int minutes) {
    return '$minutes د';
  }

  @override
  String get historyInfoMessage =>
      'تظهر هذه القائمة السجلات المتبقية بعد المسح. للتاريخ الكامل، انتقل إلى \"عرض كامل التاريخ\" من أعلى اليمين.';

  @override
  String get historyCleared => 'تم مسح التاريخ. البيانات تستمر في التخزين.';

  @override
  String get noHistoryYet => 'لا توجد سجلات تاريخ بعد';

  @override
  String get historyDataKeptMessage =>
      'عند مسح هذه الشاشة، تستمر البيانات في الاحتفاظ بها في قاعدة البيانات.';

  @override
  String get cannotLoadHistory => 'تعذر تحميل معلومات التاريخ';

  @override
  String get historyLoadFailed => 'فشل في تحميل التاريخ';

  @override
  String get splashMessage1 => 'تناول أدويتك في الوقت المحدد، احم صحتك.';

  @override
  String get splashMessage2 => 'نحن هنا من أجل صحتك.';

  @override
  String get splashMessage3 => 'لا تنس دواءك، اجعل حياتك أسهل.';

  @override
  String get splashMessage4 =>
      'الحياة الصحية،\nتبدأ بتناول الدواء في الوقت المحدد.';

  @override
  String get splashMessage5 => 'الصحة في كل جرعة، السلام في كل إشعار.';

  @override
  String get didYouTakeMedicine => 'هل تناولت دواءك؟';

  @override
  String get tookMyMedicine => 'تناولت دوائي';

  @override
  String get snooze30Min => 'تأجيل (30 دقيقة)';

  @override
  String get ignoreMarkTaken => 'تجاهل (وضع علامة كمأخوذ)';

  @override
  String get snoozeIgnoreExplanation =>
      'خيار التأجيل سيذكرك مرة أخرى خلال 30 دقيقة. خيار التجاهل يضع علامة كمأخوذ.';

  @override
  String get connectionTimeout => 'انتهت مهلة العملية. يرجى المحاولة مرة أخرى.';

  @override
  String get checkInternetConnection => 'تحقق من اتصال الإنترنت الخاص بك';

  @override
  String get generalError => 'حدث خطأ';

  @override
  String get snoozeOperationFailed => 'فشلت عملية التأجيل';

  @override
  String get okay => 'حسناً';

  @override
  String get processing => 'معالجة...';

  @override
  String get notScheduled => 'غير مجدول';

  @override
  String get now => 'الآن';

  @override
  String get nextAlarm => 'المنبه التالي';

  @override
  String get days => 'ي';

  @override
  String get minutes => 'د';

  @override
  String get seconds => 'ث';

  @override
  String everyXHours(int hours) {
    return 'كل $hours ساعات';
  }
}
