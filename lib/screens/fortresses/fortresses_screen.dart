import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../../app/app_routes.dart';
import '../../providers/fortress_provider.dart';
import '../../widgets/fortress_card.dart';

/// شاشة الحصون الخمسة
class FortressesScreen extends StatelessWidget {
  const FortressesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحصون الخمسة'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: Consumer<FortressProvider>(
        builder: (context, fortressProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // شرح مختصر
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'اختر الحصن الذي تريد العمل عليه اليوم',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.primaryGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // حصن الورد اليومي
                FortressCard(
                  title: 'الورد اليومي',
                  subtitle: 'استماع وتلاوة الحزب اليومي',
                  icon: Icons.hearing,
                  color: AppTheme.primaryGreen,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.dailyRecitation);
                  },
                  isCompleted: false,
                ),

                // حصن التحضير
                FortressCard(
                  title: 'التحضير',
                  subtitle: 'التحضير الأسبوعي والليلي والقبلي',
                  icon: Icons.schedule,
                  color: Colors.blue[700]!,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.preparation);
                  },
                  isCompleted: false,
                ),

                // حصن الحفظ
                FortressCard(
                  title: 'الحفظ',
                  subtitle: fortressProvider.getMemorizationTask() ??
                      'لا يوجد حفظ اليوم',
                  icon: Icons.book,
                  color: Colors.purple[700]!,
                  onTap: () {
                    final task = fortressProvider.getMemorizationTask();
                    if (task != null) {
                      Navigator.pushNamed(context, AppRoutes.memorization);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لا يوجد مهام حفظ لليوم'),
                        ),
                      );
                    }
                  },
                  isCompleted: false,
                ),

                // حصن مراجعة القريب
                FortressCard(
                  title: 'مراجعة القريب',
                  subtitle: fortressProvider.getNearReviewTask() ??
                      'لا يوجد مراجعة اليوم',
                  icon: Icons.refresh,
                  color: Colors.orange[700]!,
                  onTap: () {
                    final task = fortressProvider.getNearReviewTask();
                    if (task != null) {
                      Navigator.pushNamed(context, AppRoutes.nearReview);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لا يوجد مراجعة قريبة لليوم'),
                        ),
                      );
                    }
                  },
                  isCompleted: false,
                ),

                // حصن مراجعة البعيد
                FortressCard(
                  title: 'مراجعة البعيد',
                  subtitle: fortressProvider.getFarReviewTask() ??
                      'لا يوجد مراجعة اليوم',
                  icon: Icons.history,
                  color: Colors.teal[700]!,
                  onTap: () {
                    final task = fortressProvider.getFarReviewTask();
                    if (task != null) {
                      Navigator.pushNamed(context, AppRoutes.farReview);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لا يوجد مراجعة بعيدة لليوم'),
                        ),
                      );
                    }
                  },
                  isCompleted: false,
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
