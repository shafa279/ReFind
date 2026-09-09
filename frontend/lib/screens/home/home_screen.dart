import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/primary_button.dart';
import '../report/report_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    _checkNotifications();
  }

  // =========================
  // CHECK UNREAD NOTIFICATIONS
  // =========================

  Future<void> _checkNotifications() async {
    final userId = AuthService.userId;

    if (userId == null) {
      return;
    }

    final notifications = await ApiService.getNotifications(userId);

    if (!mounted) return;

    final hasUnread = notifications.any(
      (notification) => notification['read'] == 0,
    );

    setState(() {
      hasUnreadNotifications = hasUnread;
    });
  }

  // =========================
  // SHOW NOTIFICATIONS
  // =========================

  Future<void> _showNotifications(BuildContext context) async {
    final userId = AuthService.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to view notifications.'),
        ),
      );
      return;
    }

    final notifications = await ApiService.getNotifications(userId);

    if (!mounted) return;

    // Mark unread notifications as read
    for (final notification in notifications) {
      final isUnread = notification['read'] == 0;
      final notificationId = notification['id'];

      if (isUnread && notificationId != null) {
        await ApiService.markNotificationAsRead(notificationId);
      }
    }

    if (!mounted) return;

    setState(() {
      hasUnreadNotifications = false;
    });

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.notifications_rounded,
                color: Color(0xFF6C4EFF),
              ),
              SizedBox(width: 10),
              Text('Notifications'),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: notifications.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    child: Text(
                      'You have no notifications.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 20),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEBFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF6C4EFF),
                          ),
                        ),
                        title: Text(
                          notification['message'] ??
                              'New notification',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: notification['created_at'] != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  notification['created_at'].toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF686B78),
                                  ),
                                ),
                              )
                            : null,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppNavigation(
              currentPage: 'Home',
            ),

            // Notification button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(
                  right: isMobile ? 20 : 70,
                  top: 8,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        _showNotifications(context);
                      },
                      tooltip: 'Notifications',
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF171A2B),
                      ),
                    ),
                    if (hasUnreadNotifications)
                      Positioned(
                        right: 7,
                        top: 6,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHero(context, isMobile),
                    _buildFeatures(context, isMobile),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 55 : 90,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1000,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBFF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'SMART CAMPUS LOST & FOUND',
                  style: TextStyle(
                    color: Color(0xFF6045D8),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                'LOST SOMETHING?\nLET\'S FIND IT.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(
                      fontSize: isMobile ? 38 : 58,
                      height: 1.05,
                    ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Find it. Verify it. Reclaim it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6C4EFF),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Lost something on campus? Found something that isn\'t yours? '
                'ReFind helps connect the two — simply, safely and intelligently.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF686B78),
                ),
              ),

              const SizedBox(height: 35),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  PrimaryButton(
                    text: 'I Lost Something',
                    icon: Icons.search_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportItemScreen(
                            initialIsLost: true,
                          ),
                        ),
                      );
                    },
                  ),

                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportItemScreen(
                            initialIsLost: false,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.inventory_2_outlined,
                    ),
                    label: const Text(
                      'I Found Something',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatures(
    BuildContext context,
    bool isMobile,
  ) {
    final features = [
      const _FeatureData(
        icon: Icons.auto_awesome_rounded,
        title: 'AI-Powered Matching',
        description:
            'Smart matching helps identify possible connections between lost and found reports.',
      ),
      const _FeatureData(
        icon: Icons.lock_outline_rounded,
        title: 'Private Verification',
        description:
            'Private identifying details stay hidden and are only used during ownership verification.',
      ),
      const _FeatureData(
        icon: Icons.school_outlined,
        title: 'Built for Your Campus',
        description:
            'A simple lost-and-found system designed specifically for your college community.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 55,
      ),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: Column(
            children: [
              Text(
                'Why ReFind?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 10),

              const Text(
                'Designed to make campus lost-and-found faster, safer and smarter.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF686B78),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 35),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 700) {
                    return Column(
                      children: features
                          .map(
                            (feature) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 16),
                              child: _FeatureCard(
                                feature: feature,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }

                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: features
                        .map(
                          (feature) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: _FeatureCard(
                                feature: feature,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 35,
      ),
      color: const Color(0xFF171A2B),
      child: const Column(
        children: [
          Text(
            'ReFind',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Lost things deserve a way home.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// FEATURE DATA
// =========================

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// =========================
// FEATURE CARD
// =========================

class _FeatureCard extends StatelessWidget {
  final _FeatureData feature;

  const _FeatureCard({
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8E9F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature.icon,
              color: const Color(0xFF6C4EFF),
              size: 23,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            feature.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171A2B),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            feature.description,
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