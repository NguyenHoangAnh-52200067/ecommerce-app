import 'package:ecomerce_app/repository/cart_repository.dart';
import 'package:ecomerce_app/repository/user_repository.dart';
import 'package:ecomerce_app/screens/cart/cart_screen.dart';
import 'package:ecomerce_app/screens/widgets/appbar/custom_appbar.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  HomeAppBar({super.key, required String fullName}) : _fullName = fullName;

  final String? _fullName;
  final UserRepository _userRepository = new UserRepository();
  final CartRepository _cartRepository = new CartRepository();
  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Chào ngày mới,", style: TextStyle(fontSize: 12)),
          Text(
            "$_fullName",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () async {
            final cart = await _cartRepository.getCart(
              _userRepository.getCurrentUserId()!,
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartScreen(cart: cart)),
            );
          },
          icon: const Icon(Icons.shopping_cart_outlined),
          color: Colors.black,
        ),
      ],
    );
  }
}
