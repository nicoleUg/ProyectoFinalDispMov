class ReportDataEntity {
  final double totalEarnings;
  final int totalOrders;
  final List<PopularDishEntity> popularDishes;
  final List<DailySaleEntity> dailySales;

  ReportDataEntity({
    required this.totalEarnings,
    required this.totalOrders,
    required this.popularDishes,
    required this.dailySales,
  });
}

class PopularDishEntity {
  final String name;
  final int quantitySold;
  final double earnings;

  PopularDishEntity({
    required this.name,
    required this.quantitySold,
    required this.earnings,
  });
}

class DailySaleEntity {
  final String dayLabel;
  final double salesAmount;

  DailySaleEntity({
    required this.dayLabel,
    required this.salesAmount,
  });
}
