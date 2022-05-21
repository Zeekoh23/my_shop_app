import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/http_exception.dart';
import '../models/products.dart';

class ProductsProvider with ChangeNotifier {
  var log = Logger();
  List<Product> _items = [];

  final String authToken;
  final String userId;

  ProductsProvider(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var url = Uri.parse('http://10.0.2.2:3001/api/v1/products');
    final res = await http.get(url);
    final extractedData = json.decode(res.body) as Map<String, dynamic>;

    try {
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      log.d(extractedData);
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw HttpException('could not fetch product, error is $error');
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse('http://10.0.2.2:3001/api/v1/products');
    final headers = {"Content-type": "application/json"};
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
          'userid': userId,
        }),
      );
      final resData = json.decode(response.body);
      log.i(resData);
      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: product.id);
      _items.add(newProduct);

      notifyListeners();
    } catch (error) {
      print(error);
      throw HttpException('unable to add product');
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      var url = Uri.parse('http://10.0.2.2:3001/api/v1/products/$id');
      final headers = {"Content-type": "application/json"};
      final res = await http.post(url,
          headers: headers,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      final resData = json.decode(res.body);
      log.i(resData);
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
      throw HttpException('unable to update');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      var url = Uri.parse('http://10.0.2.2:3001/api/v1/products/$id');
      final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
      var existingProduct = _items[existingProductIndex];
      _items.removeAt(existingProductIndex);
      notifyListeners();
      final response = await http.delete(url);
      log.d(response);
      if (response.statusCode >= 400) {
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw HttpException('Could not delete product.');
      }
      existingProduct;
    } catch (err) {
      throw HttpException('could not delete, error is $err');
    }
  }
}
