import 'package:drift/drift.dart';
import '../../../../Core/database/app_database.dart';
import '../../../../Core/network/api_client.dart';
import '../../domain/entities/report_data_entity.dart';
import '../../domain/repositories/admin_reports_repository.dart';

class AdminReportsRepositoryImpl implements AdminReportsRepository {
  final AppDatabase db;
  final ApiClient apiClient;

  AdminReportsRepositoryImpl({required this.db, required this.apiClient});

  @override
  Future<ReportDataEntity> getReportData(String period) async {
    // 1. Intentar sincronizar pedidos desde el backend remoto para asegurar datos reales
    try {
      final response = await apiClient.dio.get('/orders');
      final List<dynamic> data = response.data;
      print('[AdminReportsRepository] Sincronizando ${data.length} pedidos desde el backend para reportes...');

      for (var json in data) {
        final orderId = json['id'] as String;
        final total = (json['total'] as num).toDouble();
        final status = json['status'] as String;
        final tableNumber = json['tableNumber'] as int? ?? 0;
        final createdAt = json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now();

        // Guardar o actualizar pedido local
        await db.into(db.ordersTable).insertOnConflictUpdate(OrdersTableCompanion(
              id: Value(orderId),
              total: Value(total),
              status: Value(status),
              createdAt: Value(createdAt),
              isSynced: const Value(true),
              tableNumber: Value(tableNumber),
            ));

        // Actualizar items locales para este pedido
        await (db.delete(db.orderItemsTable)..where((t) => t.orderId.equals(orderId))).go();

        final List<dynamic> itemsJson = json['items'] as List<dynamic>? ?? [];
        for (var item in itemsJson) {
          await db.into(db.orderItemsTable).insert(OrderItemsTableCompanion(
                orderId: Value(orderId),
                productName: Value(item['name'] as String),
                quantity: Value(item['qty'] as int),
              ));
        }
      }
    } catch (e) {
      print('[AdminReportsRepository] Sincronización remota de reportes omitida ($e). Usando agregación de base de datos local existente.');
    }

    // 2. Query all local orders
    final allOrders = await (db.select(db.ordersTable)).get();
    
    if (allOrders.isEmpty) {
      return ReportDataEntity(
        totalEarnings: 0.0,
        totalOrders: 0,
        popularDishes: const [],
        dailySales: const [],
      );
    }

    // 3. Define cutoff date based on period
    final now = DateTime.now();
    DateTime cutoff;
    if (period == 'today') {
      cutoff = DateTime(now.year, now.month, now.day);
    } else if (period == 'week') {
      cutoff = now.subtract(const Duration(days: 7));
    } else {
      cutoff = now.subtract(const Duration(days: 30));
    }

    // 4. Filter orders
    final filteredOrders = allOrders.where((o) => o.createdAt.isAfter(cutoff)).toList();
    if (filteredOrders.isEmpty) {
      return ReportDataEntity(
        totalEarnings: 0.0,
        totalOrders: 0,
        popularDishes: const [],
        dailySales: const [],
      );
    }

    // 5. Aggregate earnings & count
    final totalEarnings = filteredOrders.fold(0.0, (sum, o) => sum + o.total);
    final totalOrdersCount = filteredOrders.length;

    // 6. Aggregate popular dishes
    final Map<String, int> dishQuantities = {};
    for (var order in filteredOrders) {
      final localItems = await (db.select(db.orderItemsTable)
            ..where((t) => t.orderId.equals(order.id)))
          .get();
      for (var item in localItems) {
        dishQuantities[item.productName] = (dishQuantities[item.productName] ?? 0) + item.quantity;
      }
    }

    // Lookup product prices to calculate earnings per dish
    final products = await (db.select(db.productsTable)).get();
    final Map<String, double> productPrices = {
      for (var p in products) p.name: p.price
    };

    final List<PopularDishEntity> popularDishes = [];
    final sortedDishes = dishQuantities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Limit to top 5 popular dishes
    for (var entry in sortedDishes.take(5)) {
      final qty = entry.value;
      final price = productPrices[entry.key] ?? 12.0; // Default price if not found
      popularDishes.add(PopularDishEntity(
        name: entry.key,
        quantitySold: qty,
        earnings: qty * price,
      ));
    }

    // 7. Group sales by date labels for charts
    final Map<String, double> salesByGroup = {};
    if (period == 'today') {
      // Group by hour blocks
      for (var o in filteredOrders) {
        final hourStr = '${o.createdAt.hour.toString().padLeft(2, '0')}:00';
        salesByGroup[hourStr] = (salesByGroup[hourStr] ?? 0.0) + o.total;
      }
    } else if (period == 'week') {
      // Group by weekday name
      final days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
      for (var o in filteredOrders) {
        final label = days[o.createdAt.weekday % 7];
        salesByGroup[label] = (salesByGroup[label] ?? 0.0) + o.total;
      }
    } else {
      // Group by day of month
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      for (var o in filteredOrders) {
        final label = '${o.createdAt.day} ${months[o.createdAt.month - 1]}';
        salesByGroup[label] = (salesByGroup[label] ?? 0.0) + o.total;
      }
    }

    // Convert map to DailySaleEntity list
    final List<DailySaleEntity> dailySales = salesByGroup.entries
        .map((e) => DailySaleEntity(dayLabel: e.key, salesAmount: e.value))
        .toList();

    // Sort chart data chronologically (hours/days)
    if (period != 'week') {
      dailySales.sort((a, b) => a.dayLabel.compareTo(b.dayLabel));
    }

    return ReportDataEntity(
      totalEarnings: totalEarnings,
      totalOrders: totalOrdersCount,
      popularDishes: popularDishes,
      dailySales: dailySales,
    );
  }
}
