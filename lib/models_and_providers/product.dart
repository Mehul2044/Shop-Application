import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models_and_providers/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavourite = false});

  Future<void> toggleFavourite(String token, String userId) async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final updateUrl = Uri.parse(
        "${dotenv.env['BASEURL']}/userFavourites/$userId/$id.json?auth=$token");
    try {
      final response = await http.put(
        updateUrl,
        body: json.encode(
          isFavourite,
        ),
      );
      if (response.statusCode >= 400) {
        isFavourite = oldStatus;
        notifyListeners();
        throw HttpException("Failed to update the Favourite status!");
      }
    } catch (error) {
      isFavourite = oldStatus;
      notifyListeners();
      rethrow;
    }
  }
}
