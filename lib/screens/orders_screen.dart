import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models_and_providers/orders.dart' show Orders;

import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";

  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders"),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).setAndFetchOrders(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.error != null) {
            return Center(
              child: AlertDialog(
                title: const Text("Error Occurred!"),
                content: const Text(
                    "Unable to fetch data.Please check your internet connection and refresh!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .popAndPushNamed(OrdersScreen.routeName);
                    },
                    child: const Text("Reload"),
                  ),
                ],
              ),
            );
          } else {
            return Consumer<Orders>(builder: (ctx, orderData, child) {
              if (orderData.orders.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "No Orders available!!",
                      style: TextStyle(letterSpacing: 1.5),
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemBuilder: (context, index) =>
                    OrderItem(order: orderData.orders[index]),
                itemCount: orderData.orders.length,
              );
            });
          }
        },
      ),
    );
  }
}