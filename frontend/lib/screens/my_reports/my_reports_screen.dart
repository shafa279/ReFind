import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/item_card.dart';
import '../../widgets/status_badge.dart';
import '../item_details/item_details_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<dynamic> reports = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final userId = AuthService.userId;

    if (userId == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Please log in to view your reports.';
      });

      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result =
          await ApiService.getMyReports(userId);

      if (!mounted) return;

      setState(() {
        reports = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load your reports.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    final activeReports = reports.where((report) {
      return (report['status'] ?? 'Searching') !=
          'Resolved';
    }).length;

    final possibleMatches = reports.where((report) {
      return (report['status'] ?? '') ==
          'Potential Match';
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            const AppNavigation(
              currentPage: 'My Reports',
            ),

            Expanded(
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 64,
                  vertical: isMobile ? 28 : 42,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 980,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildHeader(
                          context,
                          isMobile,
                          reports.length,
                          activeReports,
                          possibleMatches,
                        ),

                        const SizedBox(height: 28),

                        if (isLoading)
                          const Center(
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(
                                vertical: 70,
                              ),
                              child:
                                  CircularProgressIndicator(),
                            ),
                          )
                        else if (errorMessage != null)
                          _buildError()
                        else if (reports.isEmpty)
                          _buildEmptyState()
                        else
                          _buildReports(
                            context,
                            isMobile,
                          ),

                        const SizedBox(height: 28),

                        _buildPrivacyNotice(),

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

  Widget _buildReports(
    BuildContext context,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Your reported items',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontSize: isMobile ? 22 : 25,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF171A2B),
              ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Select a report to review its details, match status, and verification progress.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF686B78),
          ),
        ),

        const SizedBox(height: 20),

        ...reports.map(
          (report) => Padding(
            padding:
                const EdgeInsets.only(bottom: 16),
            child: _ReportCard(
              report: report,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isMobile,
    int totalReports,
    int activeReports,
    int possibleMatches,
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
              color: const Color(0xFF6C4EFF),
              borderRadius:
                  BorderRadius.circular(30),
            ),
            child: const Text(
              'REPORT DASHBOARD',
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
            'Keep track of every report',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
                  color: Colors.white,
                  fontSize:
                      isMobile ? 29 : 36,
                  fontWeight: FontWeight.w900,
                ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Follow your lost and found item reports from submission to verification.',
            style: TextStyle(
              color: Color(0xFFD0D2DE),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SummaryChip(
                icon:
                    Icons.inventory_2_outlined,
                value:
                    '$totalReports',
                label: 'Total reports',
              ),
              _SummaryChip(
                icon:
                    Icons.track_changes_rounded,
                value:
                    '$activeReports',
                label: 'Active',
              ),
              _SummaryChip(
                icon:
                    Icons.auto_awesome_rounded,
                value:
                    '$possibleMatches',
                label: 'Potential matches',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 60,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFF667085),
            ),

            const SizedBox(height: 16),

            Text(
              errorMessage ??
                  'Unable to load your reports.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF475467),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loadReports,
              child:
                  const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 20,
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 56,
            color: Color(0xFF98A2B3),
          ),

          SizedBox(height: 16),

          Text(
            'No reports yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Items you report will appear here.',
            style: TextStyle(
              color: Color(0xFF667085),
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
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE1D8FF),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF6C4EFF),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Your private details remain private',
                  style: TextStyle(
                    color: Color(0xFF302A55),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Private identifying details are never displayed in public reports or match cards. They are only used during ownership verification.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF4D4968),
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

class _ReportCard extends StatelessWidget {
  final dynamic report;

  const _ReportCard({
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final int itemId =
        report['id'] ?? 0;

    final String itemName =
        report['item_name'] ??
            'Unnamed item';

    final String type =
        report['item_type'] ??
            'Unknown';

    final String category =
        report['category'] ??
            'Other';

    final String location =
        report['location'] ??
            'Unknown location';

    final String date =
        _formatDate(report['date']);

    final String status =
        report['status'] ??
            'Searching';

    final bool isLost =
        type.toLowerCase() == 'lost';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E9F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ItemCard(
            itemName: itemName,
            category: category,
            location: location,
            date: date,
            status: status,
            onPressed: () {
              if (itemId == 0) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Unable to open this report.',
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

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              4,
              16,
              12,
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isLost
                        ? const Color(
                            0xFFFFF4E5,
                          )
                        : const Color(
                            0xFFEAF8F0,
                          ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        isLost
                            ? Icons.search_rounded
                            : Icons
                                .inventory_2_outlined,
                        size: 15,
                        color: isLost
                            ? const Color(
                                0xFFB25A00,
                              )
                            : const Color(
                                0xFF16794A,
                              ),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        '$type report',
                        style: TextStyle(
                          color: isLost
                              ? const Color(
                                  0xFFB25A00,
                                )
                              : const Color(
                                  0xFF16794A,
                                ),
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                StatusBadge(
                  status: status,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null ||
        date.toString().isEmpty) {
      return 'Date unavailable';
    }

    try {
      final parsedDate =
          DateTime.parse(
        date.toString(),
      );

      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      return '${parsedDate.day} '
          '${months[parsedDate.month - 1]} '
          '${parsedDate.year}';
    } catch (_) {
      return date.toString();
    }
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF252A43),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3C4260),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFFA997FF),
          ),

          const SizedBox(width: 8),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(width: 5),

          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD0D2DE),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}