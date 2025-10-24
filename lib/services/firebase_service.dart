import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../models/progress_model.dart';

/// خدمة Firebase للتعامل مع المصادقة وقاعدة البيانات
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // ============ المصادقة (Authentication) ============

  /// تسجيل دخول المستخدم
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        return UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email!,
          displayName: credential.user!.displayName,
          createdAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('خطأ في تسجيل الدخول: $e');
      rethrow;
    }
  }

  /// إنشاء حساب جديد
  Future<UserModel?> signUp(String email, String password, String displayName) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // تحديث اسم المستخدم
        await credential.user!.updateDisplayName(displayName);
        
        final user = UserModel(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );

        // إنشاء سجل التقدم الأولي
        await _createInitialProgress(user.uid);
        
        return user;
      }
      return null;
    } catch (e) {
      print('خطأ في إنشاء الحساب: $e');
      rethrow;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// الحصول على المستخدم الحالي
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ============ قاعدة البيانات (Database) ============

  /// إنشاء سجل تقدم أولي للمستخدم الجديد
  Future<void> _createInitialProgress(String userId) async {
    final progress = ProgressModel(
      userId: userId,
      currentStreak: 0,
      longestStreak: 0,
      totalPoints: 0,
      completedLessons: 0,
      lessonsCompleted: {},
      lastActivityDate: DateTime.now(),
    );

    await _database.child('users/$userId/progress').set(progress.toJson());
  }

  /// جلب بيانات التقدم للمستخدم
  Future<ProgressModel?> getProgress(String userId) async {
    try {
      final snapshot = await _database.child('users/$userId/progress').get();
      
      if (snapshot.exists) {
        return ProgressModel.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map)
        );
      }
      return null;
    } catch (e) {
      print('خطأ في جلب التقدم: $e');
      return null;
    }
  }

  /// تحديث بيانات التقدم
  Future<void> updateProgress(ProgressModel progress) async {
    try {
      await _database
          .child('users/${progress.userId}/progress')
          .update(progress.toJson());
    } catch (e) {
      print('خطأ في تحديث التقدم: $e');
      rethrow;
    }
  }

  /// تسجيل درس مكتمل
  Future<void> markLessonCompleted(String userId, String lessonDate) async {
    try {
      await _database
          .child('users/$userId/progress/lessonsCompleted/$lessonDate')
          .set(true);
      
      // تحديث عدد الدروس المكتملة
      final progress = await getProgress(userId);
      if (progress != null) {
        await updateProgress(
          progress.copyWith(
            completedLessons: progress.completedLessons + 1,
            lastActivityDate: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      print('خطأ في تسجيل الدرس: $e');
      rethrow;
    }
  }

  /// تحديث سلسلة الأيام (Streak)
  Future<void> updateStreak(String userId) async {
    try {
      final progress = await getProgress(userId);
      if (progress != null) {
        final now = DateTime.now();
        final lastActivity = progress.lastActivityDate;
        final daysDifference = now.difference(lastActivity).inDays;

        int newStreak = progress.currentStreak;
        
        // إذا كان آخر نشاط أمس، زيادة السلسلة
        if (daysDifference == 1) {
          newStreak += 1;
        }
        // إذا مر أكثر من يوم، إعادة تعيين السلسلة
        else if (daysDifference > 1) {
          newStreak = 1;
        }

        final longestStreak = newStreak > progress.longestStreak 
            ? newStreak 
            : progress.longestStreak;

        await updateProgress(
          progress.copyWith(
            currentStreak: newStreak,
            longestStreak: longestStreak,
            lastActivityDate: now,
          ),
        );
      }
    } catch (e) {
      print('خطأ في تحديث السلسلة: $e');
      rethrow;
    }
  }

  /// إضافة نقاط للمستخدم
  Future<void> addPoints(String userId, int points) async {
    try {
      final progress = await getProgress(userId);
      if (progress != null) {
        await updateProgress(
          progress.copyWith(
            totalPoints: progress.totalPoints + points,
          ),
        );
      }
    } catch (e) {
      print('خطأ في إضافة النقاط: $e');
      rethrow;
    }
  }
}