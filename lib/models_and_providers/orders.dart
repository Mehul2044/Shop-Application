import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models_and_providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this._orders, this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> setAndFetchOrders() async {
    final url = Uri.parse(
        "${dotenv.env['BASEURL']}/orders/$userId.json?auth=$authToken");
    try {
      final response = await http.get(url);
      final Map<String, dynamic>? extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }
      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((key, value) {
        loadedOrders.add(
          OrderItem(
              id: key,
              amount: value["amount"],
              dateTime: DateTime.parse(value["dateTime"]),
              products: (value["products"] as List<dynamic>)
                  .map((e) => CartItem(
                      id: e["id"],
                      title: e["title"],
                      quantity: e["quantity"],
                      price: e["price"]))
                  .toList()),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        "${dotenv.env['BASEURL']}/orders/$userId.json?auth=$authToken");
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "amount": total,
          "products": cartProducts
              .map((e) => {
                    "id": e.id,
                    "title": e.title,
                    "quantity": e.quantity,
                    "price": e.price
                  })
              .toList(),
          "dateTime": timeStamp.toIso8601String()
        }),
      );
      final newOrder = OrderItem(
          id: json.decode(response.body)["name"],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp);
      _orders.add(newOrder);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
