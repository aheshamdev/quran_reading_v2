import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../providers/fortress_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/audio_service.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

/// شاشة مراجعة البعيد
class FarReviewFortress extends StatefulWidget {
  const FarReviewFortress({Key? key}) : super(key: key);

  @override
  State<FarReviewFortress> createState() => _FarReviewFortressState();
}

class _FarReviewFortressState extends State<FarReviewFortress> {
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
      _currentTask = fortressProvider.getFarReviewTask();
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

      if (result['analysis']['accuracy'] >= 75.0) {
        final userProvider = context.read<UserProvider>();
        final progressProvider = context.read<ProgressProvider>();
        
        if (userProvider.currentUser != null) {
          await progressProvider.addPoints(
            userProvider.currentUser!.uid,
            12, // 12 نقطة لمراجعة البعيد
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
        title: const Text('مراجعة البعيد'),
        backgroundColor: Colors.teal[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.teal[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 70,
                      color: Colors.teal[700],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'مراجعة البعيد',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'مراجعة ما تم حفظه منذ فترة',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentTask ?? 'لا توجد مراجعة اليوم',
                        style: const TextStyle(
                          fontSize: 24,
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
            
            // أهمية مراجعة البعيد
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.teal[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'أهمية المراجعة البعيدة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem('تثبت الحفظ في الذاكرة طويلة المدى'),
                    _buildInfoItem('تمنع النسيان'),
                    _buildInfoItem('تقوي الصلة بكتاب الله'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: GestureDetector(
                onTap: _isAnalyzing ? null : _toggleRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: _isRecording 
                        ? AppTheme.errorRed 
                        : Colors.teal[700],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording 
                            ? AppTheme.errorRed 
                            : Colors.teal[700]!).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 65,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Center(
              child: Text(
                _isRecording 
                    ? 'جاري التسجيل...' 
                    : _isAnalyzing 
                        ? 'جاري المراجعة...' 
                        : 'اضغط لبدء المراجعة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _isRecording ? AppTheme.errorRed : Colors.teal[700],
                ),
              ),
            ),
            
            if (_isAnalyzing)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            
            const SizedBox(height: 32),
            
            if (_analysisResult != null) _buildAnalysisResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.teal[600], size: 20),
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
    final isPassed = accuracy >= 75.0;

    return Card(
      elevation: 6,
      color: isPassed ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isPassed ? Icons.check_circle : Icons.refresh,
              size: 60,
              color: isPassed ? AppTheme.correctGreen : Colors.orange[700],
            ),
            const SizedBox(height: 16),
            Text(
              isPassed ? 'ممتاز!' : 'يحتاج إلى تحسين',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isPassed ? AppTheme.correctGreen : Colors.orange[900],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'نسبة الدقة: ${accuracy.toInt()}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: isPassed ? 'تم بنجاح' : 'إعادة المحاولة',
              onPressed: () {
                if (isPassed) {
                  Navigator.pop(context);
                } else {
                  setState(() {
                    _analysisResult = null;
                  });
                }
              },
              icon: isPassed ? Icons.check : Icons.refresh,
              backgroundColor: isPassed ? AppTheme.correctGreen : Colors.orange[700],
            ),
          ],
        ),
      ),
    );
  }
}