import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/progress_model.dart';

/// Provider لإدارة تقدم المستخدم
class ProgressProvider with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  Progress? _progress;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Progress? get progress => _progress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentStreak => _progress?.streak ?? 0;
  int get totalPoints => _progress?.points ?? 0;
  int get completedLessons => _progress?.lessonsCompleted ?? 0;

  /// تحميل تقدم المستخدم من Firebase
  Future<void> loadProgress(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _database
          .child('users/$userId/progress')
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _progress = Progress.fromJson(data);
      } else {
        // إنشاء تقدم جديد إذا لم يكن موجوداً
        _progress = Progress(
          points: 0,
          streak: 0,
          lessonsCompleted: 0,
          lastActivityDate: DateTime.now(),
        );
        await updateProgress(userId, _progress!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تحميل التقدم: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث تقدم المستخدم في Firebase
  Future<void> updateProgress(String userId, Progress progress) async {
    try {
      await _database
          .child('users/$userId/progress')
          .set(progress.toJson());
      
      _progress = progress;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تحديث التقدم: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// إضافة نقاط للمستخدم
  Future<void> addPoints(String userId, int pointsToAdd) async {
    if (_progress == null) return;

    final updatedProgress = Progress(
      points: _progress!.points + pointsToAdd,
      streak: _progress!.streak,
      lessonsCompleted: _progress!.lessonsCompleted,
      lastActivityDate: DateTime.now(),
    );

    await updateProgress(userId, updatedProgress);
  }

  /// تحديث سلسلة الأيام (Streak)
  Future<void> updateStreak(String userId) async {
    if (_progress == null) return;

    final now = DateTime.now();
    final lastActivity = _progress!.lastActivityDate;
    final daysDifference = now.difference(lastActivity).inDays;

    int newStreak = _progress!.streak;

    if (daysDifference == 1) {
      // يوم متتالي - زيادة السلسلة
      newStreak += 1;
    } else if (daysDifference > 1) {
      // انقطعت السلسلة - إعادة تعيينها
      newStreak = 1;
    }
    // إذا كان نفس اليوم (daysDifference == 0)، لا تتغير السلسلة

    final updatedProgress = Progress(
      points: _progress!.points,
      streak: newStreak,
      lessonsCompleted: _progress!.lessonsCompleted,
      lastActivityDate: now,
    );

    await updateProgress(userId, updatedProgress);
  }

  /// تسجيل درس مكتمل
  Future<void> completeLesson(String userId) async {
    if (_progress == null) return;

    // تحديث السلسلة أولاً
    await updateStreak(userId);

    final updatedProgress = Progress(
      points: _progress!.points,
      streak: _progress!.streak,
      lessonsCompleted: _progress!.lessonsCompleted + 1,
      lastActivityDate: DateTime.now(),
    );

    await updateProgress(userId, updatedProgress);
  }

  /// الحصول على نسبة التقدم من هدف معين
  double getCompletionPercentage(int totalGoal) {
    if (_progress == null || totalGoal == 0) return 0.0;
    return (_progress!.lessonsCompleted / totalGoal * 100).clamp(0.0, 100.0);
  }

  /// التحقق من تحقيق هدف معين
  bool hasAchievedGoal(int goalLessons) {
    return completedLessons >= goalLessons;
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// إعادة تعيين التقدم (للاختبار أو تسجيل الخروج)
  void reset() {
    _progress = null;
    _errorMessage = null;
    notifyListeners();
  }
}