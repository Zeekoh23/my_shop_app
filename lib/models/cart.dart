import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/foundation.dart';

class CartItem with ChangeNotifier {
  final String? id;
  final int? myid;
  final ObjectId? id1;
  String title;
  int quantity;
  double price;
  final String? orderid;

  CartItem(
      {this.id1,
      this.myid,
      this.id,
      required this.title,
      required this.quantity,
      required this.price,
      this.orderid});
}
