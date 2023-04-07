import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import './helpers/custom_route.dart';

import './models_and_providers/auth.dart';
import './models_and_providers/products_provider.dart';
import './models_and_providers/cart.dart';
import './models_and_providers/orders.dart';

import './screens/auth_screen.dart';
import './screens/cart_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/orders_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/profile_screen.dart';
import './screens/splash_screen.dart';
import './screens/user_product_screen.dart';


Future  main() async {
  dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (BuildContext context) => Products("", [], ""),
          update: (BuildContext context, value, Products? previous) => Products(
              value.token as String,
              previous == null ? [] : previous.items,
              value.userId as String),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (BuildContext context) => Orders("", [], ""),
          update: (ctx, value, Orders? previous) => Orders(
              value.token as String,
              previous == null ? [] : previous.orders,
              value.userId as String),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Shop APP",
          theme: ThemeData(
            // useMaterial3: true,
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                .copyWith(secondary: Colors.deepOrange),
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.linux: CustomPageTransitionBuilder(),
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder()
            }),
          ),
          home: auth.isAuth
              ? const ProductsOverview()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SplashScreen();
                    } else {
                      return const AuthScreen();
                    }
                  }),
          routes: {
            ProductDetailScreen.routeName: (context) =>
                const ProductDetailScreen(),
            CartScreen.routeName: (context) => const CartScreen(),
            OrdersScreen.routeName: (context) => const OrdersScreen(),
            UserProductScreen.routeName: (context) => const UserProductScreen(),
            EditProductScreen.routeName: (context) => const EditProductScreen(),
            ProductsOverview.routeName: (context) => const ProductsOverview(),
            ProfileScreen.routeName: (context) => const ProfileScreen(),
          },
        ),
      ),
    );
  }
}
