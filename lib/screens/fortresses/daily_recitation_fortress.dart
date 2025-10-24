import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../providers/fortress_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/audio_service.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

/// شاشة الورد اليومي
class DailyRecitationFortress extends StatefulWidget {
  const DailyRecitationFortress({Key? key}) : super(key: key);

  @override
  State<DailyRecitationFortress> createState() => _DailyRecitationFortressState();
}

class _DailyRecitationFortressState extends State<DailyRecitationFortress> {
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
    final dailyRecitation = fortressProvider.getDailyRecitation();
    setState(() {
      _currentTask = dailyRecitation?['listening'];
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
        mode: 'daily_recitation',
        expectedText: _currentTask,
      );

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });

      if (result['analysis']['accuracy'] >= 70.0) {
        final userProvider = context.read<UserProvider>();
        final progressProvider = context.read<ProgressProvider>();
        
        if (userProvider.currentUser != null) {
          await progressProvider.addPoints(
            userProvider.currentUser!.uid,
            15,
          );
          
          await progressProvider.updateStreak(userProvider.currentUser!.uid);
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
        title: const Text('الورد اليومي'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              color: AppTheme.primaryGreen.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.hearing,
                      size: 70,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'الورد اليومي',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'السماع والتلاوة اليومية',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryGreen,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _currentTask ?? 'لا يوجد ورد اليوم',
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
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.stars, color: AppTheme.lightGold),
                        SizedBox(width: 8),
                        Text(
                          'فضل الورد اليومي',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem('الاستمرارية في تلاوة القرآن'),
                    _buildBenefitItem('زيادة الأجر والثواب'),
                    _buildBenefitItem('الحفاظ على الارتباط بكتاب الله'),
                    _buildBenefitItem('تحقيق الاستقامة على الطاعة'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
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
                            : AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording 
                                ? AppTheme.errorRed 
                                : AppTheme.primaryGreen).withOpacity(0.5),
                            blurRadius: 25,
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
                            ? 'جاري التحليل...' 
                            : 'اضغط لبدء التلاوة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _isRecording ? AppTheme.errorRed : AppTheme.primaryGreen,
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
            
            if (_analysisResult != null) _buildAnalysisResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppTheme.correctGreen, size: 20),
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
    final isPassed = accuracy >= 70.0;

    return Card(
      elevation: 6,
      color: isPassed ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              isPassed ? Icons.check_circle_outline : Icons.info_outline,
              size: 80,
              color: isPassed ? AppTheme.correctGreen : Colors.orange[700],
            ),
            const SizedBox(height: 20),
            Text(
              isPassed ? 'بارك الله فيك!' : 'استمر في المحاولة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isPassed ? AppTheme.correctGreen : Colors.orange[900],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPassed ? AppTheme.correctGreen : Colors.orange[700]!,
                  width: 2,
                ),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_analysisResult!['feedback'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.tips_and_updates, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      _analysisResult!['feedback']['message'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                if (!isPassed)
                  Expanded(
                    child: CustomButton(
                      text: 'إعادة',
                      onPressed: () {
                        setState(() {
                          _analysisResult = null;
                        });
                      },
                      icon: Icons.refresh,
                      backgroundColor: Colors.orange[700],
                    ),
                  ),
                if (!isPassed) const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: isPassed ? 'تم' : 'متابعة',
                    onPressed: () => Navigator.pop(context),
                    icon: isPassed ? Icons.check : Icons.arrow_forward,
                    backgroundColor: isPassed ? AppTheme.correctGreen : AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}