import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../providers/fortress_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../services/audio_service.dart';
import '../../../services/api_service.dart';
import '../../../widgets/custom_button.dart';

/// شاشة التحضير القبلي
class PreSessionPreparation extends StatefulWidget {
  const PreSessionPreparation({Key? key}) : super(key: key);

  @override
  State<PreSessionPreparation> createState() => _PreSessionPreparationState();
}

class _PreSessionPreparationState extends State<PreSessionPreparation> {
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
      _currentTask = fortressProvider.getPreSessionPreparation();
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
        mode: 'pre_session_preparation',
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
            6, // 6 نقاط للتحضير القبلي
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
        title: const Text('التحضير القبلي'),
        backgroundColor: Colors.purple[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              elevation: 4,
              color: Colors.purple[50],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.play_arrow,
                      size: 80,
                      color: Colors.purple[700],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'التحضير القبلي',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'التحضير قبل جلسة الحفظ',
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
                          color: Colors.purple[300]!,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _currentTask ?? 'لا يوجد تحضير قبلي اليوم',
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
            
            // Pre-session Preparation Benefits
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stars, color: Colors.purple[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'فوائد التحضير القبلي',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      'تهيئة الذهن للحفظ',
                      Icons.psychology,
                      Colors.purple,
                    ),
                    _buildBenefitItem(
                      'زيادة التركيز والانتباه',
                      Icons.center_focus_strong,
                      Colors.blue,
                    ),
                    _buildBenefitItem(
                      'تقليل الأخطاء أثناء الحفظ',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildBenefitItem(
                      'تحسين جودة التلاوة',
                      Icons.record_voice_over,
                      Colors.orange,
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
                        Icon(Icons.list_alt, color: Colors.purple[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'خطوات التحضير القبلي',
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
                      'الوضوء وطلب العون من الله',
                      Icons.water_drop,
                      Colors.blue,
                    ),
                    _buildStepItem(
                      '2',
                      'قراءة الصفحات المحددة بصوت منخفض',
                      Icons.volume_down,
                      Colors.green,
                    ),
                    _buildStepItem(
                      '3',
                      'التدرب على النطق الصحيح',
                      Icons.record_voice_over,
                      Colors.orange,
                    ),
                    _buildStepItem(
                      '4',
                      'فهم معاني الكلمات الصعبة',
                      Icons.lightbulb,
                      Colors.amber,
                    ),
                    _buildStepItem(
                      '5',
                      'تحديد الأهداف للجلسة',
                      Icons.flag,
                      Colors.red,
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
                        'ابدأ التحضير القبلي',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'اقرأ الصفحات المحددة بهدوء وتركيز',
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
                                  : Colors.purple[700],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isRecording 
                                      ? AppTheme.errorRed 
                                      : Colors.purple[700]!).withOpacity(0.5),
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
                          color: _isRecording ? AppTheme.errorRed : Colors.purple[700],
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
                        'لا يوجد تحضير قبلي اليوم',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'تحقق من الخطة اليومية لمعرفة مواعيد التحضير القبلي',
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
            
            const SizedBox(height: 24),
            
            // Preparation Tips
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.tips_and_updates,
                      size: 60,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'نصائح للتحضير القبلي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem('اختر مكاناً هادئاً ومريحاً'),
                    _buildTipItem('تأكد من الإضاءة الجيدة'),
                    _buildTipItem('احتفظ بمصحف مفتوح أمامك'),
                    _buildTipItem('لا تستعجل في القراءة'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
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

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.amber[700], size: 18),
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
              isPassed ? 'ممتاز! أحسنت التحضير القبلي' : 'استمر في التحضير',
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
                    backgroundColor: isPassed ? AppTheme.correctGreen : Colors.purple[700],
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
