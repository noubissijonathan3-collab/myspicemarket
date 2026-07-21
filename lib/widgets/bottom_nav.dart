import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(Icons.home, "Home", true),
          _NavItem(Icons.favorite_border, "Favorites", false),
          _NavItem(Icons.receipt_long, "Orders", false),
          _NavItem(Icons.notifications_none, "Alerts", false),
          _NavItem(Icons.person_outline, "Profile", false),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem(
      this.icon,
      this.label,
      this.selected,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: selected
              ? const Color(0xFF006E2F)
              : const Color(0xFF6B7280),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w400,
            color: selected
                ? const Color(0xFF006E2F)
                : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}