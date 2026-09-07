import 'package:flutter/material.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

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
                'My Reports',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF171A2B),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Track the items you have reported and their current status.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF686B78),
                ),
              ),

              const SizedBox(height: 30),

              const _ReportCard(
                itemName: 'Black Wireless Headphones',
                type: 'Lost',
                category: 'Electronics',
                location: 'Central Library',
                date: '5 September 2026',
                status: 'Potential Match',
                statusColor: Color(0xFF6C4EFF),
              ),

              const SizedBox(height: 16),

              const _ReportCard(
                itemName: 'Blue Notebook',
                type: 'Lost',
                category: 'Stationery',
                location: 'Classroom Block',
                date: '2 September 2026',
                status: 'Searching',
                statusColor: Color(0xFFB06A00),
              ),

              const SizedBox(height: 16),

              const _ReportCard(
                itemName: 'Black Water Bottle',
                type: 'Found',
                category: 'Other',
                location: 'Cafeteria',
                date: '28 August 2026',
                status: 'Verification Pending',
                statusColor: Color(0xFF2878A6),
              ),

              const SizedBox(height: 16),

              const _ReportCard(
                itemName: 'Calculator',
                type: 'Lost',
                category: 'Electronics',
                location: 'Science Block',
                date: '20 August 2026',
                status: 'Resolved',
                statusColor: Color(0xFF237A4B),
              ),

              const SizedBox(height: 30),

              Center(
                child: Text(
                  'Private identifying details are never displayed here.',
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

class _ReportCard extends StatelessWidget {
  final String itemName;
  final String type;
  final String category;
  final String location;
  final String date;
  final String status;
  final Color statusColor;

  const _ReportCard({
    required this.itemName,
    required this.type,
    required this.category,
    required this.location,
    required this.date,
    required this.status,
    required this.statusColor,
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
                      '$type • $category',
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
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
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

          const SizedBox(height: 18),

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
                'View Report',
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