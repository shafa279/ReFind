import 'package:flutter/material.dart';

class AppNavigation extends StatelessWidget {
  final String currentPage;

  const AppNavigation({super.key, this.currentPage = 'Home'});

  void _navigate(BuildContext context, String page) {
    switch (page) {
      case 'Home':
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        break;

      case 'Matches':
        Navigator.pushNamed(context, '/matches');
        break;

      case 'My Reports':
        Navigator.pushNamed(context, '/my-reports');
        break;

      case 'Login':
        Navigator.pushNamed(context, '/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    if (isMobile) {
      return _buildMobileNavigation(context);
    }

    return _buildDesktopNavigation(context);
  }

  Widget _buildDesktopNavigation(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8E9F0))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigate(context, 'Home'),
            child: Row(
              children: [
                const ReFindLogo(size: 38),
                const SizedBox(width: 10),
                const Text(
                  'ReFind',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF171A2B),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          _NavItem(
            label: 'Home',
            isSelected: currentPage == 'Home',
            onTap: () => _navigate(context, 'Home'),
          ),
          _NavItem(
            label: 'Matches',
            isSelected: currentPage == 'Matches',
            onTap: () => _navigate(context, 'Matches'),
          ),
          _NavItem(
            label: 'My Reports',
            isSelected: currentPage == 'My Reports',
            onTap: () => _navigate(context, 'My Reports'),
          ),

          const SizedBox(width: 18),

          ElevatedButton(
            onPressed: () => _navigate(context, 'Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF171A2B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavigation(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8E9F0))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigate(context, 'Home'),
            child: Row(
              children: [
                const ReFindLogo(size: 34),
                const SizedBox(width: 9),
                const Text(
                  'ReFind',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF171A2B),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          PopupMenuButton<String>(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF171A2B)),
            onSelected: (page) {
              _navigate(context, page);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Home', child: Text('Home')),
              PopupMenuItem(value: 'Matches', child: Text('Matches')),
              PopupMenuItem(value: 'My Reports', child: Text('My Reports')),
              PopupMenuItem(value: 'Login', child: Text('Login')),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: isSelected
              ? const Color(0xFF6C4EFF)
              : const Color(0xFF686B78),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// The ReFind mark: a magnifying glass containing the green R/location pin.
/// It is vector-based so it remains sharp on every screen size.
class ReFindLogo extends StatelessWidget {
  final double size;

  const ReFindLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size * .76,
            height: size * .76,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9F4),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF20A66A),
                width: size * .08,
              ),
            ),
            child: Center(
              child: Text(
                'R',
                style: TextStyle(
                  color: const Color(0xFF138C55),
                  fontSize: size * .43,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
          Positioned(
            right: size * .02,
            bottom: size * .02,
            child: Transform.rotate(
              angle: -.78,
              child: Container(
                width: size * .13,
                height: size * .4,
                decoration: BoxDecoration(
                  color: const Color(0xFF20A66A),
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
            ),
          ),
          Positioned(
            right: size * .15,
            top: size * .05,
            child: Icon(
              Icons.location_on_rounded,
              color: const Color(0xFF20A66A),
              size: size * .2,
            ),
          ),
        ],
      ),
    );
  }
}
