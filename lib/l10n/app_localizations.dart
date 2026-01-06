import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
    Locale('en'),
    Locale('ru'),
    Locale('ar')
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'MediSafe'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @lightTheme.
  ///
  /// In tr, this message translates to:
  /// **'Açık Tema'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Tema'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Teması'**
  String get systemTheme;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get english;

  /// No description provided for @russian.
  ///
  /// In tr, this message translates to:
  /// **'Rusça'**
  String get russian;

  /// No description provided for @arabic.
  ///
  /// In tr, this message translates to:
  /// **'Arapça'**
  String get arabic;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @remindersAndAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatmalar ve uyarılar'**
  String get remindersAndAlerts;

  /// No description provided for @backgroundPermissions.
  ///
  /// In tr, this message translates to:
  /// **'Arka Plan İzinleri'**
  String get backgroundPermissions;

  /// No description provided for @batteryOptimization.
  ///
  /// In tr, this message translates to:
  /// **'Pil Optimizasyonu'**
  String get batteryOptimization;

  /// No description provided for @notificationPermission.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim İzni'**
  String get notificationPermission;

  /// No description provided for @exactAlarmPermission.
  ///
  /// In tr, this message translates to:
  /// **'Tam Zamanlı Alarm İzni'**
  String get exactAlarmPermission;

  /// No description provided for @physicalDeviceAlarms.
  ///
  /// In tr, this message translates to:
  /// **'Fiziksel Cihazlarda Alarmlar'**
  String get physicalDeviceAlarms;

  /// No description provided for @batteryOptInfo.
  ///
  /// In tr, this message translates to:
  /// **'Alarmların çalışması için:\n• Pil optimizasyonunu kapatın\n• Bildirim izinlerini açın\n• Uygulamayı \"Korunan uygulamalar\" listesine ekleyin\n• Cihazınızın arka plan kısıtlamalarını kapatın'**
  String get batteryOptInfo;

  /// No description provided for @appAbout.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Hakkında'**
  String get appAbout;

  /// No description provided for @version.
  ///
  /// In tr, this message translates to:
  /// **'MediSafe v1.0.0'**
  String get version;

  /// No description provided for @signOut.
  ///
  /// In tr, this message translates to:
  /// **'Oturumu Kapat'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızdan çıkmak istediğinizden emin misiniz?'**
  String get signOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get confirm;

  /// No description provided for @guest.
  ///
  /// In tr, this message translates to:
  /// **'Misafir'**
  String get guest;

  /// No description provided for @notLoggedIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapmadınız'**
  String get notLoggedIn;

  /// No description provided for @errorSigningOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapılırken bir hata oluştu'**
  String get errorSigningOut;

  /// No description provided for @off.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get off;

  /// No description provided for @on.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get on;

  /// No description provided for @recommended.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen'**
  String get recommended;

  /// No description provided for @alarmsWontWork.
  ///
  /// In tr, this message translates to:
  /// **'Alarmlar çalışmayabilir'**
  String get alarmsWontWork;

  /// No description provided for @alarmsMayDelay.
  ///
  /// In tr, this message translates to:
  /// **'Alarmlar gecikebilir'**
  String get alarmsMayDelay;

  /// No description provided for @medicineNotFound.
  ///
  /// In tr, this message translates to:
  /// **'İlaç bilgisi bulunamadı'**
  String get medicineNotFound;

  /// No description provided for @cannotOpenAlarm.
  ///
  /// In tr, this message translates to:
  /// **'Alarm ekranı açılamadı'**
  String get cannotOpenAlarm;

  /// No description provided for @goBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri Dön'**
  String get goBack;

  /// No description provided for @manageMedicines.
  ///
  /// In tr, this message translates to:
  /// **'İlaçlarını yönet'**
  String get manageMedicines;

  /// No description provided for @manageMedicinesDescription.
  ///
  /// In tr, this message translates to:
  /// **'İlaçlarınızı ekleyin, zamanında hatırlatmalar alın ve sağlığınızı takip edin.'**
  String get manageMedicinesDescription;

  /// No description provided for @home.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get home;

  /// No description provided for @addMedicine.
  ///
  /// In tr, this message translates to:
  /// **'İlaç Ekle'**
  String get addMedicine;

  /// No description provided for @history.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get history;

  /// No description provided for @healthyLiving.
  ///
  /// In tr, this message translates to:
  /// **'Sağlıklı Yaşam'**
  String get healthyLiving;

  /// No description provided for @medicines.
  ///
  /// In tr, this message translates to:
  /// **'İlaçlar'**
  String get medicines;

  /// No description provided for @addNewMedicine.
  ///
  /// In tr, this message translates to:
  /// **'Yeni İlaç Ekle'**
  String get addNewMedicine;

  /// No description provided for @fillInfoAndSave.
  ///
  /// In tr, this message translates to:
  /// **'Bilgileri doldurun ve kaydedin'**
  String get fillInfoAndSave;

  /// No description provided for @startDate.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Günü'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş Günü'**
  String get endDate;

  /// No description provided for @name.
  ///
  /// In tr, this message translates to:
  /// **'Adı'**
  String get name;

  /// No description provided for @enterMedicineName.
  ///
  /// In tr, this message translates to:
  /// **'İlaç adını yazın'**
  String get enterMedicineName;

  /// No description provided for @required.
  ///
  /// In tr, this message translates to:
  /// **'Gerekli'**
  String get required;

  /// No description provided for @type.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get type;

  /// No description provided for @selectType.
  ///
  /// In tr, this message translates to:
  /// **'Bir tür seçin'**
  String get selectType;

  /// No description provided for @tablet.
  ///
  /// In tr, this message translates to:
  /// **'Tablet'**
  String get tablet;

  /// No description provided for @syrup.
  ///
  /// In tr, this message translates to:
  /// **'Şurup'**
  String get syrup;

  /// No description provided for @capsule.
  ///
  /// In tr, this message translates to:
  /// **'Kapsül'**
  String get capsule;

  /// No description provided for @injection.
  ///
  /// In tr, this message translates to:
  /// **'Enjeksiyon'**
  String get injection;

  /// No description provided for @reminders.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcı'**
  String get reminders;

  /// No description provided for @hourly.
  ///
  /// In tr, this message translates to:
  /// **'Saatlik'**
  String get hourly;

  /// No description provided for @mealBased.
  ///
  /// In tr, this message translates to:
  /// **'Öğünlere göre'**
  String get mealBased;

  /// No description provided for @interval.
  ///
  /// In tr, this message translates to:
  /// **'Aralık'**
  String get interval;

  /// No description provided for @hours.
  ///
  /// In tr, this message translates to:
  /// **'sa'**
  String get hours;

  /// No description provided for @mealTimes.
  ///
  /// In tr, this message translates to:
  /// **'Öğün Saatleri'**
  String get mealTimes;

  /// No description provided for @morning.
  ///
  /// In tr, this message translates to:
  /// **'Sabah'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In tr, this message translates to:
  /// **'Öğle'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get evening;

  /// No description provided for @alarmEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Alarm Açık'**
  String get alarmEnabled;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @scanFromCamera.
  ///
  /// In tr, this message translates to:
  /// **'Kameradan Tara'**
  String get scanFromCamera;

  /// No description provided for @textNotDetected.
  ///
  /// In tr, this message translates to:
  /// **'Metin tespit edilemedi'**
  String get textNotDetected;

  /// No description provided for @cameraReadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kamera ile okuma başarısız oldu'**
  String get cameraReadFailed;

  /// No description provided for @sessionRequired.
  ///
  /// In tr, this message translates to:
  /// **'Oturum gerekli'**
  String get sessionRequired;

  /// No description provided for @selectAtLeastOneMeal.
  ///
  /// In tr, this message translates to:
  /// **'En az bir öğün seçin'**
  String get selectAtLeastOneMeal;

  /// No description provided for @endDateCannotBeBeforeStart.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş günü başlangıçtan önce olamaz'**
  String get endDateCannotBeBeforeStart;

  /// No description provided for @settingUpAlarm.
  ///
  /// In tr, this message translates to:
  /// **'Alarm ayarlanıyor...'**
  String get settingUpAlarm;

  /// No description provided for @medicineSaved.
  ///
  /// In tr, this message translates to:
  /// **'İlaç kaydedildi'**
  String get medicineSaved;

  /// No description provided for @couldNotSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilemedi'**
  String get couldNotSave;

  /// No description provided for @takeMedicine.
  ///
  /// In tr, this message translates to:
  /// **'İlacınızı alınız'**
  String get takeMedicine;

  /// No description provided for @takeAfterMeal.
  ///
  /// In tr, this message translates to:
  /// **'Öğünden sonra alın'**
  String get takeAfterMeal;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu?'**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get register;

  /// No description provided for @registerNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Kayıt Ol'**
  String get registerNow;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabınız var mı?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Giriş Yap'**
  String get loginNow;

  /// No description provided for @enterEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinizi girin'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifrenizi girin'**
  String get enterPassword;

  /// No description provided for @signInWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get signInWithGoogle;

  /// No description provided for @welcome.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz'**
  String get welcome;

  /// No description provided for @getStarted.
  ///
  /// In tr, this message translates to:
  /// **'Başlayın'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get next;

  /// No description provided for @done.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get skip;

  /// No description provided for @selectTime.
  ///
  /// In tr, this message translates to:
  /// **'Saat Seç'**
  String get selectTime;

  /// No description provided for @emailAndPasswordEmpty.
  ///
  /// In tr, this message translates to:
  /// **'E-posta ve şifre alanları boş olamaz'**
  String get emailAndPasswordEmpty;

  /// No description provided for @loginError.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapılırken bir hata oluştu'**
  String get loginError;

  /// No description provided for @userNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı'**
  String get userNotFound;

  /// No description provided for @wrongPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre hatalı'**
  String get wrongPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz e-posta adresi'**
  String get invalidEmail;

  /// No description provided for @userDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap devre dışı bırakılmış'**
  String get userDisabled;

  /// No description provided for @tooManyRequests.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin'**
  String get tooManyRequests;

  /// No description provided for @alarms.
  ///
  /// In tr, this message translates to:
  /// **'Alarmlar'**
  String get alarms;

  /// No description provided for @addNewMedicineButton.
  ///
  /// In tr, this message translates to:
  /// **'Yeni ilaç ekle'**
  String get addNewMedicineButton;

  /// No description provided for @loginRequired.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapılmalı'**
  String get loginRequired;

  /// No description provided for @historyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get historyTitle;

  /// No description provided for @options.
  ///
  /// In tr, this message translates to:
  /// **'Seçenekler'**
  String get options;

  /// No description provided for @clear.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clear;

  /// No description provided for @viewAll.
  ///
  /// In tr, this message translates to:
  /// **'Tüm geçmişi gör'**
  String get viewAll;

  /// No description provided for @healthyLivingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sağlıklı Yaşam'**
  String get healthyLivingTitle;

  /// No description provided for @dailyTips.
  ///
  /// In tr, this message translates to:
  /// **'Günlük İpuçları'**
  String get dailyTips;

  /// No description provided for @currentNews.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Haberler'**
  String get currentNews;

  /// No description provided for @healthyLivingMessage.
  ///
  /// In tr, this message translates to:
  /// **'Daha iyi bir yaşam için küçük adımlar atın. Bugün kendinize iyi bakın!'**
  String get healthyLivingMessage;

  /// No description provided for @increaseWaterIntake.
  ///
  /// In tr, this message translates to:
  /// **'Su tüketimini artırın'**
  String get increaseWaterIntake;

  /// No description provided for @waterIntakeDescription.
  ///
  /// In tr, this message translates to:
  /// **'Günde 6-8 bardak su içmek zihinsel ve fiziksel performansı artırır.'**
  String get waterIntakeDescription;

  /// No description provided for @thirtyMinutesExercise.
  ///
  /// In tr, this message translates to:
  /// **'30 dakika hareket'**
  String get thirtyMinutesExercise;

  /// No description provided for @exerciseDescription.
  ///
  /// In tr, this message translates to:
  /// **'Her gün hafif tempolu yürüyüş kalp sağlığını destekler.'**
  String get exerciseDescription;

  /// No description provided for @regularSleep.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli uyku'**
  String get regularSleep;

  /// No description provided for @sleepDescription.
  ///
  /// In tr, this message translates to:
  /// **'7-8 saat uyku bağışıklık sistemini güçlendirir.'**
  String get sleepDescription;

  /// No description provided for @vegetablesAndFruits.
  ///
  /// In tr, this message translates to:
  /// **'Sebze & meyve'**
  String get vegetablesAndFruits;

  /// No description provided for @vegetablesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Renkli tabaklar daha fazla vitamin ve lif sağlar.'**
  String get vegetablesDescription;

  /// No description provided for @whoPhysicalActivityUpdate.
  ///
  /// In tr, this message translates to:
  /// **'DSÖ: Fiziksel aktivite rehberi güncellendi'**
  String get whoPhysicalActivityUpdate;

  /// No description provided for @smartWatchSleep.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı saatlerle uyku takibi: Nelere dikkat etmeli?'**
  String get smartWatchSleep;

  /// No description provided for @omega3HeartHealth.
  ///
  /// In tr, this message translates to:
  /// **'Omega-3 ve kalp sağlığı üzerine yeni meta-analiz'**
  String get omega3HeartHealth;

  /// No description provided for @currentHealthSource.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Sağlık'**
  String get currentHealthSource;

  /// No description provided for @techHealthSource.
  ///
  /// In tr, this message translates to:
  /// **'Tekno Sağlık'**
  String get techHealthSource;

  /// No description provided for @medicalWorldSource.
  ///
  /// In tr, this message translates to:
  /// **'Tıp Dünyası'**
  String get medicalWorldSource;

  /// No description provided for @readingTime.
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dk'**
  String readingTime(int minutes);

  /// No description provided for @historyInfoMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu listede temizledikten sonra kalan kayıtlar görünür. Tüm geçmiş için sağ üstten \"Tüm geçmişi gör\"e gidin.'**
  String get historyInfoMessage;

  /// No description provided for @historyCleared.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş temizlendi. Veriler saklanmaya devam ediyor.'**
  String get historyCleared;

  /// No description provided for @noHistoryYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir geçmiş kaydı yok'**
  String get noHistoryYet;

  /// No description provided for @historyDataKeptMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu ekran temizlendiğinde veriler veritabanında tutulmaya devam eder.'**
  String get historyDataKeptMessage;

  /// No description provided for @cannotLoadHistory.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş bilgisi alınamadı'**
  String get cannotLoadHistory;

  /// No description provided for @historyLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş yüklenemedi'**
  String get historyLoadFailed;

  /// No description provided for @splashMessage1.
  ///
  /// In tr, this message translates to:
  /// **'İlaçlarını zamanında al, sağlığını koru.'**
  String get splashMessage1;

  /// No description provided for @splashMessage2.
  ///
  /// In tr, this message translates to:
  /// **'Sağlığın için buradayız.'**
  String get splashMessage2;

  /// No description provided for @splashMessage3.
  ///
  /// In tr, this message translates to:
  /// **'İlacını unutma, hayatını kolaylaştır.'**
  String get splashMessage3;

  /// No description provided for @splashMessage4.
  ///
  /// In tr, this message translates to:
  /// **'Sağlıklı bir yaşam,\nzamanında alınan ilaçla başlar.'**
  String get splashMessage4;

  /// No description provided for @splashMessage5.
  ///
  /// In tr, this message translates to:
  /// **'Her dozda sağlık, her bildirimde huzur.'**
  String get splashMessage5;

  /// No description provided for @didYouTakeMedicine.
  ///
  /// In tr, this message translates to:
  /// **'İlaç aldınız mı?'**
  String get didYouTakeMedicine;

  /// No description provided for @tookMyMedicine.
  ///
  /// In tr, this message translates to:
  /// **'İlacımı Aldım'**
  String get tookMyMedicine;

  /// No description provided for @snooze30Min.
  ///
  /// In tr, this message translates to:
  /// **'Ertele (30 dk)'**
  String get snooze30Min;

  /// No description provided for @ignoreMarkTaken.
  ///
  /// In tr, this message translates to:
  /// **'Yoksay (Aldı say)'**
  String get ignoreMarkTaken;

  /// No description provided for @snoozeIgnoreExplanation.
  ///
  /// In tr, this message translates to:
  /// **'Ertele seçeneği 30 dakika sonra sizi tekrar uyarır. Yoksay seçeneği alınmış olarak işaretler.'**
  String get snoozeIgnoreExplanation;

  /// No description provided for @connectionTimeout.
  ///
  /// In tr, this message translates to:
  /// **'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.'**
  String get connectionTimeout;

  /// No description provided for @checkInternetConnection.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantınızı kontrol edin'**
  String get checkInternetConnection;

  /// No description provided for @generalError.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get generalError;

  /// No description provided for @snoozeOperationFailed.
  ///
  /// In tr, this message translates to:
  /// **'Erteleme işlemi başarısız'**
  String get snoozeOperationFailed;

  /// No description provided for @okay.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get okay;

  /// No description provided for @processing.
  ///
  /// In tr, this message translates to:
  /// **'İşleniyor...'**
  String get processing;

  /// No description provided for @notScheduled.
  ///
  /// In tr, this message translates to:
  /// **'Planlanmadı'**
  String get notScheduled;

  /// No description provided for @now.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi'**
  String get now;

  /// No description provided for @nextAlarm.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki alarm'**
  String get nextAlarm;

  /// No description provided for @days.
  ///
  /// In tr, this message translates to:
  /// **'g'**
  String get days;

  /// No description provided for @minutes.
  ///
  /// In tr, this message translates to:
  /// **'dk'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In tr, this message translates to:
  /// **'sn'**
  String get seconds;

  /// No description provided for @everyXHours.
  ///
  /// In tr, this message translates to:
  /// **'{hours} saatte bir'**
  String everyXHours(int hours);

  /// No description provided for @noAlarmsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz alarm yok. Hemen bir ilaç ekleyin!'**
  String get noAlarmsYet;

  /// No description provided for @allHistoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Geçmiş'**
  String get allHistoryTitle;

  /// No description provided for @historyNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş bulunamadı'**
  String get historyNotFound;
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
      <String>['ar', 'en', 'ru', 'tr'].contains(locale.languageCode);

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
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
