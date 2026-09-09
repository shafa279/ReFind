import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 64,
            vertical: isMobile ? 22 : 34,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back'),
                  ),
                  const SizedBox(height: 18),
                  _buildHeader(context, isMobile),
                  const SizedBox(height: 28),
                  _buildStatistics(isMobile),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    title: 'Recent activity',
                    subtitle:
                        'A quick view of new reports, match detection, and verification progress.',
                  ),
                  const SizedBox(height: 16),
                  const _ActivityCard(
                    icon: Icons.report_outlined,
                    iconColor: Color(0xFF6C4EFF),
                    iconBackground: Color(0xFFF0EBFF),
                    title: 'New lost item reported',
                    subtitle: 'Black Wireless Headphones · Central Library',
                    time: '10 minutes ago',
                  ),
                  const _ActivityCard(
                    icon: Icons.auto_awesome_outlined,
                    iconColor: Color(0xFF2E7D5A),
                    iconBackground: Color(0xFFEAF8F0),
                    title: 'Potential match detected',
                    subtitle: 'Wireless Headphones · 94% similarity',
                    time: '32 minutes ago',
                  ),
                  const _ActivityCard(
                    icon: Icons.verified_outlined,
                    iconColor: Color(0xFF3155D9),
                    iconBackground: Color(0xFFF0F4FF),
                    title: 'Verification completed',
                    subtitle: 'Calculator · Science Block',
                    time: '1 hour ago',
                  ),
                  const SizedBox(height: 28),
                  _buildSecurityNotice(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
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
              'AUTHORIZED STAFF AREA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Admin Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: isMobile ? 30 : 38,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Monitor reports, review matching activity, and support secure ownership verification.',
            style: TextStyle(
              color: Color(0xFFD0D2DE),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_outlined,
                color: Color(0xFFA997FF),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Private details are protected during verification.',
                style: TextStyle(
                  color: Color(0xFFD0D2DE),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 650;

        return GridView.count(
          crossAxisCount: isCompact ? 1 : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isCompact ? 3.4 : 1.45,
          children: const [
            _StatCard(
              title: 'Total Reports',
              value: '128',
              description: 'Submitted across campus',
              icon: Icons.description_outlined,
              color: Color(0xFF6C4EFF),
              backgroundColor: Color(0xFFF0EBFF),
            ),
            _StatCard(
              title: 'Potential Matches',
              value: '34',
              description: 'Awaiting user review',
              icon: Icons.auto_awesome_outlined,
              color: Color(0xFF2E7D5A),
              backgroundColor: Color(0xFFEAF8F0),
            ),
            _StatCard(
              title: 'Pending Verification',
              value: '12',
              description: 'Require staff attention',
              icon: Icons.pending_actions_outlined,
              color: Color(0xFFB25A00),
              backgroundColor: Color(0xFFFFF4E5),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF171A2B),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF686B78),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            Icons.security_outlined,
            color: Color(0xFF6C4EFF),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy and verification reminder',
                  style: TextStyle(
                    color: Color(0xFF302A55),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Admin access is intended for authorized campus staff. Private identifying details should only be used to confirm ownership during the verification process.',
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
    required this.backgroundColor,
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF171A2B),
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF171A2B),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF8A8D99),
                    fontSize: 12,
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

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final showTime = MediaQuery.of(context).size.width >= 600;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8E9F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
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
                    color: Color(0xFF171A2B),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF686B78),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (!showTime) ...[
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF9294A0),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showTime) ...[
            const SizedBox(width: 14),
            Text(
              time,
              style: const TextStyle(
                color: Color(0xFF9294A0),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}