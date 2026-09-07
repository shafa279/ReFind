import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF171A2B),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Manage reports, matches, and verification activity.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF686B78),
                ),
              ),

              const SizedBox(height: 30),

              // STATISTICS
              GridView.count(
                crossAxisCount: isMobile ? 1 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isMobile ? 3.2 : 1.7,
                children: const [
                  _StatCard(
                    title: 'Total Reports',
                    value: '128',
                    icon: Icons.description_outlined,
                  ),
                  _StatCard(
                    title: 'Potential Matches',
                    value: '34',
                    icon: Icons.auto_awesome_outlined,
                  ),
                  _StatCard(
                    title: 'Pending Verification',
                    value: '12',
                    icon: Icons.pending_actions_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171A2B),
                ),
              ),

              const SizedBox(height: 15),

              const _ActivityCard(
                icon: Icons.report_outlined,
                title: 'New lost item reported',
                subtitle: 'Black Wireless Headphones • Central Library',
                time: '10 minutes ago',
              ),

              const _ActivityCard(
                icon: Icons.auto_awesome_outlined,
                title: 'Potential match detected',
                subtitle: 'Wireless Headphones • 94% similarity',
                time: '32 minutes ago',
              ),

              const _ActivityCard(
                icon: Icons.verified_outlined,
                title: 'Verification completed',
                subtitle: 'Calculator • Science Block',
                time: '1 hour ago',
              ),

              const SizedBox(height: 30),

              // ADMIN NOTICE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE8E9F0),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.security_outlined,
                      color: Color(0xFF6C4EFF),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Admin access is intended for authorized campus staff. '
                        'Private identifying details should only be used during verification.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF686B78),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E9F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6C4EFF),
            ),
          ),

          const SizedBox(width: 14),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF171A2B),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF686B78),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E9F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6C4EFF),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF171A2B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF686B78),
                  ),
                ),
              ],
            ),
          ),

          if (MediaQuery.of(context).size.width >= 600)
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9294A0),
              ),
            ),
        ],
      ),
    );
  }
}