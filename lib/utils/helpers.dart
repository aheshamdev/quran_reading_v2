import 'package:flutter/material.dart';
import 'constants.dart';
import 'dart:math';

/// دوال مساعدة عامة للتطبيق
class Helpers {
  /// تنسيق التاريخ بالعربية
  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = AppConstants.monthNames[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  /// الحصول على اسم اليوم بالعربية
  static String getWeekDayName(DateTime date) {
    final weekday = (date.weekday + 1) % 7;
    return AppConstants.weekDays[weekday];
  }

  /// التحقق من صلاحية البريد الإلكتروني
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// التحقق من قوة كلمة المرور
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (password.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  /// الحصول على رسالة نجاح عشوائية
  static String getRandomSuccessMessage() {
    final random = Random();
    return AppConstants
        .successMessages[random.nextInt(AppConstants.successMessages.length)];
  }

  /// الحصول على رسالة تشجيع عشوائية
  static String getRandomEncouragementMessage() {
    final random = Random();
    return AppConstants.encouragementMessages[
        random.nextInt(AppConstants.encouragementMessages.length)];
  }

  /// تنسيق الوقت (مثل: منذ ساعتين)
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  /// تحويل الثواني إلى تنسيق MM:SS
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// حساب نسبة الإنجاز
  static double calculateProgress(int completed, int total) {
    if (total == 0) return 0.0;
    return (completed / total * 100).clamp(0.0, 100.0);
  }

  /// الحصول على لون حسب النسبة
  static Color getProgressColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// تحويل رقم الصفحة إلى نص بالعربية
  static String formatPageRange(String pageRange) {
    if (pageRange == 'لا يوجد') return pageRange;

    if (pageRange.contains('الي')) {
      return pageRange;
    }

    return 'صفحة $pageRange';
  }

  /// عرض رسالة Toast
  static void showToast(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// عرض مربع حوار تأكيد
  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// عرض شاشة تحميل
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// إخفاء شاشة التحميل
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// حساب المستوى بناءً على النقاط
  static int calculateLevel(int points) {
    if (points < 100) return 1;
    if (points < 300) return 2;
    if (points < 600) return 3;
    if (points < 1000) return 4;
    return 5;
  }

  /// الحصول على اسم المستوى
  static String getLevelName(int level) {
    const levels = [
      'مبتدئ',
      'متعلم',
      'متقدم',
      'محترف',
      'خبير',
    ];
    return level <= levels.length ? levels[level - 1] : 'أسطورة';
  }

  /// حساب النقاط المطلوبة للمستوى التالي
  static int getPointsForNextLevel(int currentLevel) {
    const thresholds = [100, 300, 600, 1000, 1500];
    return currentLevel < thresholds.length
        ? thresholds[currentLevel]
        : thresholds.last + (currentLevel - thresholds.length + 1) * 500;
  }

  /// تحويل الأرقام الإنجليزية إلى عربية
  static String convertToArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  /// التحقق من أن اليوم هو نفس اليوم
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// الحصول على بداية اليوم
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// الحصول على نهاية اليوم
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
}
