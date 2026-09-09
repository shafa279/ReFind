import 'package:flutter/material.dart';

import '../../widgets/app_navigation.dart';
import '../../widgets/match_card.dart';
import '../item_details/item_details_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    final matches = [
      const _MatchData(
        itemName: 'Black Wireless Headphones',
        category: 'Electronics',
        location: 'Central Library',
        date: '5 September 2026',
        matchPercentage: 94,
      ),
      const _MatchData(
        itemName: 'Wireless Headphones',
        category: 'Electronics',
        location: 'Student Block',
        date: '4 September 2026',
        matchPercentage: 81,
      ),
      const _MatchData(
        itemName: 'Black Bluetooth Headset',
        category: 'Electronics',
        location: 'Cafeteria',
        date: '3 September 2026',
        matchPercentage: 68,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            const AppNavigation(currentPage: 'Matches'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 64,
                  vertical: isMobile ? 28 : 42,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, isMobile, matches.length),
                        const SizedBox(height: 24),
                        _buildPrivacyNotice(),
                        const SizedBox(height: 28),
                        Text(
                          'Matches for your report',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontSize: isMobile ? 22 : 25,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF171A2B),
                                  ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Review each possible match and start verification only when the item appears to be yours.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF686B78),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...matches.map(
                          (match) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: MatchCard(
                              itemName: match.itemName,
                              category: match.category,
                              location: match.location,
                              date: match.date,
                              matchPercentage: match.matchPercentage,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ItemDetailsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Private identifying details are never shown in public match cards.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: Color(0xFF686B78),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isMobile,
    int matchCount,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        color: const Color(0xFF171A2B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF6C4EFF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'MATCH RESULTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Potential matches found',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: isMobile ? 29 : 36,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          const Text(
            'ReFind compares report details to help identify likely matches across campus.',
            style: TextStyle(
              color: Color(0xFFD0D2DE),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF252A43),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3C4260),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFA997FF),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '$matchCount possible matches',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE1D8FF),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF6C4EFF),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your privacy stays protected',
                  style: TextStyle(
                    color: Color(0xFF302A55),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'These are potential matches, not proof of ownership. Private identifying details remain hidden and are only used during ownership verification.',
                  style: TextStyle(
                    color: Color(0xFF4D4968),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchData {
  final String itemName;
  final String category;
  final String location;
  final String date;
  final int matchPercentage;

  const _MatchData({
    required this.itemName,
    required this.category,
    required this.location,
    required this.date,
    required this.matchPercentage,
  });
}