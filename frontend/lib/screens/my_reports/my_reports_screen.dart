import 'package:flutter/material.dart';

import '../../widgets/app_navigation.dart';
import '../../widgets/item_card.dart';
import '../../widgets/status_badge.dart';
import '../item_details/item_details_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    final reports = [
      const _ReportData(
        itemName: 'Black Wireless Headphones',
        type: 'Lost',
        category: 'Electronics',
        location: 'Central Library',
        date: '5 September 2026',
        status: 'Potential Match',
      ),
      const _ReportData(
        itemName: 'Blue Notebook',
        type: 'Lost',
        category: 'Stationery',
        location: 'Classroom Block',
        date: '2 September 2026',
        status: 'Searching',
      ),
      const _ReportData(
        itemName: 'Black Water Bottle',
        type: 'Found',
        category: 'Other',
        location: 'Cafeteria',
        date: '28 August 2026',
        status: 'Verification Pending',
      ),
      const _ReportData(
        itemName: 'Calculator',
        type: 'Lost',
        category: 'Electronics',
        location: 'Science Block',
        date: '20 August 2026',
        status: 'Resolved',
      ),
    ];

    final activeReports =
        reports.where((report) => report.status != 'Resolved').length;
    final possibleMatches =
        reports.where((report) => report.status == 'Potential Match').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            const AppNavigation(currentPage: 'My Reports'),
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
                        _buildHeader(
                          context,
                          isMobile,
                          reports.length,
                          activeReports,
                          possibleMatches,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Your reported items',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ReportCard(report: report),
                          ),
                        ),
                        const SizedBox(height: 8),
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

  Widget _buildHeader(
    BuildContext context,
    bool isMobile,
    int totalReports,
    int activeReports,
    int possibleMatches,
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: isMobile ? 29 : 36,
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
                icon: Icons.inventory_2_outlined,
                value: '$totalReports',
                label: 'Total reports',
              ),
              _SummaryChip(
                icon: Icons.track_changes_rounded,
                value: '$activeReports',
                label: 'Active',
              ),
              _SummaryChip(
                icon: Icons.auto_awesome_rounded,
                value: '$possibleMatches',
                label: 'Potential matches',
              ),
            ],
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
  final _ReportData report;

  const _ReportCard({
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final isLost = report.type == 'Lost';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            itemName: report.itemName,
            category: report.category,
            location: report.location,
            date: report.date,
            status: report.status,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ItemDetailsScreen(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isLost
                        ? const Color(0xFFFFF4E5)
                        : const Color(0xFFEAF8F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLost
                            ? Icons.search_rounded
                            : Icons.inventory_2_outlined,
                        size: 15,
                        color: isLost
                            ? const Color(0xFFB25A00)
                            : const Color(0xFF16794A),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${report.type} report',
                        style: TextStyle(
                          color: isLost
                              ? const Color(0xFFB25A00)
                              : const Color(0xFF16794A),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                StatusBadge(status: report.status),
              ],
            ),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
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

class _ReportData {
  final String itemName;
  final String type;
  final String category;
  final String location;
  final String date;
  final String status;

  const _ReportData({
    required this.itemName,
    required this.type,
    required this.category,
    required this.location,
    required this.date,
    required this.status,
  });
}