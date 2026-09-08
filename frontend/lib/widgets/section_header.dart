
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EBFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 19,
                color: const Color(0xFF6C4EFF),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171A2B),
                ),
              ),
            ),
          ],
        ),

        if (subtitle != null) ...[
          const SizedBox(height: 7),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF686B78),
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}