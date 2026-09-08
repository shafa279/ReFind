
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'Searching':
        icon = Icons.search_rounded;
        backgroundColor = const Color(0xFFEFF1F7);
        textColor = const Color(0xFF555968);
        break;

      case 'Potential Match':
        icon = Icons.auto_awesome_rounded;
        backgroundColor = const Color(0xFFF0EBFF);
        textColor = const Color(0xFF6045D8);
        break;

      case 'Verification Pending':
        icon = Icons.lock_outline_rounded;
        backgroundColor = const Color(0xFFFFF4D8);
        textColor = const Color(0xFF876600);
        break;

      case 'Resolved':
        icon = Icons.check_circle_outline_rounded;
        backgroundColor = const Color(0xFFE8F7EF);
        textColor = const Color(0xFF287A4B);
        break;

      case 'Disputed':
        icon = Icons.warning_amber_rounded;
        backgroundColor = const Color(0xFFFFECEA);
        textColor = const Color(0xFFB43B32);
        break;

      default:
        icon = Icons.info_outline_rounded;
        backgroundColor = const Color(0xFFEFF1F7);
        textColor = const Color(0xFF555968);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}