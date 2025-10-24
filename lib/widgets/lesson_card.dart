import 'package:flutter/material.dart';

/// كارت لعرض درس أو مهمة
class LessonCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onStart;
  final bool isCompleted;
  final IconData? icon;

  const LessonCard({
    Key? key,
    required this.title,
    required this.description,
    required this.onStart,
    this.isCompleted = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted 
                ? const Color(0xFF4CAF50) 
                : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // الأيقونة أو علامة الإنجاز
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF1B5E20).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted 
                    ? Icons.check_circle 
                    : (icon ?? Icons.book),
                color: isCompleted 
                    ? Colors.white 
                    : const Color(0xFF1B5E20),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            // زر البدء
            if (!isCompleted)
              ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'ابدأ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// كارت درس مصغر
class CompactLessonCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isActive;

  const CompactLessonCard({
    Key? key,
    required this.title,
    required this.onTap,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isActive 
          ? const Color(0xFF1B5E20) 
          : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive 
                  ? Colors.white 
                  : const Color(0xFF1B5E20),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}