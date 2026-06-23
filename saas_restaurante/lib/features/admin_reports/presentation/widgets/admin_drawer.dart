import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../../../auth/presentation/pages/logout_dialog.dart';

class AdminDrawer extends StatelessWidget {
  final String activeRoute;
  final bool isMobileDrawer;

  const AdminDrawer({
    super.key,
    required this.activeRoute,
    this.isMobileDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: RSColors.surfaceContainerLow,
        borderRadius: isMobileDrawer
            ? null
            : const BorderRadius.only(
                topRight: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
        boxShadow: isMobileDrawer
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Restaurante SaaS',
                  style: RSTypography.titleLarge.copyWith(
                    color: RSColors.primary,
                  ),
                ),
                RSSpacing.verticalMd,
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: RSColors.outlineVariant.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.store, color: RSColors.textOnSurfaceVariant),
                    ),
                    RSSpacing.horizontalSm,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sucursal #104 - Admin',
                          style: RSTypography.titleSmall.copyWith(
                            color: RSColors.textOnSurfaceVariant,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: RSColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            RSSpacing.horizontalSm,
                            Text(
                              'Activo',
                              style: RSTypography.labelSmall.copyWith(
                                color: RSColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDrawerItem(
            context,
            Icons.dashboard,
            'Dashboard',
            activeRoute == '/admin-dashboard',
            () => _navigate(context, '/admin-dashboard'),
          ),
          _buildDrawerItem(
            context,
            Icons.restaurant_menu,
            'Editor de Menú',
            activeRoute == '/admin-menu',
            () => _navigate(context, '/admin-menu'),
          ),
          _buildDrawerItem(
            context,
            Icons.receipt_long,
            'Tablero de Cocina',
            activeRoute == '/admin-orders',
            () => _navigate(context, '/admin-orders'),
          ),
          _buildDrawerItem(
            context,
            Icons.bar_chart,
            'Reportes de Venta',
            activeRoute == '/admin-reports',
            () => _navigate(context, '/admin-reports'),
          ),
          const Divider(indent: 16, endIndent: 16),
          _buildDrawerItem(
            context,
            Icons.logout,
            'Cerrar Sesión',
            false,
            () {
              if (isMobileDrawer) {
                Navigator.of(context).pop(); // Close drawer first
              }
              showDialog(
                context: context,
                builder: (context) => const LogoutDialog(),
              );
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'v1.0.0-SaaS',
              style: RSTypography.labelSmall.copyWith(
                color: RSColors.textOnSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    if (isMobileDrawer) {
      Navigator.of(context).pop(); // Close mobile drawer
    }
    context.go(route);
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? RSColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? RSColors.primary : RSColors.textOnSurfaceVariant,
        ),
        title: Text(
          title,
          style: RSTypography.titleSmall.copyWith(
            color: isActive ? RSColors.primary : RSColors.textOnSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
