import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models_and_providers/products_provider.dart';

import '../screens/edit_product_screen.dart';

import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = "/user-products";

  Future<void> refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  const UserProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Your Products"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: refreshProducts(context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: AlertDialog(
                title: const Text("Error Occurred!"),
                content: const Text(
                    "Unable to fetch data. Please check your internet connection and refresh!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .popAndPushNamed(UserProductScreen.routeName);
                    },
                    child: const Text("Reload"),
                  ),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () {
                return refreshProducts(context);
              },
              child: Consumer<Products>(builder: (ctx, productsData, _) {
                if (productsData.items.isEmpty) {
                  return const Center(
                    child: Text(
                      "You have not added any products",
                      style: TextStyle(letterSpacing: 1.5),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          UserProductItem(
                            title: productsData.items[index].title,
                            imageUrl: productsData.items[index].imageUrl,
                            id: productsData.items[index].id,
                          ),
                          const Divider(),
                        ],
                      );
                    },
                    itemCount: productsData.items.length,
                  ),
                );
              }),
            );
          }
        },
      ),
    );
  }
}
