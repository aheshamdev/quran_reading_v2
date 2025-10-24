/// نموذج بيانات التقدم للمستخدم
class Progress {
  final int points;
  final int streak;
  final int lessonsCompleted;
  final DateTime lastActivityDate;

  Progress({
    required this.points,
    required this.streak,
    required this.lessonsCompleted,
    required this.lastActivityDate,
  });

  /// تحويل من JSON إلى Progress
  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      points: json['points'] ?? 0,
      streak: json['streak'] ?? 0,
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'])
          : DateTime.now(),
    );
  }

  /// تحويل من Progress إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'streak': streak,
      'lessonsCompleted': lessonsCompleted,
      'lastActivityDate': lastActivityDate.toIso8601String(),
    };
  }

  /// إنشاء نسخة معدلة من Progress
  Progress copyWith({
    int? points,
    int? streak,
    int? lessonsCompleted,
    DateTime? lastActivityDate,
  }) {
    return Progress(
      points: points ?? this.points,
      streak: streak ?? this.streak,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  @override
  String toString() {
    return 'Progress(points: $points, streak: $streak, lessonsCompleted: $lessonsCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Progress &&
        other.points == points &&
        other.streak == streak &&
        other.lessonsCompleted == lessonsCompleted;
  }

  @override
  int get hashCode {
    return points.hashCode ^
        streak.hashCode ^
        lessonsCompleted.hashCode ^
        lastActivityDate.hashCode;
  }

  get longestStreak => null;
}

/// نموذج بيانات التقدم المتقدم للمستخدم (للاستخدام مع Firebase)
class ProgressModel {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final int totalPoints;
  final int completedLessons;
  final Map<String, bool> lessonsCompleted;
  final DateTime lastActivityDate;

  ProgressModel({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
    required this.completedLessons,
    required this.lessonsCompleted,
    required this.lastActivityDate,
  });

  /// تحويل من JSON إلى ProgressModel
  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      userId: json['userId'] ?? '',
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      lessonsCompleted: Map<String, bool>.from(json['lessonsCompleted'] ?? {}),
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'])
          : DateTime.now(),
    );
  }

  /// تحويل من ProgressModel إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalPoints': totalPoints,
      'completedLessons': completedLessons,
      'lessonsCompleted': lessonsCompleted,
      'lastActivityDate': lastActivityDate.toIso8601String(),
    };
  }

  /// إنشاء نسخة معدلة من ProgressModel
  ProgressModel copyWith({
    String? userId,
    int? currentStreak,
    int? longestStreak,
    int? totalPoints,
    int? completedLessons,
    Map<String, bool>? lessonsCompleted,
    DateTime? lastActivityDate,
  }) {
    return ProgressModel(
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalPoints: totalPoints ?? this.totalPoints,
      completedLessons: completedLessons ?? this.completedLessons,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  /// تحويل ProgressModel إلى Progress
  Progress toProgress() {
    return Progress(
      points: totalPoints,
      streak: currentStreak,
      lessonsCompleted: completedLessons,
      lastActivityDate: lastActivityDate,
    );
  }

  @override
  String toString() {
    return 'ProgressModel(userId: $userId, currentStreak: $currentStreak, totalPoints: $totalPoints)';
  }
}
