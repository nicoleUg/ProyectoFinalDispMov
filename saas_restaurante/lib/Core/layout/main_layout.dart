import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final primary = const Color(0xFFB02F00);
    final primaryContainer = const Color(0xFFFF5722);

    return Scaffold(
      body: child, 
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F5), 
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_filled,
                  label: 'Home',
                  isActive: location == '/',
                  activeColor: primaryContainer,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: Icons.receipt_long,
                  label: 'Orders',
                  isActive: location.startsWith('/orders'),
                  activeColor: primaryContainer,
                  onTap: () => context.go('/orders'),
                ),
                _NavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isActive: location.startsWith('/profile'),
                  activeColor: primaryContainer,
                  onTap: () {
                    // módulo de perfil
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.label, required this.isActive, 
    required this.activeColor, required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? activeColor.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: isActive ? activeColor : Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black87 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}