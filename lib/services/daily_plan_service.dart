import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/daily_plan_model.dart';

/// خدمة لقراءة وإدارة الخطة اليومية من ملف JSON
class DailyPlanService {
  List<DailyPlan>? _cachedPlans;

  /// قراءة الخطة اليومية من الملف
  Future<List<DailyPlan>> loadDailyPlan() async {
    // إذا كانت البيانات محملة مسبقاً، إرجاعها مباشرة
    if (_cachedPlans != null) {
      return _cachedPlans!;
    }

    try {
      // قراءة الملف من assets
      final String jsonString = await rootBundle.loadString(
        'lib/backend/config/daily_plan.json',
      );
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> weeksJson = jsonData['weeks'];
      
      _cachedPlans = weeksJson
          .map((week) => DailyPlan.fromJson(week))
          .toList();
      
      return _cachedPlans!;
    } catch (e) {
      print('خطأ في قراءة الخطة اليومية: $e');
      return [];
    }
  }

  /// الحصول على خطة يوم محدد بالتاريخ
  Future<DayPlan?> getPlanByDate(String date) async {
    final plans = await loadDailyPlan();
    
    try {
      // البحث في جميع الأسابيع عن اليوم المطلوب
      for (final plan in plans) {
        for (final day in plan.days) {
          if (day.dayName == date) {
            return day;
          }
        }
      }
      return null;
    } catch (e) {
      print('لم يتم العثور على خطة لتاريخ: $date');
      return null;
    }
  }

  /// الحصول على خطة اليوم الحالي
  Future<DayPlan?> getTodayPlan() async {
    final now = DateTime.now();
    final today = now.day;
    
    final plans = await loadDailyPlan();
    
    try {
      // البحث في جميع الأسابيع عن اليوم الحالي
      for (final plan in plans) {
        for (final day in plan.days) {
          if (day.dayNumber == today) {
            return day;
          }
        }
      }
      return null;
    } catch (e) {
      print('لم يتم العثور على خطة لليوم الحالي');
      return null;
    }
  }

  /// الحصول على جميع المهام المتاحة
  Future<List<DailyPlan>> getAllPlans() async {
    return await loadDailyPlan();
  }

  /// التحقق من وجود مهام لليوم
  Future<bool> hasTodayTasks() async {
    final todayPlan = await getTodayPlan();
    
    if (todayPlan == null) return false;
    
    return todayPlan.memorization['pages'] != 'لا يوجد' ||
           todayPlan.nearReview['pages'] != 'لا يوجد' ||
           todayPlan.farReview['pages'] != 'لا يوجد' ||
           todayPlan.preparation['weekly'] != 'لا يوجد' ||
           todayPlan.preparation['nightly'] != 'لا يوجد' ||
           todayPlan.preparation['before'] != 'لا يوجد';
  }

  /// الحصول على اسم الشهر بالعربية
  String _getMonthName(int month) {
    const months = {
      1: 'يناير',
      2: 'فبراير',
      3: 'مارس',
      4: 'أبريل',
      5: 'مايو',
      6: 'يونيو',
      7: 'يوليو',
      8: 'أغسطس',
      9: 'سبتمبر',
      10: 'أكتوبر',
      11: 'نوفمبر',
      12: 'ديسمبر',
    };
    return months[month] ?? '';
  }

  /// مسح الكاش (للتحديث)
  void clearCache() {
    _cachedPlans = null;
  }
}