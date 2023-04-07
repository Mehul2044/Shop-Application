import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models_and_providers/cart.dart';
import '../models_and_providers/products_provider.dart';

import '../screens/cart_screen.dart';

import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';

enum FilterOptions {
  favourites,
  all,
}

class ProductsOverview extends StatefulWidget {
  static const routeName = "/products-overview";

  const ProductsOverview({Key? key}) : super(key: key);

  @override
  State<ProductsOverview> createState() => _ProductsOverviewState();
}

class _ProductsOverviewState extends State<ProductsOverview> {
  bool _showOnlyFavourites = false;

  bool isInit = true;
  bool isLoading = false;
  bool isError = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (isInit) {
      setState(() {
        isLoading = true;
      });
      Provider.of<Products>(context)
          .fetchAndSetProducts(false)
          .catchError((error) {
        setState(() {
          isError = true;
        });
      }).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Shop"),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.favourites) {
                  _showOnlyFavourites = true;
                } else {
                  _showOnlyFavourites = false;
                }
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOptions.favourites,
                child: Text("Only Favourites"),
              ),
              const PopupMenuItem(
                value: FilterOptions.all,
                child: Text("Show All"),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => BadgeBuild(
              value: cart.itemCount.toString(),
              child: ch as Widget,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : isError
              ? Center(
                  child: AlertDialog(
                    title: const Text("Error Occurred!"),
                    content: const Text(
                        "Unable to fetch data. Please check your internet connection and refresh!"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .popAndPushNamed(ProductsOverview.routeName);
                        },
                        child: const Text("Reload"),
                      ),
                    ],
                  ),
                )
              : ProductsGrid(showFavourites: _showOnlyFavourites),
    );
  }
}
