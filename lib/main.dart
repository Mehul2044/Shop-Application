import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app_v2/screens/cart_screen.dart';
import 'package:shop_app_v2/screens/edit_product_screen.dart';
import 'package:shop_app_v2/screens/orders_screen.dart';
import 'package:shop_app_v2/screens/product_detail_screen.dart';
import 'package:shop_app_v2/screens/products_overview_screen.dart';
import 'package:shop_app_v2/screens/user_product_screen.dart';

import 'models_and_providers/products_provider.dart';
import 'models_and_providers/cart.dart';
import 'models_and_providers/orders.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => Products(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => Orders(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Shop APP",
        theme: ThemeData(
          // useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
              .copyWith(secondary: Colors.deepOrange),
          fontFamily: "Lato",
        ),
        home: const ProductsOverview(),
        routes: {
          ProductDetailScreen.routeName: (context) =>
              const ProductDetailScreen(),
          CartScreen.routeName: (context) => const CartScreen(),
          OrdersScreen.routeName: (context) => const OrdersScreen(),
          UserProductScreen.routeName: (context) => const UserProductScreen(),
          EditProductScreen.routeName: (context) => const EditProductScreen(),
        },
      ),
    );
  }
}
