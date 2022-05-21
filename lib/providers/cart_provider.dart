import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/cart.dart';
import '../models/http_exception.dart';

class Cart with ChangeNotifier {
  var log = Logger();
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  final String authToken;
  final String userId;
  Cart(this.authToken, this.userId);

  Future<void> addItem(
    String productId,
    double price,
    String title,
  ) async {
    try {
      var cart = CartItem(
        id: '',
        title: '',
        price: 0,
        quantity: 0,
      );
      final headers = {"Content-type": "application/json"};
      if (_items.containsKey(productId)) {
        final url = Uri.parse('http://10.0.2.2:3001/api/v1/carts/$productId');
        // change quantity...
        _items.update(
          productId,
          (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: cart.title = existingCartItem.title,
            price: cart.price = existingCartItem.price,
            quantity: cart.quantity = existingCartItem.quantity + 1,
          ),
        );
        final response = await http.post(url,
            headers: headers,
            body: json.encode({
              'title': cart.title,
              'price': cart.price,
              'quantity': cart.quantity
            }));
        final responseData = json.decode(response.body);
        log.i(responseData);
      } else {
        final url = Uri.parse('http://10.0.2.2:3001/api/v1/carts');

        _items.putIfAbsent(
          productId,
          () => CartItem(
            id: DateTime.now().toString(),
            title: title,
            price: price,
            quantity: 1,
          ),
        );
        final response = await http.post(url,
            headers: headers,
            body: json.encode({
              'title': title,
              'price': price,
              'quantity': 1,
              'userid': userId
            }));
        final responseData = json.decode(response.body);
        log.d(responseData);
      }
      notifyListeners();
    } catch (error) {
      throw HttpException('Add Cart error is $error');
    }
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity - 1,
              ));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
