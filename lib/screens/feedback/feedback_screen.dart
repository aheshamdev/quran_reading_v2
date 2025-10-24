import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

/// شاشة الملاحظات والتقييم
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار التقييم'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final userProvider = context.read<UserProvider>();
    
    try {
      final success = await _apiService.submitFeedback(
        userId: userProvider.currentUser?.uid ?? '',
        message: _messageController.text,
        rating: _selectedRating,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال ملاحظاتك بنجاح'),
            backgroundColor: AppTheme.correctGreen,
          ),
        );
        _messageController.clear();
        setState(() {
          _selectedRating = 0;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل إرسال الملاحظات'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملاحظات والتقييم'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // رسالة ترحيبية
              Card(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.feedback_outlined,
                        size: 60,
                        color: AppTheme.primaryGreen,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'نسعد بسماع رأيك',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ساعدنا في تحسين التطبيق من خلال ملاحظاتك',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // التقييم بالنجوم
              const Text(
                'تقييمك للتطبيق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          size: 48,
                          color: AppTheme.lightGold,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // رسالة الملاحظات
              const Text(
                'ملاحظاتك ومقترحاتك',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'اكتب ملاحظاتك هنا...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء كتابة ملاحظاتك';
                  }
                  if (value.length < 10) {
                    return 'الرجاء كتابة ملاحظات أكثر تفصيلاً (10 أحرف على الأقل)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // زر الإرسال
              CustomButton(
                text: 'إرسال الملاحظات',
                onPressed: _submitFeedback,
                isLoading: _isSubmitting,
                icon: Icons.send,
              ),
              
              const SizedBox(height: 24),
              
              // أمثلة على الملاحظات المفيدة
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.tips_and_updates, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'أمثلة على الملاحظات المفيدة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem('اقتراحات لتحسين واجهة المستخدم'),
                      _buildTipItem('ملاحظات حول دقة التحليل الصوتي'),
                      _buildTipItem('ميزات جديدة تود إضافتها'),
                      _buildTipItem('مشاكل تقنية واجهتك'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.blue, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}