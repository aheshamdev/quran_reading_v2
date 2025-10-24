import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

/// Provider لإدارة حالة المستخدم
class UserProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  /// تسجيل الدخول
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _firebaseService.signIn(email, password);
      
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'فشل تسجيل الدخول';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'خطأ: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// إنشاء حساب جديد
  Future<bool> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _firebaseService.signUp(email, password, displayName);
      
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'فشل إنشاء الحساب';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'خطأ: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.signOut();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تسجيل الخروج: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// التحقق من حالة المستخدم عند بدء التطبيق
  Future<void> checkUserStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final firebaseUser = _firebaseService.getCurrentUser();
      
      if (firebaseUser != null) {
        _currentUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          displayName: firebaseUser.displayName,
          createdAt: DateTime.now(),
        );
      } else {
        _currentUser = null;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في التحقق من المستخدم: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}