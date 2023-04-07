import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models_and_providers/auth.dart';
import '../models_and_providers/cart.dart';
import '../models_and_providers/product.dart';

import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  final String id;
  final double price;
  final String title;
  final String imageUrl;

  const ProductItem(
      {Key? key,
      required this.id,
      required this.price,
      required this.title,
      required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (context, product, child) => IconButton(
              color: Theme.of(context).colorScheme.secondary,
              icon: Icon(
                  product.isFavourite ? Icons.favorite : Icons.favorite_border),
              onPressed: () async {
                try {
                  await product.toggleFavourite(
                      authData.token!, authData.userId as String);
                } catch (error) {
                  scaffoldMessenger.showSnackBar(const SnackBar(
                    content: Text("Failed to update the favourite status!"),
                    duration: Duration(milliseconds: 1500),
                  ));
                }
              },
            ),
          ),
          trailing: IconButton(
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              cart.addItem(id, price, title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "Added item to cart!",
                    // textAlign: TextAlign.center,
                  ),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        cart.removeSingleItem(id);
                      }),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black87,
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pushNamed(ProductDetailScreen.routeName, arguments: id);
          },
          child: Hero(
            tag: id,
            child: FadeInImage(
              placeholder:
                  const AssetImage("assets/images/product_placeholder.png"),
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
