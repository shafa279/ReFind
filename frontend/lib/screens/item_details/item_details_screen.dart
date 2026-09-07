import 'package:flutter/material.dart';

class ItemDetailsScreen extends StatelessWidget {
  const ItemDetailsScreen({super.key});

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
                'Item Details',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF171A2B),
                ),
              ),

              const SizedBox(height: 25),

              // ITEM CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFE8E9F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PHOTO PLACEHOLDER
                    Container(
                      width: double.infinity,
                      height: isMobile ? 220 : 300,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F1F6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 55,
                          color: Color(0xFF9A9CAB),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Black Wireless Headphones',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF171A2B),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Electronics',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF686B78),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const _DetailRow(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      value: 'Central Library',
                    ),

                    const SizedBox(height: 15),

                    const _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Date',
                      value: '5 September 2026',
                    ),

                    const SizedBox(height: 15),

                    const _DetailRow(
                      icon: Icons.access_time_outlined,
                      title: 'Approximate Time',
                      value: 'Afternoon',
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Public Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF171A2B),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Black wireless headphones reported near the Central Library.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Color(0xFF686B78),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // POTENTIAL MATCH
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF6C4EFF),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Potential Match',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF302A55),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'ReFind found a possible match for this item with a 94% similarity score.',
                      style: TextStyle(
                        color: Color(0xFF4D4968),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Potential match, not proof of ownership.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4D4968),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // PRIVACY NOTICE
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
                      Icons.lock_outline_rounded,
                      color: Color(0xFF6C4EFF),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Private identifying details are kept hidden and are only used during ownership verification.',
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

              const SizedBox(height: 25),

              // ACTION BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Verification request will be connected later.',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF171A2B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    'Start Verification',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF686B78),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    color: Color(0xFF171A2B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Color(0xFF686B78),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}