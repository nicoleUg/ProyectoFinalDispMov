class OrderEntity {
  final String id;
  final double total;
  final String status;
  final DateTime createdAt;
  final List<OrderItemEntity> items;
  final bool isSynced;
  final int tableNumber;

  OrderEntity({
    required this.id,
    required this.total,
    required this.status, 
    required this.createdAt,
    required this.items,
    this.isSynced = false,
    this.tableNumber = 0,
  });
}

class OrderItemEntity {
  final String productName;
  final int quantity;
  OrderItemEntity({required this.productName, required this.quantity});
}