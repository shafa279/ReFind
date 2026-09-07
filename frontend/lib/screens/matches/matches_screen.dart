import 'package:flutter/material.dart';

import '../item_details/item_details_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF171A2B),
          ),
        ),
        title: const Text(
          'Potential Matches',
          style: TextStyle(
            color: Color(0xFF171A2B),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 70,
          vertical: 30,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Items that may match your report',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF171A2B),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Our system found these items as possible matches.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF686B78),
                  ),
                ),

                const SizedBox(height: 25),

                // IMPORTANT NOTICE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEBFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF6C4EFF),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'These are potential matches, not proof of ownership. '
                          'Private details are kept hidden and can be used during verification.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF3F3A63),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                _MatchCard(
                  itemName: 'Black Wireless Headphones',
                  category: 'Electronics',
                  location: 'Central Library',
                  date: '5 September 2026',
                  confidence: '94%',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ItemDetailsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),

                _MatchCard(
                  itemName: 'Wireless Headphones',
                  category: 'Electronics',
                  location: 'Student Block',
                  date: '4 September 2026',
                  confidence: '81%',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ItemDetailsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),

                _MatchCard(
                  itemName: 'Black Bluetooth Headset',
                  category: 'Electronics',
                  location: 'Cafeteria',
                  date: '3 September 2026',
                  confidence: '68%',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ItemDetailsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String itemName;
  final String category;
  final String location;
  final String date;
  final String confidence;
  final VoidCallback onPressed;

  const _MatchCard({
    required this.itemName,
    required this.category,
    required this.location,
    required this.date,
    required this.confidence,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E9F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F1F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.headphones_rounded,
                  color: Color(0xFF6C4EFF),
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF171A2B),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '$category • $location',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF686B78),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8A8D99),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  confidence,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF237A4B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Potential match based on the available report information.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF686B78),
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF171A2B),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                side: const BorderSide(
                  color: Color(0xFFD9DBE5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Potential Match',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}