import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models_and_providers/auth.dart';

import '../widgets/app_drawer.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = "/profile-screen";
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? userId = Provider.of<Auth>(context, listen: false).userId;
    String? email = Provider.of<Auth>(context, listen: false).email;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Email:"),
                Text(email as String),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("User ID:"),
                Text(userId as String),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
