```dart
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/match_card.dart';
import '../item_details/item_details_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  bool _isLoading = true;
  List<dynamic> _matches = [];

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    final userId = AuthService.userId;

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Get all items reported by the current user.
    // Then get potential matches for each report.
    //
    // For now, we use the backend /items endpoint to find
    // the user's reports.
    try {
      final response = await ApiService.getMyReports(userId);

      final List<dynamic> allMatches = [];

      for (final item in response) {
        final itemId = item['id'];

        if (itemId == null) continue;

        final matches = await ApiService.getMatches(itemId);

        allMatches.addAll(matches);
      }

      if (!mounted) return;

      setState(() {
        _matches = allMatches;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _matches = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Potential Matches'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
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

                      if (_matches.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 50),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 50,
                                  color: Color(0xFF686B78),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No potential matches found yet.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'We’ll show possible matches here when they are found.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF686B78),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ..._matches.map(
                        (match) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: MatchCard(
                            itemName:
                                match['item_name'] ?? 'Unknown item',
                            category:
                                match['category'] ?? 'Unknown category',
                            location:
                                match['location'] ?? 'Unknown location',
                            date: match['date'] ?? 'Unknown date',
                            matchPercentage:
                                match['match_score'] ?? 0,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ItemDetailsScreen(),
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
```
