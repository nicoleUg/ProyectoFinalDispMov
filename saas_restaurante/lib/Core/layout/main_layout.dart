import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/logout_dialog.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final primary = const Color(0xFFB02F00);
    final primaryContainer = const Color(0xFFFF5722);

    final authState = context.watch<AuthBloc>().state;
    String userName = 'Cliente';
    String userEmail = 'cliente@restaurante.com';
    if (authState is AuthAuthenticated && authState.user != null) {
      userName = authState.user!.fullName;
      userEmail = authState.user!.email;
    }

    return Scaffold(
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              accountName: Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                userEmail,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.home_filled,
                    title: 'Inicio',
                    isSelected: location == '/',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go('/');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.favorite,
                    title: 'Mis Favoritos',
                    isSelected: location == '/favorites',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go('/favorites');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long,
                    title: 'Mis Pedidos',
                    isSelected: location.startsWith('/orders'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go('/orders');
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _DrawerItem(
                    icon: Icons.info_outline,
                    title: 'Acerca de Nosotros',
                    isSelected: location == '/about-us',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go('/about-us');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.gavel_rounded,
                    title: 'Términos y Condiciones',
                    isSelected: location == '/terms',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go('/terms');
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) => const LogoutDialog(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/scanner'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        tooltip: 'Escanear QR de mesa',
        elevation: 4,
        child: const Icon(Icons.qr_code_scanner_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                  icon: Icons.favorite,
                  label: 'Favoritos',
                  isActive: location == '/favorites',
                  activeColor: primaryContainer,
                  onTap: () => context.go('/favorites'),
                ),
                const SizedBox(width: 48),
                _NavItem(
                  icon: Icons.receipt_long,
                  label: 'Pedidos',
                  isActive: location.startsWith('/orders'),
                  activeColor: primaryContainer,
                  onTap: () => context.go('/orders'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFFF5722);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? activeColor : Colors.grey.shade600,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? activeColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: activeColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
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