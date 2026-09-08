import 'package:flutter/material.dart';

import '../../widgets/item_card.dart';
import '../../widgets/status_badge.dart';
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
      appBar: AppBar(
        title: const Text('My Reports'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                Text(
                  'My Reports',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track the items you have reported and their current status.',
                ),
                const SizedBox(height: 28),

                ...reports.map(
                  (report) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ReportCard(report: report),
                  ),
                ),

                const SizedBox(height: 4),

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.swap_horiz,
                  size: 17,
                  color: Color(0xFF667085),
                ),
                const SizedBox(width: 6),
                Text(
                  report.type,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475467),
                  ),
                ),
                const Spacer(),
                StatusBadge(
                  status: report.status,
                ),
              ],
            ),
          ],
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