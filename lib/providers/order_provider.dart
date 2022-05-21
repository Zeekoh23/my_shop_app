import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/http_exception.dart';
import '../models/orders.dart';
import '../models/cart.dart';

class Orders with ChangeNotifier {
  var log = Logger();
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    try {
      final url =
          Uri.parse('http://10.0.2.2:3001/api/v1/orders?userid=$userId');
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<OrderItem> loadedOrders = [];

      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title'],
                  ),
                )
                .toList(),
          ),
        );
      });
      log.i(extractedData);
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (err) {
      throw HttpException('Fetch Order Error is $err');
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    try {
      var url = Uri.parse('http://10.0.2.2:3001/api/v1/orders');
      var url1 = Uri.parse('http://10.0.2.2:3001/api/v1/carts');
      final headers = {"Content-type": "application/json"};
      final res1 = await http.get(url1);
      final extract = json.decode(res1.body);
      final timestamp = DateTime.now();
      final res = await http.post(
        url,
        headers: headers,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
          'userid': userId,
        }),
      );
      final res2 = json.decode(res.body);
      log.i(res2);
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(res.body)['name'],
          amount: total,
          dateTime: timestamp,
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (err) {
      throw HttpException('Add Order Error is $err');
    }
  }
}
