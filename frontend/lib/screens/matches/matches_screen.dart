import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_navigation.dart';
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
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _matches = [];
      });

      return;
    }

    try {
      final reports = await ApiService.getMyReports(userId);

      final List<dynamic> allMatches = [];

      for (final report in reports) {
        final itemId = int.tryParse(
          report['id'].toString(),
        );

        if (itemId == null) {
          continue;
        }

        final matches =
            await ApiService.getMatches(itemId);

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
    final screenWidth =
        MediaQuery.of(context).size.width;

    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            const AppNavigation(
              currentPage: 'Matches',
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      isMobile ? 20 : 64,
                  vertical:
                      isMobile ? 28 : 42,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 980,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildHeader(
                          context,
                          isMobile,
                          _matches.length,
                        ),

                        const SizedBox(height: 24),

                        _buildPrivacyNotice(),

                        const SizedBox(height: 28),

                        Text(
                          'Matches for your report',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontSize:
                                    isMobile
                                        ? 22
                                        : 25,
                                fontWeight:
                                    FontWeight.w800,
                                color:
                                    const Color(
                                  0xFF171A2B,
                                ),
                              ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Review each possible match and start verification only when the item appears to be yours.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color:
                                Color(0xFF686B78),
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(
                                vertical: 60,
                              ),
                              child:
                                  CircularProgressIndicator(),
                            ),
                          )
                        else if (_matches.isEmpty)
                          _buildEmptyState()
                        else
                          ..._buildMatchCards(),

                        const SizedBox(height: 8),

                        const Center(
                          child: Text(
                            'Private identifying details are never shown in public match cards.',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color:
                                  Color(0xFF686B78),
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

  List<Widget> _buildMatchCards() {
    return _matches.map((match) {
      final itemId = int.tryParse(
        match['id'].toString(),
      );

      final itemName =
          match['item_name']?.toString() ??
              'Unknown item';

      final category =
          match['category']?.toString() ??
              'Unknown category';

      final location =
          match['location']?.toString() ??
              'Unknown location';

      final date =
          match['date']?.toString() ??
              'Unknown date';

      final matchScore =
          int.tryParse(
                match['match_score']
                    .toString(),
              ) ??
              0;

      return Padding(
        padding:
            const EdgeInsets.only(
          bottom: 16,
        ),
        child: MatchCard(
          itemName: itemName,
          category: category,
          location: location,
          date: date,
          matchPercentage: matchScore,
          onPressed: () {
            if (itemId == null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Unable to open this item.',
                  ),
                ),
              );

              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ItemDetailsScreen(
                  itemId: itemId,
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildHeader(
    BuildContext context,
    bool isMobile,
    int matchCount,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isMobile ? 22 : 30,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF171A2B),
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color:
                  const Color(0xFF6C4EFF),
              borderRadius:
                  BorderRadius.circular(30),
            ),
            child: const Text(
              'MATCH RESULTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight:
                    FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Potential matches found',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
                  color: Colors.white,
                  fontSize:
                      isMobile ? 29 : 36,
                  fontWeight:
                      FontWeight.w900,
                ),
          ),

          const SizedBox(height: 10),

          const Text(
            'ReFind compares report details to help identify likely matches across campus.',
            style: TextStyle(
              color:
                  Color(0xFFD0D2DE),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color:
                  const Color(0xFF252A43),
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color:
                    const Color(0xFF3C4260),
              ),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons
                      .auto_awesome_rounded,
                  color:
                      Color(0xFFA997FF),
                  size: 18,
                ),

                const SizedBox(width: 8),

                Text(
                  '$matchCount possible matches',
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
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
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF0EBFF),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFE1D8FF),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color:
                Color(0xFF6C4EFF),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Your privacy stays protected',
                  style: TextStyle(
                    color:
                        Color(0xFF302A55),
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'These are potential matches, not proof of ownership. Private identifying details remain hidden and are only used during ownership verification.',
                  style: TextStyle(
                    color:
                        Color(0xFF4D4968),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 55,
        horizontal: 20,
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 50,
            color:
                Color(0xFF686B78),
          ),

          SizedBox(height: 12),

          Text(
            'No potential matches found yet.',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
              color:
                  Color(0xFF171A2B),
            ),
          ),

          SizedBox(height: 8),

          Text(
            'ReFind will show possible matches here when they are identified.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color:
                  Color(0xFF686B78),
            ),
          ),
        ],
      ),
    );
  }
}