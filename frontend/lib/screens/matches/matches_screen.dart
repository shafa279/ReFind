import 'package:flutter/material.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 22 : 70,
            vertical: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back'),
              ),

              const SizedBox(height: 25),

              const Text(
                'Potential Matches',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF171A2B),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'ReFind uses smart matching to find items that may be '
                'connected to your report.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
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
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF6C4EFF),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'These are potential matches, not proof of ownership. '
                        'Private details are kept hidden and can be used '
                        'during verification.',
                        style: TextStyle(
                          color: Color(0xFF4D4968),
                          height: 1.45,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                '3 potential matches found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171A2B),
                ),
              ),

              const SizedBox(height: 16),

              const _MatchCard(
                itemName: 'Black Wireless Headphones',
                category: 'Electronics',
                location: 'Central Library',
                date: '5 September 2026',
                score: '94%',
              ),

              const SizedBox(height: 16),

              const _MatchCard(
                itemName: 'Wireless Headphones',
                category: 'Electronics',
                location: 'Student Block',
                date: '4 September 2026',
                score: '81%',
              ),

              const SizedBox(height: 16),

              const _MatchCard(
                itemName: 'Black Bluetooth Headset',
                category: 'Electronics',
                location: 'Cafeteria',
                date: '3 September 2026',
                score: '68%',
              ),

              const SizedBox(height: 35),

              Center(
                child: Text(
                  'Private identifying details are never shown here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
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
  final String score;

  const _MatchCard({
    required this.itemName,
    required this.category,
    required this.location,
    required this.date,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF6C4EFF),
                ),
              ),

              const SizedBox(width: 14),

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
                    const SizedBox(height: 5),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF686B78),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7EF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '$score match',
                  style: const TextStyle(
                    color: Color(0xFF237A4B),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Color(0xFF686B78),
              ),
              const SizedBox(width: 7),
              Text(
                location,
                style: const TextStyle(
                  color: Color(0xFF686B78),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 17,
                color: Color(0xFF686B78),
              ),
              const SizedBox(width: 7),
              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFF686B78),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
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
                  color: Color(0xFF171A2B),
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