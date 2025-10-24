import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../app/app_routes.dart';
import '../../providers/user_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/custom_button.dart';

/// شاشة الملف الشخصي
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // صورة وبيانات المستخدم
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.currentUser;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // صورة المستخدم
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // الاسم
                        Text(
                          user?.displayName ?? 'المستخدم',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // البريد الإلكتروني
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // الإحصائيات السريعة
            Consumer<ProgressProvider>(
              builder: (context, progressProvider, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'السلسلة',
                          '${progressProvider.currentStreak}',
                          Icons.local_fire_department,
                          Colors.orange[700]!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'النقاط',
                          '${progressProvider.totalPoints}',
                          Icons.stars,
                          Colors.purple[700]!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'الدروس',
                          '${progressProvider.completedLessons}',
                          Icons.book,
                          AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // الإعدادات
            _buildMenuSection(
              context,
              'الإعدادات',
              [
                _buildMenuItem(
                  context,
                  'التقدم والإحصائيات',
                  Icons.trending_up,
                  () => Navigator.pushNamed(context, AppRoutes.progress),
                ),
                _buildMenuItem(
                  context,
                  'الملاحظات والتقييم',
                  Icons.feedback_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.feedback),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // معلومات التطبيق
            _buildMenuSection(
              context,
              'معلومات',
              [
                _buildMenuItem(
                  context,
                  'حول التطبيق',
                  Icons.info_outline,
                  () => _showAboutDialog(context),
                ),
                _buildMenuItem(
                  context,
                  'سياسة الخصوصية',
                  Icons.privacy_tip_outlined,
                  () {
                    // TODO: عرض سياسة الخصوصية
                  },
                ),
                _buildMenuItem(
                  context,
                  'شروط الاستخدام',
                  Icons.description_outlined,
                  () {
                    // TODO: عرض شروط الاستخدام
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // زر تسجيل الخروج
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomButton(
                text: 'تسجيل الخروج',
                onPressed: () => _handleSignOut(context),
                icon: Icons.logout,
                backgroundColor: AppTheme.errorRed,
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حول التطبيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'تطبيق تصحيح التلاوة باستخدام الذكاء الاصطناعي',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'الإصدار: 1.0.0',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'تطبيق مخصص لمساعدتك في حفظ ومراجعة القرآن الكريم مع تصحيح التلاوة باستخدام الذكاء الاصطناعي.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final userProvider = context.read<UserProvider>();
      final progressProvider = context.read<ProgressProvider>();
      
      await userProvider.signOut();
      progressProvider.reset();
      
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }
}