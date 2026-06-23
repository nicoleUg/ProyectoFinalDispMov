import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../../domain/entities/report_data_entity.dart';
import '../bloc/admin_reports_bloc.dart';
import '../bloc/admin_reports_event.dart';
import '../bloc/admin_reports_state.dart';
import '../widgets/admin_drawer.dart';

class ReporteDeVentasAppAdmin extends StatefulWidget {
  const ReporteDeVentasAppAdmin({super.key});

  @override
  State<ReporteDeVentasAppAdmin> createState() => _ReporteDeVentasAppAdminState();
}

class _ReporteDeVentasAppAdminState extends State<ReporteDeVentasAppAdmin> {
  String _currentPeriod = 'today';

  @override
  void initState() {
    super.initState();
    // Load initial report data
    context.read<AdminReportsBloc>().add(LoadReportDataRequested(period: _currentPeriod));
  }

  void _onPeriodChanged(String period) {
    if (_currentPeriod != period) {
      setState(() {
        _currentPeriod = period;
      });
      context.read<AdminReportsBloc>().add(LoadReportDataRequested(period: period));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: RSColors.background,
      body: Row(
        children: [
          if (isDesktop)
            const AdminDrawer(activeRoute: '/admin-reports', isMobileDrawer: false),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isDesktop),
                Expanded(
                  child: BlocBuilder<AdminReportsBloc, AdminReportsState>(
                    builder: (context, state) {
                      if (state is AdminReportsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: RSColors.primary),
                        );
                      }

                      if (state is AdminReportsError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: RSColors.error),
                              RSSpacing.verticalMd,
                              Text(
                                state.error,
                                style: RSTypography.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              RSSpacing.verticalMd,
                              RSButton.filled(
                                label: 'Reintentar',
                                onPressed: () {
                                  context.read<AdminReportsBloc>().add(
                                        LoadReportDataRequested(period: _currentPeriod),
                                      );
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is AdminReportsLoaded) {
                        final reportData = state.reportData;
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(RSSpacing.lg),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 1200),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPeriodSelector(),
                                  RSSpacing.verticalLg,
                                  _buildSummaryRow(reportData),
                                  RSSpacing.verticalLg,
                                  _buildChartsSection(reportData, isDesktop),
                                  RSSpacing.verticalLg,
                                  _buildPopularDishesTable(reportData),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildMobileBottomNav(),
    );
  }



  Widget _buildHeader(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (!isDesktop)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/admin-dashboard'),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reporte de Ventas',
                  style: RSTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Análisis detallado de ingresos y platos populares.',
                  style: RSTypography.bodyMedium.copyWith(
                    color: RSColors.textOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        RSChoiceChip(
          label: 'Hoy',
          selected: _currentPeriod == 'today',
          onSelected: (selected) => _onPeriodChanged('today'),
        ),
        const SizedBox(width: 8),
        RSChoiceChip(
          label: 'Esta Semana',
          selected: _currentPeriod == 'week',
          onSelected: (selected) => _onPeriodChanged('week'),
        ),
        const SizedBox(width: 8),
        RSChoiceChip(
          label: 'Este Mes',
          selected: _currentPeriod == 'month',
          onSelected: (selected) => _onPeriodChanged('month'),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(ReportDataEntity reportData) {
    final earnings = reportData.totalEarnings;
    final orders = reportData.totalOrders;
    final avgTicket = orders > 0 ? (earnings / orders) : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 32) / 3;
        final isTooNarrow = constraints.maxWidth < 600;

        final children = [
          _buildSummaryCard(
            'Ingresos Totales',
            '\$${earnings.toStringAsFixed(2)}',
            Icons.attach_money,
            const Color(0xFF1B5E20),
            isTooNarrow ? double.infinity : cardWidth,
          ),
          _buildSummaryCard(
            'Órdenes Totales',
            '$orders',
            Icons.shopping_cart,
            const Color(0xFF0D47A1),
            isTooNarrow ? double.infinity : cardWidth,
          ),
          _buildSummaryCard(
            'Ticket Promedio',
            '\$${avgTicket.toStringAsFixed(2)}',
            Icons.receipt,
            const Color(0xFFE65100),
            isTooNarrow ? double.infinity : cardWidth,
          ),
        ];

        if (isTooNarrow) {
          return Column(
            children: children.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: c,
            )).toList(),
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          );
        }
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, double width) {
    return SizedBox(
      width: width,
      child: GFKpiCard(
        title: title,
        value: value,
        icon: icon,
        accentColor: color,
      ),
    );
  }

  Widget _buildChartsSection(ReportDataEntity reportData, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildLineChartCard(reportData.dailySales)),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildPieChartCard(reportData.popularDishes)),
        ],
      );
    } else {
      return Column(
        children: [
          _buildLineChartCard(reportData.dailySales),
          const SizedBox(height: 16),
          _buildPieChartCard(reportData.popularDishes),
        ],
      );
    }
  }

  Widget _buildLineChartCard(List<DailySaleEntity> dailySales) {
    if (dailySales.isEmpty) {
      return RSCard(
        padding: const EdgeInsets.all(RSSpacing.lg),
        child: const Center(
          child: Text('No hay datos de ventas disponibles para este período.'),
        ),
      );
    }

    final spots = List.generate(dailySales.length, (index) {
      return FlSpot(index.toDouble(), dailySales[index].salesAmount);
    });

    double maxSales = 100.0;
    for (var sale in dailySales) {
      if (sale.salesAmount > maxSales) {
        maxSales = sale.salesAmount;
      }
    }
    // Round max sales up to give some padding at the top
    maxSales = (maxSales * 1.15).ceilToDouble();

    return RSCard(
      padding: const EdgeInsets.all(RSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendencia de Ventas',
            style: RSTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            'Ingresos generados a lo largo del período seleccionado.',
            style: RSTypography.bodyMedium.copyWith(color: RSColors.textOnSurfaceVariant),
          ),
          const Divider(height: 24),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: RSColors.outlineVariant.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: RSTypography.labelSmall.copyWith(color: RSColors.textOnSurfaceVariant),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dailySales.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dailySales[index].dayLabel,
                              style: RSTypography.labelSmall.copyWith(
                                color: RSColors.textOnSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: RSColors.outlineVariant.withValues(alpha: 0.5), width: 1),
                    left: BorderSide(color: RSColors.outlineVariant.withValues(alpha: 0.5), width: 1),
                  ),
                ),
                minX: 0,
                maxX: (dailySales.length - 1).toDouble(),
                minY: 0,
                maxY: maxSales,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: RSColors.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: RSColors.primary,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: RSColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(List<PopularDishEntity> popularDishes) {
    if (popularDishes.isEmpty) {
      return RSCard(
        padding: const EdgeInsets.all(RSSpacing.lg),
        child: const Center(
          child: Text('No hay información de platos vendidos.'),
        ),
      );
    }

    final totalQuantity = popularDishes.fold<int>(0, (sum, item) => sum + item.quantitySold);

    final colors = [
      RSColors.primary,
      RSColors.primaryContainer,
      const Color(0xFF0D47A1),
      const Color(0xFF1B5E20),
      const Color(0xFFE65100),
    ];

    return RSCard(
      padding: const EdgeInsets.all(RSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución de Platos',
            style: RSTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            'Participación de los platos más vendidos.',
            style: RSTypography.bodyMedium.copyWith(color: RSColors.textOnSurfaceVariant),
          ),
          const Divider(height: 24),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: List.generate(popularDishes.length, (index) {
                      final dish = popularDishes[index];
                      final pct = totalQuantity > 0 ? (dish.quantitySold / totalQuantity) * 100 : 0.0;
                      final color = colors[index % colors.length];

                      return PieChartSectionData(
                        color: color,
                        value: dish.quantitySold.toDouble(),
                        title: '${pct.toStringAsFixed(0)}%',
                        radius: 40,
                        titleStyle: RSTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(popularDishes.length, (index) {
                    final dish = popularDishes[index];
                    final color = colors[index % colors.length];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dish.name,
                              style: RSTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${dish.quantitySold})',
                            style: RSTypography.labelSmall.copyWith(color: RSColors.textOnSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDishesTable(ReportDataEntity reportData) {
    final popularDishes = reportData.popularDishes;

    return RSCard(
      padding: const EdgeInsets.all(RSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalle de Platos Más Vendidos',
            style: RSTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: RSColors.outlineVariant.withValues(alpha: 0.5))),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Plato',
                      style: RSTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Cant.',
                      style: RSTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Ingresos',
                      style: RSTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              ...popularDishes.map((dish) {
                return TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: RSColors.outlineVariant.withValues(alpha: 0.1))),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        dish.name,
                        style: RSTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        '${dish.quantitySold}',
                        style: RSTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        '\$${dish.earnings.toStringAsFixed(2)}',
                        style: RSTypography.bodyMedium.copyWith(
                          color: RSColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: RSColors.surfaceContainerLow,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: BottomNavigationBar(
        currentIndex: 0, // Maps to Home/Reports
        onTap: (index) {
          if (index == 0) context.go('/admin-dashboard');
          if (index == 1) context.go('/admin-menu');
          if (index == 2) context.go('/admin-orders');
        },
        selectedItemColor: RSColors.primary,
        unselectedItemColor: RSColors.textOnSurfaceVariant,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}

// Simple KPI Card wrapper using design system widgets
class GFKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const GFKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return RSCard(
      padding: const EdgeInsets.all(RSSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: RSTypography.labelMedium.copyWith(color: RSColors.textOnSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: RSTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
