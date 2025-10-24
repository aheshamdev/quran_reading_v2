import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import '../../../app/app_routes.dart';
import '../../../providers/fortress_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/section_title.dart';

/// شاشة التحضير الرئيسية - نقطة البداية لجميع أنواع التحضير
class PreparationFortress extends StatelessWidget {
  const PreparationFortress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحضير'),
        backgroundColor: Colors.blue[700],
      ),
      body: Consumer<FortressProvider>(
        builder: (context, fortressProvider, child) {
          return SingleChildScrollView(
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
                          Icons.schedule,
                          size: 80,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'التحضير',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'التحضير الأسبوعي والليلي والقبلي',
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
                          child: const Text(
                            'التحضير هو الأساس المتين لحفظ القرآن الكريم',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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
                
                // Preparation Types
                const SectionTitle(
                  title: 'أنواع التحضير',
                  icon: Icons.list_alt,
                ),
                
                // Weekly Preparation
                _buildPreparationCard(
                  context,
                  'التحضير الأسبوعي',
                  'تحضير شامل للأسبوع القادم',
                  Icons.calendar_today,
                  Colors.blue[700]!,
                  fortressProvider.getWeeklyPreparation(),
                  () => Navigator.pushNamed(context, AppRoutes.weeklyPreparation),
                ),
                
                const SizedBox(height: 12),
                
                // Nightly Preparation
                _buildPreparationCard(
                  context,
                  'التحضير الليلي',
                  'مراجعة ما تم حفظه اليوم',
                  Icons.nightlight_round,
                  Colors.indigo[700]!,
                  fortressProvider.getNightlyPreparation(),
                  () => Navigator.pushNamed(context, AppRoutes.nightlyPreparation),
                ),
                
                const SizedBox(height: 12),
                
                // Pre-session Preparation
                _buildPreparationCard(
                  context,
                  'التحضير القبلي',
                  'التحضير قبل جلسة الحفظ',
                  Icons.play_arrow,
                  Colors.purple[700]!,
                  fortressProvider.getPreSessionPreparation(),
                  () => Navigator.pushNamed(context, AppRoutes.preSessionPreparation),
                ),
                
                const SizedBox(height: 32),
                
                // Benefits Section
                _buildBenefitsSection(),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                const SectionTitle(
                  title: 'إجراءات سريعة',
                  icon: Icons.flash_on,
                ),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'بدء التحضير الأسبوعي',
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.weeklyPreparation),
                        icon: Icons.calendar_today,
                        backgroundColor: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'التحضير الليلي',
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.nightlyPreparation),
                        icon: Icons.nightlight_round,
                        backgroundColor: Colors.indigo[700],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreparationCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String? task,
    VoidCallback onTap,
  ) {
    final hasTask = task != null && task != 'لا يوجد';
    
    return Card(
      elevation: hasTask ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasTask ? color : Colors.grey[300]!,
              width: hasTask ? 2 : 1,
            ),
            gradient: hasTask 
                ? LinearGradient(
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasTask 
                      ? color.withOpacity(0.2)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: hasTask ? color : Colors.grey,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: hasTask 
                            ? AppTheme.primaryGreen
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: hasTask 
                            ? Colors.grey[600]
                            : Colors.grey,
                      ),
                    ),
                    if (hasTask) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                hasTask ? Icons.arrow_forward_ios : Icons.lock,
                color: hasTask ? color : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'فوائد التحضير',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBenefitItem(
              'يؤسس قاعدة قوية للحفظ',
              Icons.foundation,
              Colors.blue,
            ),
            _buildBenefitItem(
              'يساعد على الفهم العميق',
              Icons.lightbulb,
              Colors.amber,
            ),
            _buildBenefitItem(
              'يقلل من الأخطاء أثناء الحفظ',
              Icons.check_circle,
              Colors.green,
            ),
            _buildBenefitItem(
              'يزيد من الثقة في النفس',
              Icons.psychology,
              Colors.purple,
            ),
            _buildBenefitItem(
              'يحسن من جودة التلاوة',
              Icons.record_voice_over,
              Colors.teal,
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
}
