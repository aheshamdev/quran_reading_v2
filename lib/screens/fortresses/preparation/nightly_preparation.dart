import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../providers/fortress_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../services/audio_service.dart';
import '../../../services/api_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/section_title.dart';

/// شاشة التحضير الليلي
class NightlyPreparation extends StatefulWidget {
  const NightlyPreparation({Key? key}) : super(key: key);

  @override
  State<NightlyPreparation> createState() => _NightlyPreparationState();
}

class _NightlyPreparationState extends State<NightlyPreparation> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();

  bool _isRecording = false;
  bool _isAnalyzing = false;
  String? _currentTask;
  Map<String, dynamic>? _analysisResult;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final fortressProvider = context.read<FortressProvider>();

    // تحميل الخطة اليومية إذا لم تكن محملة
    if (fortressProvider.todayPlan == null) {
      await fortressProvider.loadDailyPlan();
    }

    _loadTask();
  }

  void _loadTask() {
    final fortressProvider = context.read<FortressProvider>();
    setState(() {
      _currentTask = fortressProvider.getNightlyPreparation();
      _isInitialized = true;
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
        // التحقق من الأذونات قبل بدء التسجيل
        final hasPermission = await _audioService.checkAndRequestPermissions();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يجب السماح بالوصول للميكروفون لتسجيل الصوت'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
          return;
        }

        await _audioService.startRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في بدء التسجيل: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _analyzeAudio(String audioPath) async {
    try {
      final result = await _apiService.analyzeAudio(
        audioPath: audioPath,
        mode: 'nightly_preparation',
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
          // إضافة النقاط
          await progressProvider.addPoints(
            userProvider.currentUser!.uid,
            8, // 8 نقاط للتحضير الليلي
          );

          // تحديث السلسلة
          await progressProvider.updateStreak(userProvider.currentUser!.uid);

          // إظهار رسالة نجاح
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم إكمال التحضير الليلي بنجاح! +8 نقاط'),
                backgroundColor: AppTheme.correctGreen,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التحليل: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحضير الليلي'),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
      ),
      body: !_isInitialized
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card
                  Card(
                    elevation: 4,
                    color: Colors.indigo[50],
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.nightlight_round,
                            size: 80,
                            color: Colors.indigo[700],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'التحضير الليلي',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'مراجعة ما تم حفظه اليوم',
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
                                color: Colors.indigo[300]!,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              _currentTask ?? 'لا يوجد تحضير ليلي اليوم',
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

                  // Nightly Preparation Benefits
                  const SectionTitle(
                    title: 'فوائد التحضير الليلي',
                    icon: Icons.stars,
                  ),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildBenefitItem(
                            'تثبيت الحفظ في الذاكرة',
                            Icons.psychology,
                            Colors.purple,
                          ),
                          _buildBenefitItem(
                            'تحسين جودة النوم',
                            Icons.bedtime,
                            Colors.blue,
                          ),
                          _buildBenefitItem(
                            'زيادة التركيز في اليوم التالي',
                            Icons.center_focus_strong,
                            Colors.green,
                          ),
                          _buildBenefitItem(
                            'تقوية الصلة بالقرآن',
                            Icons.favorite,
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Preparation Steps
                  const SectionTitle(
                    title: 'خطوات التحضير الليلي',
                    icon: Icons.list_alt,
                  ),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildStepItem(
                            '1',
                            'مراجعة سريعة لما تم حفظه اليوم',
                            Icons.refresh,
                            Colors.green,
                          ),
                          _buildStepItem(
                            '2',
                            'قراءة هادئة ومرتلة',
                            Icons.volume_down,
                            Colors.blue,
                          ),
                          _buildStepItem(
                            '3',
                            'التفكر في معاني الآيات',
                            Icons.lightbulb,
                            Colors.amber,
                          ),
                          _buildStepItem(
                            '4',
                            'الدعاء والاستغفار',
                            Icons.favorite,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recording Section
                  if (_currentTask != null && _currentTask != 'لا يوجد') ...[
                    const SectionTitle(
                      title: 'ابدأ التحضير الليلي',
                      icon: Icons.mic,
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
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
                                        : Colors.indigo[700],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isRecording
                                                ? AppTheme.errorRed
                                                : Colors.indigo[700]!)
                                            .withOpacity(0.5),
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
                                color: _isRecording
                                    ? AppTheme.errorRed
                                    : Colors.indigo[700],
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
                              'لا يوجد تحضير ليلي اليوم',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'تحقق من الخطة اليومية لمعرفة مواعيد التحضير الليلي',
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

                  // Night Prayer Reminder
                  const SectionTitle(
                    title: 'تذكير',
                    icon: Icons.mosque,
                  ),

                  Card(
                    color: Colors.purple[50],
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.mosque,
                            size: 60,
                            color: Colors.purple[700],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'لا تنس صلاة العشاء وقيام الليل بعد التحضير الليلي',
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

  Widget _buildStepItem(
      String number, String text, IconData icon, Color color) {
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
              isPassed ? 'ممتاز! أحسنت التحضير الليلي' : 'استمر في التحضير',
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
                      color:
                          isPassed ? AppTheme.correctGreen : Colors.orange[700],
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
                    backgroundColor:
                        isPassed ? AppTheme.correctGreen : Colors.indigo[700],
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
