import 'package:flutter/material.dart';

import '../item_details/item_details_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      _ReportData(
        itemName: 'Black Wireless Headphones',
        type: 'Lost',
        category: 'Electronics',
        location: 'Central Library',
        date: '5 September 2026',
        status: 'Potential Match',
      ),
      _ReportData(
        itemName: 'Blue Notebook',
        type: 'Lost',
        category: 'Stationery',
        location: 'Classroom Block',
        date: '2 September 2026',
        status: 'Searching',
      ),
      _ReportData(
        itemName: 'Black Water Bottle',
        type: 'Found',
        category: 'Other',
        location: 'Cafeteria',
        date: '28 August 2026',
        status: 'Verification Pending',
      ),
      _ReportData(
        itemName: 'Calculator',
        type: 'Lost',
        category: 'Electronics',
        location: 'Science Block',
        date: '20 August 2026',
        status: 'Resolved',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'My Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                const Text(
                  'My Reports',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track the items you have reported and their current status.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 28),

                ...reports.map(
                  (report) => _ReportCard(report: report),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD9E2FF),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Color(0xFF3155D9),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your private identifying details are never displayed in public reports or match cards. They are only used during ownership verification.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF475467),
                          ),
                        ),
                      ),
                    ],
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

class _ReportCard extends StatelessWidget {
  final _ReportData report;

  const _ReportCard({
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  report.itemName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
              ),
              _StatusBadge(status: report.status),
            ],
          ),
          const SizedBox(height: 14),

          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _InfoItem(
                icon: Icons.swap_horiz,
                label: report.type,
              ),
              _InfoItem(
                icon: Icons.category_outlined,
                label: report.category,
              ),
              _InfoItem(
                icon: Icons.location_on_outlined,
                label: report.location,
              ),
              _InfoItem(
                icon: Icons.calendar_today_outlined,
                label: report.date,
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ItemDetailsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('View Report'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3155D9),
                side: const BorderSide(
                  color: Color(0xFF3155D9),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF667085),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF475467),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3155D9),
        ),
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