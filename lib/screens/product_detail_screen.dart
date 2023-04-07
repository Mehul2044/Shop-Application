import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models_and_providers/cart.dart';
import '../models_and_providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "/product-detail";

  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(156, 39, 176, 0.9),
                ),
                width: 150,
                child: Text(
                  loadedProduct.title,
                  textAlign: TextAlign.center,
                ),
              ),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(
                  height: 50,
                ),
                Text(
                  "\$${loadedProduct.price}",
                  style: const TextStyle(color: Colors.grey, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    loadedProduct.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<Cart>(context, listen: false).addItem(
                          loadedProduct.id,
                          loadedProduct.price,
                          loadedProduct.title);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          // title: const Text("Alert Dialog Box"),
                          content:
                              const Text("Item successfully added to Cart!"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                              child: Container(
                                color: Theme.of(context).colorScheme.secondary,
                                padding: const EdgeInsets.all(14),
                                child: const Text(
                                  "Okay",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Add to Cart"),
                  ),
                ),
                const SizedBox(
                  height: 500,
                  child: Center(child: Text("More details coming soon..")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
