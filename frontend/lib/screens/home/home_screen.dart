import 'package:flutter/material.dart';

import '../report/report_item_screen.dart';
import '../my_reports/my_reports_screen.dart';
import '../matches/matches_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // NAVIGATION BAR
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 70,
                  vertical: 24,
                ),
                child: Row(
                  children: [
                    // LOGO
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF171A2B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_outward_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'ReFind',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF171A2B),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    if (!isMobile) ...[
                      // HOME
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Home',
                          style: TextStyle(
                            color: Color(0xFF171A2B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // MATCHES
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MatchesScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Matches',
                          style: TextStyle(
                            color: Color(0xFF686B78),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // MY REPORTS
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyReportsScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'My Reports',
                          style: TextStyle(
                            color: Color(0xFF686B78),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // LOGIN
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          side: const BorderSide(
                            color: Color(0xFFD9DBE5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF171A2B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else
                      // MOBILE MENU
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu_rounded),
                      ),
                  ],
                ),
              ),

              // HERO SECTION
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 70,
                  vertical: isMobile ? 50 : 80,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEBFF),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: Color(0xFF6C4EFF),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'SMART CAMPUS LOST & FOUND',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: Color(0xFF6C4EFF),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'LOST SOMETHING?\nLET\'S FIND IT.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 42 : 68,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        color: const Color(0xFF171A2B),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Find it. Verify it. Reclaim it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6C4EFF),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const SizedBox(
                      width: 650,
                      child: Text(
                        'Lost something on campus? Found something that isn\'t yours? '
                        'ReFind helps connect the two — simply, safely and intelligently.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Color(0xFF686B78),
                        ),
                      ),
                    ),

                    const SizedBox(height: 38),

                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      alignment: WrapAlignment.center,
                      children: [
                        // I LOST SOMETHING
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReportItemScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('I Lost Something'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF171A2B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        // I FOUND SOMETHING
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReportItemScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.volunteer_activism_rounded,
                          ),
                          label: const Text('I Found Something'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF171A2B),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            side: const BorderSide(
                              color: Color(0xFFD9DBE5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // FEATURE CARDS
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 24 : 70,
                  20,
                  isMobile ? 24 : 70,
                  80,
                ),
                child: Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  alignment: WrapAlignment.center,
                  children: const [
                    _FeatureCard(
                      icon: Icons.auto_awesome_rounded,
                      title: 'AI-powered matching',
                      description:
                          'Smart matching helps connect lost items with their possible owners.',
                    ),
                    _FeatureCard(
                      icon: Icons.verified_user_outlined,
                      title: 'Private verification',
                      description:
                          'Ownership can be verified before an item is returned.',
                    ),
                    _FeatureCard(
                      icon: Icons.school_outlined,
                      title: 'Built for your campus',
                      description:
                          'A simple lost-and-found system designed around campus life.',
                    ),
                  ],
                ),
              ),

              // FOOTER
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 70,
                  vertical: 45,
                ),
                color: const Color(0xFF171A2B),
                child: Column(
                  children: [
                    const Text(
                      'ReFind',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Lost things deserve a way home.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      padding: const EdgeInsets.all(24),
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6C4EFF),
              size: 23,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171A2B),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF686B78),
            ),
          ),
        ],
      ),
    );
  }
}