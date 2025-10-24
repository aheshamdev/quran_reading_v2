/// نموذج الخطة اليومية الكاملة
class DailyPlan {
  final int weekNumber;
  final String period;
  final List<DayPlan> days;

  DailyPlan({
    required this.weekNumber,
    required this.period,
    required this.days,
  });

  /// تحويل من JSON إلى DailyPlan
  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    return DailyPlan(
      weekNumber: json['week_number'] ?? 1,
      period: json['period'] ?? '',
      days: (json['days'] as List?)
              ?.map((day) => DayPlan.fromJson(day as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'week_number': weekNumber,
      'period': period,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }
}

/// نموذج خطة يوم واحد
class DayPlan {
  final int dayNumber;
  final String dayName;
  final Map<String, dynamic> dailyRecitation;
  final String reading;
  final Map<String, dynamic> preparation;
  final Map<String, dynamic> memorization;
  final Map<String, dynamic> nearReview;
  final Map<String, dynamic> farReview;

  DayPlan({
    required this.dayNumber,
    required this.dayName,
    required this.dailyRecitation,
    required this.reading,
    required this.preparation,
    required this.memorization,
    required this.nearReview,
    required this.farReview,
  });

  /// تحويل من JSON إلى DayPlan
  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      dayNumber: json['day_number'] ?? 0,
      dayName: json['day_name'] ?? '',
      dailyRecitation: json['daily_recitation'] ?? {},
      reading: json['reading'] ?? 'لا يوجد',
      preparation: json['preparation'] ?? {
        'weekly': 'لا يوجد',
        'nightly': 'لا يوجد',
        'pre_session': 'لا يوجد',
      },
      memorization: json['memorization'] ?? {'task': 'لا يوجد'},
      nearReview: json['near_review'] ?? {'task': 'لا يوجد'},
      farReview: json['far_review'] ?? {'task': 'لا يوجد'},
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'day_number': dayNumber,
      'day_name': dayName,
      'daily_recitation': dailyRecitation,
      'reading': reading,
      'preparation': preparation,
      'memorization': memorization,
      'near_review': nearReview,
      'far_review': farReview,
    };
  }

  // Helper Getters لسهولة الوصول للبيانات

  /// الحصول على معلومات السماع من الورد اليومي
  String get listening => dailyRecitation['listening'] ?? 'لا يوجد';

  /// التحقق من وجود مهمة حفظ
  bool get hasMemorizationTask => memorization['task'] != 'لا يوجد';

  /// التحقق من وجود مهمة مراجعة قريبة
  bool get hasNearReviewTask => nearReview['task'] != 'لا يوجد';

  /// التحقق من وجود مهمة مراجعة بعيدة
  bool get hasFarReviewTask => farReview['task'] != 'لا يوجد';

  /// التحقق من وجود تحضير أسبوعي
  bool get hasWeeklyPreparation => preparation['weekly'] != 'لا يوجد';

  /// التحقق من وجود تحضير ليلي
  bool get hasNightlyPreparation => preparation['nightly'] != 'لا يوجد';

  /// التحقق من وجود تحضير قبلي
  bool get hasPreSessionPreparation => preparation['pre_session'] != 'لا يوجد';

  @override
  String toString() {
    return 'DayPlan(dayNumber: $dayNumber, dayName: $dayName)';
  }
}