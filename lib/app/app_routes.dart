import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/fortresses/fortresses_screen.dart';
import '../screens/fortresses/daily_recitation_fortress.dart';
import '../screens/fortresses/preparation/preparation_fortress.dart';
import '../screens/fortresses/preparation/weekly_preparation.dart';
import '../screens/fortresses/preparation/nightly_preparation.dart';
import '../screens/fortresses/preparation/pre_session_preparation.dart';
import '../screens/fortresses/memorization_fortress.dart';
import '../screens/fortresses/near_review_fortress.dart';
import '../screens/fortresses/far_review_fortress.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/feedback/feedback_screen.dart';
import '../screens/profile/profile_screen.dart';

/// إدارة مسارات التطبيق
class AppRoutes {
  // مسارات المصادقة
  static const String login = '/login';
  static const String signup = '/signup';

  // المسارات الرئيسية
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // مسارات الحصون
  static const String fortresses = '/fortresses';
  static const String dailyRecitation = '/daily-recitation';
  
  // مسارات التحضير
  static const String preparation = '/preparation';
  static const String weeklyPreparation = '/weekly-preparation';
  static const String nightlyPreparation = '/nightly-preparation';
  static const String preSessionPreparation = '/pre-session-preparation';
  
  // مسارات الحفظ والمراجعة
  static const String memorization = '/memorization';
  static const String nearReview = '/near-review';
  static const String farReview = '/far-review';

  // مسارات إضافية
  static const String progress = '/progress';
  static const String feedback = '/feedback';
  static const String profile = '/profile';

  /// توليد المسارات
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case fortresses:
        return MaterialPageRoute(builder: (_) => const FortressesScreen());
      
      case dailyRecitation:
        return MaterialPageRoute(builder: (_) => const DailyRecitationFortress());

      case preparation:
        return MaterialPageRoute(builder: (_) => const PreparationFortress());
      
      case weeklyPreparation:
        return MaterialPageRoute(builder: (_) => const WeeklyPreparation());
      
      case nightlyPreparation:
        return MaterialPageRoute(builder: (_) => const NightlyPreparation());
      
      case preSessionPreparation:
        return MaterialPageRoute(builder: (_) => const PreSessionPreparation());

      case memorization:
        return MaterialPageRoute(builder: (_) => const MemorizationFortress());
      
      case nearReview:
        return MaterialPageRoute(builder: (_) => const NearReviewFortress());
      
      case farReview:
        return MaterialPageRoute(builder: (_) => const FarReviewFortress());

      case progress:
        return MaterialPageRoute(builder: (_) => const ProgressScreen());
      
      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackScreen());
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('الصفحة غير موجودة: ${settings.name}'),
            ),
          ),
        );
    }
  }
}