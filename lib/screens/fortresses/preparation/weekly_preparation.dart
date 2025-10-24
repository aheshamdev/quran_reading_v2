import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../providers/fortress_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../services/audio_service.dart';
import '../../../services/api_service.dart';
import '../../../widgets/custom_button.dart';

/// شاشة التحضير الأسبوعي
class WeeklyPreparation extends StatefulWidget {
  const WeeklyPreparation({Key? key}) : super(key: key);

  @override
  State<WeeklyPreparation> createState() => _WeeklyPreparationState();
}

class _WeeklyPreparationState extends State<WeeklyPreparation> {
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
      _currentTask = fortressProvider.getWeeklyPreparation();
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
        mode: 'weekly_preparation',
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
            10, // 10 نقاط للتحضير الأسبوعي
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
        title: const Text('التحضير الأسبوعي'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              elevation: 4,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 80,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'التحضير الأسبوعي',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'تحضير شامل للأسبوع القادم',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue[300]!,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _currentTask ?? 'لا يوجد تحضير أسبوعي اليوم',
                        style: const TextStyle(
                          fontSize: 20,
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
            
            // Preparation Steps
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list_alt, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'خطوات التحضير الأسبوعي',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStepItem(
                      '1',
                      'مراجعة ما تم حفظه الأسبوع الماضي',
                      Icons.refresh,
                      Colors.green,
                    ),
                    _buildStepItem(
                      '2',
                      'قراءة الحزب الجديد عدة مرات',
                      Icons.book,
                      Colors.blue,
                    ),
                    _buildStepItem(
                      '3',
                      'فهم معاني الآيات',
                      Icons.lightbulb,
                      Colors.amber,
                    ),
                    _buildStepItem(
                      '4',
                      'التدرب على التلاوة الصحيحة',
                      Icons.record_voice_over,
                      Colors.purple,
                    ),
                    _buildStepItem(
                      '5',
                      'تحديد الأهداف للأسبوع',
                      Icons.flag,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recording Section
            if (_currentTask != null && _currentTask != 'لا يوجد') ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'ابدأ التحضير الأسبوعي',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'اقرأ الحزب المحدد للتأكد من فهمك وإتقانك',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Recording Button
                      Center(
                        child: GestureDetector(
                          onTap: _isAnalyzing ? null : _toggleRecording,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: _isRecording 
                                  ? AppTheme.errorRed 
                                  : Colors.blue[700],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isRecording 
                                      ? AppTheme.errorRed 
                                      : Colors.blue[700]!).withOpacity(0.5),
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
                      ),
                      
                      const SizedBox(height: 20),
                      Text(
                        _isRecording 
                            ? 'جاري التسجيل...' 
                            : _isAnalyzing 
                                ? 'جاري التحليل...' 
                                : 'اضغط لبدء القراءة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _isRecording ? AppTheme.errorRed : Colors.blue[700],
                        ),
                      ),
                    ],
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
              
              const SizedBox(height: 24),
              
              if (_analysisResult != null) _buildAnalysisResult(),
            ] else ...[
              // No Task Available
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا يوجد تحضير أسبوعي اليوم',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'تحقق من الخطة اليومية لمعرفة مواعيد التحضير',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    final analysis = _analysisResult!['analysis'];
    final accuracy = analysis['accuracy'] as double;
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
              isPassed ? 'ممتاز! أحسنت التحضير' : 'استمر في التحضير',
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
            const SizedBox(height: 20),
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
                    text: isPassed ? 'تم التحضير' : 'متابعة',
                    onPressed: () => Navigator.pop(context),
                    icon: isPassed ? Icons.check : Icons.arrow_forward,
                    backgroundColor: isPassed ? AppTheme.correctGreen : Colors.blue[700],
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
