import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models_and_providers/http_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  final String authToken;
  final String userId;

  Products(this.authToken, this._items, this.userId);

  List<Product> _items = [];

  List<Product> get favouriteItems {
    return _items.where((element) => element.isFavourite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts(bool filterByUser) async {
    final filterString =
    filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        "${dotenv.env['BASEURL']}/products.json?auth=$authToken&$filterString");
    try {
      final response = await http.get(url);
      final Map<String, dynamic>? extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }
      final favouriteUrl = Uri.parse(
          "${dotenv.env['BASEURL']}/userFavourites/$userId.json?auth=$authToken");
      final favouriteResponse = await http.get(favouriteUrl);
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
            id: key,
            title: value["title"],
            description: value["description"],
            price: value["price"],
            imageUrl: value["imageUrl"],
            isFavourite:
                favouriteData == null ? false : favouriteData[key] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        "${dotenv.env['BASEURL']}/products.json?auth=$authToken");
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
          "creatorId": userId
        }),
      );
      final newProduct = Product(
          id: json.decode(response.body)["name"],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProducts(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final updateUrl = Uri.parse(
          "${dotenv.env['BASEURL']}/products/$id.json?auth=$authToken");
      await http.patch(
        updateUrl,
        body: json.encode({
          "title": newProduct.title,
          "description": newProduct.description,
          "imageUrl": newProduct.imageUrl,
          "price": newProduct.price
        }),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final updateUrl = Uri.parse(
        "${dotenv.env['BASEURL']}/products/$id.json?auth=$authToken");
    int? existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(updateUrl);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product!");
    }
    existingProductIndex = null;
    existingProduct = null;
  }
}
