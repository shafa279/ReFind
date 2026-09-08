
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String itemName;
  final String category;
  final String location;
  final String date;
  final String? imageUrl;
  final String? status;
  final VoidCallback? onPressed;

  const ItemCard({
    super.key,
    required this.itemName,
    required this.category,
    required this.location,
    required this.date,
    this.imageUrl,
    this.status,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ItemImage(imageUrl: imageUrl),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            itemName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF171A2B),
                            ),
                          ),
                        ),
                        if (status != null)
                          _StatusChip(status: status!),
                      ],
                    ),

                    const SizedBox(height: 8),

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

                    if (onPressed != null) ...[
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: onPressed,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'View Details →',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6C4EFF),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  final String? imageUrl;

  const _ItemImage({
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

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6045D8),
        ),
      ),
    );
  }
}