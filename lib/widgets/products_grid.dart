import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_v4/widgets/products_item.dart';

import '../models_and_providers/products_provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavourites;


  const ProductsGrid({super.key, required this.showFavourites});

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        showFavourites ? productsData.favouriteItems : productsData.items;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: products[index],
        child: ProductItem(
          id: products[index].id,
          price: products[index].price,
          title: products[index].title,
          imageUrl: products[index].imageUrl,
        ),
      ),
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
    );
  }
}
