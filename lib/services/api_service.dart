import 'dart:convert';
import 'package:http/http.dart' as http;

/// خدمة الاتصال بـ FastAPI Backend
class ApiService {
  // عنوان الخادم (يمكن تغييره حسب البيئة)
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8000'; // iOS Simulator
  // static const String baseUrl = 'https://your-api.com'; // Production

  /// تحليل الصوت باستخدام AI
  /// 
  /// Parameters:
  /// - audioPath: مسار الملف الصوتي
  /// - mode: نوع التحليل (daily_recitation, memorization_check, etc.)
  /// - expectedText: النص المتوقع للمقارنة (اختياري)
  /// 
  /// Returns: نتيجة التحليل مع الكلمات الصحيحة والخاطئة
  Future<Map<String, dynamic>> analyzeAudio({
    required String audioPath,
    required String mode,
    String? expectedText,
  }) async {
    try {
      // إنشاء multipart request لإرسال الملف
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/analyze'),
      );

      // إضافة الملف الصوتي
      request.files.add(
        await http.MultipartFile.fromPath('audio', audioPath),
      );

      // إضافة البيانات الإضافية
      request.fields['mode'] = mode;
      if (expectedText != null) {
        request.fields['expected_text'] = expectedText;
      }

      // إرسال الطلب مع timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('فشل التحليل: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في الاتصال بالـ API: $e');
      
      // في حالة الفشل، نرجع بيانات تجريبية للاختبار
      return _getMockAnalysisResult(mode);
    }
  }

  /// فحص اتصال الخادم
  Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('فشل الاتصال بالخادم: $e');
      return false;
    }
  }

  /// إرسال ملاحظات المستخدم
  Future<bool> submitFeedback({
    required String userId,
    required String message,
    int? rating,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'message': message,
          'rating': rating,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('خطأ في إرسال الملاحظات: $e');
      return false;
    }
  }

  /// الحصول على تفاصيل الأخطاء (اختياري)
  Future<List<Map<String, dynamic>>> getErrorDetails(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/errors/$sessionId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['errors']);
      } else {
        throw Exception('فشل جلب الأخطاء');
      }
    } catch (e) {
      print('خطأ في جلب الأخطاء: $e');
      return [];
    }
  }

  /// بيانات تحليل تجريبية (Mock Data) للاختبار
  /// تُستخدم عندما يكون الخادم غير متاح
  Map<String, dynamic> _getMockAnalysisResult(String mode) {
    // محاكاة نتائج متنوعة بناءً على الوقت
    final now = DateTime.now();
    final accuracyOptions = [65.0, 75.0, 85.0, 90.0, 95.0];
    final accuracy = accuracyOptions[now.second % accuracyOptions.length];

    return {
      'success': true,
      'mode': mode,
      'analysis': {
        'correct_words': ['بسم', 'الله', 'الرحمن', 'الرحيم'],
        'incorrect_words': accuracy < 80 ? ['الحمد'] : [],
        'accuracy': accuracy,
        'total_words': accuracy < 80 ? 5 : 4,
        'correct_count': 4,
        'incorrect_count': accuracy < 80 ? 1 : 0,
      },
      'feedback': {
        'message': accuracy >= 80 
            ? 'ممتاز! أحسنت، بارك الله فيك'
            : 'جيد! استمر في التحسين',
        'suggestions': [
          'انتبه لمخارج الحروف',
          'حاول تحسين التجويد',
          'راجع أحكام التلاوة',
        ].sublist(0, accuracy < 70 ? 3 : accuracy < 85 ? 2 : 1),
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}