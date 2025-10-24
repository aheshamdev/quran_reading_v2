import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/section_title.dart';
import '../../widgets/progress_card.dart';

/// شاشة لوحة المعلومات التفصيلية
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المعلومات'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          if (progressProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // ملخص الإحصائيات
                const SectionTitle(
                  title: 'ملخص اليوم',
                  icon: Icons.today,
                ),
                _buildTodaySummary(progressProvider),
                
                const SizedBox(height: 24),
                
                // رسم بياني للتقدم
                const SectionTitle(
                  title: 'التقدم الأسبوعي',
                  icon: Icons.show_chart,
                ),
                _buildWeeklyChart(),
                
                const SizedBox(height: 24),
                
                // الأهداف
                const SectionTitle(
                  title: 'الأهداف',
                  icon: Icons.flag,
                ),
                _buildGoals(progressProvider),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodaySummary(ProgressProvider progressProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'الدروس المكتملة',
                    '${progressProvider.completedLessons}',
                    Icons.check_circle,
                    AppTheme.correctGreen,
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.grey[300],
                  ),
                  _buildSummaryItem(
                    'النقاط المكتسبة',
                    '${progressProvider.totalPoints}',
                    Icons.stars,
                    AppTheme.lightGold.withOpacity(0.8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    // TODO: يمكن استخدام مكتبة charts_flutter لرسم بياني حقيقي
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'الرسم البياني قيد التطوير',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            // عرض بسيط للأيام
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final isActive = index < 3; // مثال: 3 أيام نشطة
                return Column(
                  children: [
                    Container(
                      width: 40,
                      height: isActive ? 80 : 40,
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primaryGreen : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ['سبت', 'أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'][index],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoals(ProgressProvider progressProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildGoalCard(
            'الهدف الأسبوعي',
            progressProvider.completedLessons,
            7,
            Icons.calendar_today,
            AppTheme.primaryGreen,
          ),
          const SizedBox(height: 12),
          _buildGoalCard(
            'الهدف الشهري',
            progressProvider.completedLessons,
            30,
            Icons.calendar_month,
            Colors.orange[700]!,
          ),
          const SizedBox(height: 12),
          _buildGoalCard(
            'هدف النقاط',
            progressProvider.totalPoints,
            500,
            Icons.stars,
            Colors.purple[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    String title,
    int current,
    int target,
    IconData icon,
    Color color,
  ) {
    final progress = current / target;
    final percentage = (progress * 100).clamp(0, 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$current من $target',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}