/// ثوابت التطبيق
class AppConstants {
  // معلومات التطبيق
  static const String appName = 'تطبيق تصحيح التلاوة';
  static const String appVersion = '1.0.0';
  
  // أنواع التحليل
  static const String dailyRecitationMode = 'daily_recitation';
  static const String memorizationCheckMode = 'memorization_check';
  static const String weeklyPreparationMode = 'weekly_preparation';
  static const String nightlyPreparationMode = 'nightly_preparation';
  static const String preSessionPreparationMode = 'pre_session_preparation';
  
  // النقاط
  static const int dailyRecitationPoints = 15;
  static const int memorizationPoints = 20;
  static const int nearReviewPoints = 15;
  static const int farReviewPoints = 12;
  static const int weeklyPreparationPoints = 10;
  static const int nightlyPreparationPoints = 8;
  static const int preSessionPreparationPoints = 6;
  
  // الحد الأدنى للنجاح
  static const double memorizationPassThreshold = 80.0;
  static const double reviewPassThreshold = 75.0;
  static const double preparationPassThreshold = 70.0;
  
  // الأحزاب
  static const List<String> hizbs = [
    'الحزب الأول',
    'الحزب الثاني',
    'الحزب الثالث',
    'الحزب الرابع',
    'الحزب الخامس',
  ];
  
  // أرباع الأحزاب
  static const List<String> hizbQuarters = [
    'حزب ربع الأول',
    'حزب ربع الثاني',
    'حزب ربع الثالث',
    'حزب ربع الرابع',
    'حزب ربع الخامس',
  ];
  
  // أيام الأسبوع بالعربية
  static const List<String> weekDays = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];
  
  // الأشهر بالعربية
  static const List<String> monthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  
  // رسائل النجاح
  static const List<String> successMessages = [
    'ممتاز! أحسنت',
    'بارك الله فيك',
    'واصل التميز',
    'جزاك الله خيراً',
    'أداء رائع',
  ];
  
  // رسائل التشجيع
  static const List<String> encouragementMessages = [
    'استمر في المحاولة',
    'لا تستسلم',
    'أنت على الطريق الصحيح',
    'حاول مرة أخرى',
    'يمكنك أن تفعل ذلك',
  ];
  
  // مفاتيح التخزين المحلي
  static const String userIdKey = 'user_id';
  static const String lastLoginKey = 'last_login';
  static const String themeKey = 'theme_mode';
  static const String notificationsKey = 'notifications_enabled';
  
  // الإعدادات الافتراضية
  static const bool defaultNotificationsEnabled = true;
  static const int defaultReminderHour = 20; // 8 مساءً
  
  // حدود التسجيل
  static const int maxRecordingSeconds = 300; // 5 دقائق
  static const int minRecordingSeconds = 3; // 3 ثواني
  
  // API
  static const int apiTimeout = 30; // ثواني
  static const int maxRetries = 3;
  
  // الإنجازات
  static const Map<String, int> achievementThresholds = {
    'first_lesson': 1,
    'week_streak': 7,
    'month_lessons': 30,
    'points_500': 500,
    'points_1000': 1000,
  };
}