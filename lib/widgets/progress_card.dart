import 'package:flutter/material.dart';
import '../models/progress_model.dart';

/// عنصر واجهة لعرض تقدم المستخدم
class ProgressCard extends StatelessWidget {
  final Progress progress;
  final VoidCallback? onTap;

  const ProgressCard({
    Key? key,
    required this.progress,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1B5E20),
                const Color(0xFF1B5E20).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'التقدم العام',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildProgressItem(
                icon: Icons.stars,
                label: 'النقاط',
                value: '${progress.points}',
              ),
              const SizedBox(height: 12),
              _buildProgressItem(
                icon: Icons.local_fire_department,
                label: 'سلسلة الأيام',
                value: '${progress.streak}',
              ),
              const SizedBox(height: 12),
              _buildProgressItem(
                icon: Icons.check_circle,
                label: 'الدروس المكتملة',
                value: '${progress.lessonsCompleted}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}