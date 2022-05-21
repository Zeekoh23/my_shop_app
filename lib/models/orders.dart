import 'package:mongo_dart/mongo_dart.dart';

class OrderItem {
  final String? id1;
  int? orderid1;
  final ObjectId? id;
  final double amount;
  final List<dynamic> products;
  final DateTime dateTime;

  OrderItem({
    this.id1,
    this.orderid1,
    this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}
