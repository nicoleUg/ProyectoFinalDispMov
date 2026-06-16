import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart'; 

class CartItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  IntColumn get quantity => integer()();
  RealColumn get price => real()();
}

class OrdersTable extends Table {
  TextColumn get id => text()(); 
  RealColumn get total => real()();
  TextColumn get status => text()(); 
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class OrderItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderId => text().references(OrdersTable, #id)();
  TextColumn get productName => text()();
  IntColumn get quantity => integer()();
}

class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class ProductsTable extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(CategoriesTable, #id)(); 
  TextColumn get name => text()();
  TextColumn get description => text()();
  RealColumn get price => real()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CartItems, CategoriesTable, ProductsTable, OrdersTable, OrderItemsTable]) 
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'restauranteX_db'));

  @override
  int get schemaVersion => 3; 
}
