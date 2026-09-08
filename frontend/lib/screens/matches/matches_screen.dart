
import 'package:flutter/material.dart';

import '../../widgets/match_card.dart';
import '../item_details/item_details_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matches = [
      _MatchData(
        itemName: 'Black Wireless Headphones',
        category: 'Electronics',
        location: 'Central Library',
        date: '5 September 2026',
        matchPercentage: 94,
      ),
      _MatchData(
        itemName: 'Wireless Headphones',
        category: 'Electronics',
        location: 'Student Block',
        date: '4 September 2026',
        matchPercentage: 81,
      ),
      _MatchData(
        itemName: 'Black Bluetooth Headset',
        category: 'Electronics',
        location: 'Cafeteria',
        date: '3 September 2026',
        matchPercentage: 68,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Potential Matches'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                Text(
                  'Potential Matches',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Possible matches identified by the system based on the information provided in your report.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF686B78),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F5FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE4DDFB),
                    ),
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
                          'These are potential matches, not proof of ownership. Private identifying details are kept hidden and can be used during verification.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF6045D8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

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
                      color: Color(0xFF686B78),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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