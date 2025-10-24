import 'package:flutter/material.dart';

/// عنوان قسم مع أيقونة اختيارية
class SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;
  final Widget? trailing;

  const SectionTitle({
    Key? key,
    required this.title,
    this.icon,
    this.color,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color ?? const Color(0xFF1B5E20),
              size: 28,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color ?? const Color(0xFF1B5E20),
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// عنوان قسم مع خط فاصل
class SectionTitleWithDivider extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;

  const SectionTitleWithDivider({
    Key? key,
    required this.title,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: title,
          icon: icon,
          color: color,
        ),
        Divider(
          color: color?.withOpacity(0.3) ?? 
                 const Color(0xFF1B5E20).withOpacity(0.3),
          thickness: 2,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}