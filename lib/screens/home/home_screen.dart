import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../app/app_routes.dart';
import '../../providers/user_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/fortress_provider.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/section_title.dart';

/// الشاشة الرئيسية للتطبيق
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    final progressProvider = context.read<ProgressProvider>();
    final fortressProvider = context.read<FortressProvider>();

    if (userProvider.currentUser != null) {
      await progressProvider.loadProgress(userProvider.currentUser!.uid);
      await fortressProvider.loadDailyPlan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية'),
        backgroundColor: AppTheme.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ترحيب بالمستخدم
              _buildWelcomeSection(),

              const SizedBox(height: 16),

              // نظرة عامة على التقدم
              const SectionTitle(
                title: 'نظرة عامة',
                icon: Icons.analytics_outlined,
              ),
              _buildProgressOverview(),

              const SizedBox(height: 24),

              // زر الحصون الخمسة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  text: 'الحصون الخمسة',
                  icon: Icons.castle_outlined,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.fortresses);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // خطة اليوم
              _buildTodayPlanSection(),

              const SizedBox(height: 24),

              // أزرار سريعة
              _buildQuickActions(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userName = userProvider.currentUser?.displayName ?? 'المستخدم';

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreen,
                AppTheme.primaryGreen.withOpacity(0.7),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.wb_sunny_outlined,
                    color: AppTheme.lightGold,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'السلام عليكم، $userName',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'بارك الله في وقتك وجهدك',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressOverview() {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        if (progressProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: _buildProgressCard(
                  'السلسلة',
                  '${progressProvider.currentStreak}',
                  Icons.local_fire_department,
                  Colors.orange[700]!,
                  () => Navigator.pushNamed(context, AppRoutes.progress),
                ),
              ),
              Expanded(
                child: _buildProgressCard(
                  'النقاط',
                  '${progressProvider.totalPoints}',
                  Icons.stars_rounded,
                  AppTheme.lightGold.withOpacity(0.8),
                  () => Navigator.pushNamed(context, AppRoutes.progress),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayPlanSection() {
    return Consumer<FortressProvider>(
      builder: (context, fortressProvider, child) {
        if (fortressProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!fortressProvider.hasTodayPlan) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'لا توجد خطة لليوم',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final todayPlan = fortressProvider.todayPlan!;

        return Column(
          children: [
            const SectionTitle(
              title: 'خطة اليوم',
              icon: Icons.calendar_today,
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todayPlan.dayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // الورد اليومي
                    _buildPlanItem(
                      'الورد اليومي',
                      todayPlan.listening,
                      Icons.hearing,
                    ),

                    // الحفظ - استخدم hasMemorizationTask
                    if (todayPlan.hasMemorizationTask)
                      _buildPlanItem(
                        'الحفظ',
                        todayPlan.memorization['task'],
                        Icons.book,
                      ),

                    // مراجعة القريب - استخدم hasNearReviewTask
                    if (todayPlan.hasNearReviewTask)
                      _buildPlanItem(
                        'مراجعة القريب',
                        todayPlan.nearReview['task'],
                        Icons.refresh,
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlanItem(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        const SectionTitle(
          title: 'إجراءات سريعة',
          icon: Icons.flash_on,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'التقدم',
                  Icons.trending_up,
                  () => Navigator.pushNamed(context, AppRoutes.progress),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'الملاحظات',
                  Icons.feedback_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.feedback),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryGreen, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, String value, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}
