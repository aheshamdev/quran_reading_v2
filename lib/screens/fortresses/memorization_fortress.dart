import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../providers/fortress_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/audio_service.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

/// شاشة حصن الحفظ
class MemorizationFortress extends StatefulWidget {
  const MemorizationFortress({Key? key}) : super(key: key);

  @override
  State<MemorizationFortress> createState() => _MemorizationFortressState();
}

class _MemorizationFortressState extends State<MemorizationFortress> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();
  
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String? _currentTask;
  Map<String, dynamic>? _analysisResult;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  void _loadTask() {
    final fortressProvider = context.read<FortressProvider>();
    setState(() {
      _currentTask = fortressProvider.getMemorizationTask();
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final audioPath = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _isAnalyzing = true;
      });

      if (audioPath != null) {
        await _analyzeAudio(audioPath);
      }
    } else {
      try {
        await _audioService.startRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في بدء التسجيل: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _analyzeAudio(String audioPath) async {
    try {
      final result = await _apiService.analyzeAudio(
        audioPath: audioPath,
        mode: 'memorization_check',
        expectedText: _currentTask,
      );

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });

      // إذا كانت النسبة ممتازة، نضيف النقاط ونسجل الإنجاز
      if (result['analysis']['accuracy'] >= 80.0) {
        final userProvider = context.read<UserProvider>();
        final progressProvider = context.read<ProgressProvider>();
        
        if (userProvider.currentUser != null) {
          await progressProvider.addPoints(
            userProvider.currentUser!.uid,
            20, // 20 نقطة للحفظ
          );
          
          // تسجيل الدرس كمكتمل
          await progressProvider.completeLesson(
            userProvider.currentUser!.uid,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في التحليل: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حصن الحفظ'),
        backgroundColor: Colors.purple[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة المهمة
            Card(
              elevation: 4,
              color: Colors.purple[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.book,
                      size: 70,
                      color: Colors.purple[700],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'مهمة الحفظ اليوم',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentTask ?? 'لا توجد مهمة حفظ اليوم',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // تعليمات الحفظ
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'نصائح للحفظ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('اقرأ المقطع عدة مرات قبل التسجيل'),
                    _buildTip('احفظ بالتجويد الصحيح'),
                    _buildTip('تأكد من الحفظ قبل التسجيل'),
                    _buildTip('النسبة المطلوبة 80% فأكثر'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // زر التسجيل
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isAnalyzing ? null : _toggleRecording,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: _isRecording 
                            ? AppTheme.errorRed 
                            : Colors.purple[700],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording 
                                ? AppTheme.errorRed 
                                : Colors.purple[700]!).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 70,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isRecording 
                        ? 'جاري التسجيل...' 
                        : _isAnalyzing 
                            ? 'جاري فحص الحفظ...' 
                            : 'اضغط لبدء الحفظ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _isRecording ? AppTheme.errorRed : Colors.purple[700],
                    ),
                  ),
                ],
              ),
            ),
            
            if (_isAnalyzing)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            
            const SizedBox(height: 32),
            
            // عرض النتيجة
            if (_analysisResult != null) _buildAnalysisResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    final analysis = _analysisResult!['analysis'];
    final accuracy = analysis['accuracy'] as double;
    final correctCount = analysis['correct_count'] as int;
    final totalWords = analysis['total_words'] as int;
    final isPassed = accuracy >= 80.0;

    return Card(
      elevation: 6,
      color: isPassed ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              isPassed ? Icons.celebration : Icons.refresh,
              size: 80,
              color: isPassed ? AppTheme.correctGreen : Colors.orange[700],
            ),
            const SizedBox(height: 20),
            Text(
              isPassed ? 'ممتاز! لقد أتممت الحفظ' : 'يحتاج إلى تحسين',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isPassed ? AppTheme.correctGreen : Colors.orange[900],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${accuracy.toInt()}%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? AppTheme.correctGreen : Colors.orange[700],
                    ),
                  ),
                  const Text(
                    'نسبة الدقة',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'الكلمات الصحيحة: $correctCount من $totalWords',
              style: const TextStyle(fontSize: 18),
            ),
            if (_analysisResult!['feedback'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _analysisResult!['feedback']['message'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            CustomButton(
              text: isPassed ? 'العودة للرئيسية' : 'إعادة المحاولة',
              onPressed: () {
                if (isPassed) {
                  Navigator.pop(context);
                } else {
                  setState(() {
                    _analysisResult = null;
                  });
                }
              },
              icon: isPassed ? Icons.home : Icons.refresh,
              backgroundColor: isPassed ? AppTheme.correctGreen : Colors.orange[700],
            ),
          ],
        ),
      ),
    );
  }
}