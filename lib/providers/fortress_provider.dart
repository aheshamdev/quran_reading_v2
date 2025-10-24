import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/daily_plan_model.dart';

/// Provider لإدارة الحصون والخطة اليومية
class FortressProvider with ChangeNotifier {
  DailyPlan? _dailyPlan;
  DayPlan? _todayPlan;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentFortress;

  // Getters
  DailyPlan? get dailyPlan => _dailyPlan;
  DayPlan? get todayPlan => _todayPlan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentFortress => _currentFortress;
  bool get hasTodayPlan => _todayPlan != null;

  /// تحميل الخطة اليومية من JSON
  Future<void> loadDailyPlan() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String jsonString = await rootBundle.loadString(
        'lib/backend/config/daily_plan.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _dailyPlan = DailyPlan.fromJson(jsonData);

      // تحديد خطة اليوم
      _todayPlan = _getTodayPlan();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تحميل الخطة اليومية: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// الحصول على خطة اليوم الحالي
  DayPlan? _getTodayPlan() {
    if (_dailyPlan == null) return null;

    final now = DateTime.now();
    final today = now.day;

    try {
      return _dailyPlan!.days.firstWhere(
        (day) => day.dayNumber == today,
      );
    } catch (e) {
      // إذا لم نجد اليوم، نرجع أول يوم
      return _dailyPlan!.days.isNotEmpty ? _dailyPlan!.days.first : null;
    }
  }

  /// الحصول على خطة يوم محدد
  DayPlan? getDayPlan(int dayNumber) {
    if (_dailyPlan == null) return null;

    try {
      return _dailyPlan!.days.firstWhere(
        (day) => day.dayNumber == dayNumber,
      );
    } catch (e) {
      return null;
    }
  }

  /// تحديد نوع AI حسب الحصن
  String getAiModeForFortress(String fortressType) {
    switch (fortressType) {
      case 'daily_recitation':
        return 'daily_recitation';
      case 'weekly_preparation':
        return 'weekly_preparation';
      case 'nightly_preparation':
        return 'nightly_preparation';
      case 'pre_session_preparation':
        return 'pre_session_preparation';
      case 'memorization':
        return 'memorization_check';
      case 'near_review':
        return 'memorization_check';
      case 'far_review':
        return 'memorization_check';
      default:
        return 'daily_recitation';
    }
  }

  /// تعيين الحصن الحالي
  void setCurrentFortress(String fortress) {
    _currentFortress = fortress;
    notifyListeners();
  }

  /// الحصول على بيانات التحضير الأسبوعي
  String? getWeeklyPreparation() {
    if (_todayPlan == null) return null;
    final prep = _todayPlan!.preparation['weekly'];
    return prep != 'لا يوجد' ? prep : null;
  }

  /// الحصول على بيانات التحضير الليلي
  String? getNightlyPreparation() {
    if (_todayPlan == null) return null;
    final prep = _todayPlan!.preparation['nightly'];
    return prep != 'لا يوجد' ? prep : null;
  }

  /// الحصول على بيانات التحضير القبلي
  String? getPreSessionPreparation() {
    if (_todayPlan == null) return null;
    final prep = _todayPlan!.preparation['pre_session'];
    return prep != 'لا يوجد' ? prep : null;
  }

  /// الحصول على بيانات الحفظ
  String? getMemorizationTask() {
    if (_todayPlan == null) return null;
    final task = _todayPlan!.memorization['task'];
    return task != 'لا يوجد' ? task : null;
  }

  /// الحصول على بيانات مراجعة القريب
  String? getNearReviewTask() {
    if (_todayPlan == null) return null;
    final task = _todayPlan!.nearReview['task'];
    return task != 'لا يوجد' ? task : null;
  }

  /// الحصول على بيانات مراجعة البعيد
  String? getFarReviewTask() {
    if (_todayPlan == null) return null;
    final task = _todayPlan!.farReview['task'];
    return task != 'لا يوجد' ? task : null;
  }

  /// الحصول على بيانات الورد اليومي
  Map<String, dynamic>? getDailyRecitation() {
    return _todayPlan?.dailyRecitation;
  }

  /// التحقق من وجود مهام لليوم
  bool hasTodayTasks() {
    if (_todayPlan == null) return false;

    return _todayPlan!.memorization['task'] != 'لا يوجد' ||
        _todayPlan!.nearReview['task'] != 'لا يوجد' ||
        _todayPlan!.farReview['task'] != 'لا يوجد' ||
        _todayPlan!.preparation['weekly'] != 'لا يوجد' ||
        _todayPlan!.preparation['nightly'] != 'لا يوجد' ||
        _todayPlan!.preparation['pre_session'] != 'لا يوجد';
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// إعادة تحميل البيانات
  Future<void> refresh() async {
    await loadDailyPlan();
  }
}
