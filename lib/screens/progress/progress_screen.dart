import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../providers/progress_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/section_title.dart';

/// شاشة التقدم والإحصائيات
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final userProvider = context.read<UserProvider>();
    final progressProvider = context.read<ProgressProvider>();

    if (userProvider.currentUser != null) {
      await progressProvider.loadProgress(userProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقدم والإحصائيات'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        child: Consumer<ProgressProvider>(
          builder: (context, progressProvider, child) {
            if (progressProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // الإحصائيات الرئيسية
                  const SectionTitle(
                    title: 'الإحصائيات',
                    icon: Icons.bar_chart,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildProgressCard(
                            'السلسلة الحالية',
                            '${progressProvider.currentStreak}',
                            Icons.local_fire_department,
                            Colors.orange[700]!,
                          ),
                        ),
                        Expanded(
                          child: _buildProgressCard(
                            'أطول سلسلة',
                            '${progressProvider.progress?.longestStreak ?? 0}',
                            Icons.emoji_events,
                            AppTheme.lightGold.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildProgressCard(
                            'إجمالي النقاط',
                            '${progressProvider.totalPoints}',
                            Icons.stars,
                            Colors.purple[700]!,
                          ),
                        ),
                        Expanded(
                          child: _buildProgressCard(
                            'الدروس المكتملة',
                            '${progressProvider.completedLessons}',
                            Icons.check_circle,
                            AppTheme.correctGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // التقدم الشهري
                  const SectionTitle(
                    title: 'التقدم الشهري',
                    icon: Icons.calendar_month,
                  ),
                  _buildMonthlyProgress(progressProvider),

                  const SizedBox(height: 24),

                  // الإنجازات
                  const SectionTitle(
                    title: 'الإنجازات',
                    icon: Icons.military_tech,
                  ),
                  _buildAchievements(progressProvider),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMonthlyProgress(ProgressProvider progressProvider) {
    final completionPercentage = progressProvider.getCompletionPercentage(30);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'نسبة الإنجاز',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${completionPercentage.toInt()}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: completionPercentage / 100,
                minHeight: 20,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${progressProvider.completedLessons} من 30 يوم',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(ProgressProvider progressProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildAchievementCard(
            'المبتدئ',
            'أكمل أول درس',
            progressProvider.completedLessons >= 1,
            Icons.star,
            Colors.blue,
          ),
          _buildAchievementCard(
            'الملتزم',
            'حافظ على سلسلة 7 أيام',
            progressProvider.currentStreak >= 7,
            Icons.local_fire_department,
            Colors.orange,
          ),
          _buildAchievementCard(
            'المثابر',
            'أكمل 30 درس',
            progressProvider.completedLessons >= 30,
            Icons.emoji_events,
            Colors.amber,
          ),
          _buildAchievementCard(
            'البطل',
            'اجمع 500 نقطة',
            progressProvider.totalPoints >= 500,
            Icons.military_tech,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    String title,
    String description,
    bool isUnlocked,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnlocked ? color.withOpacity(0.2) : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isUnlocked ? color : Colors.grey,
            size: 32,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isUnlocked ? Colors.black87 : Colors.grey,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: isUnlocked ? Colors.black54 : Colors.grey,
          ),
        ),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle,
                color: AppTheme.correctGreen, size: 32)
            : const Icon(Icons.lock, color: Colors.grey, size: 32),
      ),
    );
  }

  Widget _buildProgressCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
