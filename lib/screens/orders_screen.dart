import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_v2/widgets/app_drawer.dart';
import 'package:shop_app_v2/widgets/order_item.dart';

import '../models_and_providers/orders.dart' show Orders;

class OrdersScreen extends StatelessWidget {

  static const routeName = "/orders";

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders"),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemBuilder: (context, index) =>
            OrderItem(order: orderData.orders[index]),
        itemCount: orderData.orders.length,
      ),
    );
  }
}
