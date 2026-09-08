
import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  final String itemName;
  final String category;
  final String location;
  final String date;
  final int matchPercentage;
  final String? imageUrl;
  final VoidCallback? onPressed;

  const MatchCard({
    super.key,
    required this.itemName,
    required this.category,
    required this.location,
    required this.date,
    required this.matchPercentage,
    this.imageUrl,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MatchImage(imageUrl: imageUrl),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF171A2B),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6C4EFF),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: location,
                      ),

                      const SizedBox(height: 6),

                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: date,
                      ),
                    ],
                  ),
                ),

                _MatchPercentage(
                  percentage: matchPercentage,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: Color(0xFF6C4EFF),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Potential match — not proof of ownership.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6045D8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (onPressed != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: const Text('View Potential Match'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchImage extends StatelessWidget {
  final String? imageUrl;

  const _MatchImage({
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 105,
        height: 105,
        color: const Color(0xFFF0F1F5),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported_outlined,
                    size: 32,
                    color: Color(0xFF9A9CA8),
                  );
                },
              )
            : const Icon(
                Icons.image_outlined,
                size: 32,
                color: Color(0xFF9A9CA8),
              ),
      ),
    );
  }
}

class _MatchPercentage extends StatelessWidget {
  final int percentage;

  const _MatchPercentage({
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF287A4B),
            ),
          ),
          const Text(
            'match',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF287A4B),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF8A8D99),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF686B78),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}