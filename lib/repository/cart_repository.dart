import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/models/cart_model.dart';
import 'package:ecomerce_app/models/cartitems_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class CartRepository extends GetxController {
  final _db = FirebaseFirestore.instance;

  // Thêm sản phẩm vào giỏ hàng
  Future<void> addItem(Cart cart, CartItem newItem) async {
    try {
      final cartRef = _db.collection('carts').doc(cart.userId);
      final cartDoc = await cartRef.get();

      if (cartDoc.exists) {
        // Kiểm tra sản phẩm đã tồn tại
        final existingItems = List<CartItem>.from(
          (cartDoc.data()?['items'] as List).map(
            (item) => CartItem.fromMap(item),
          ),
        );

        final existingItemIndex = existingItems.indexWhere(
          (item) =>
              item.productId == newItem.productId &&
              item.variantName == newItem.variantName,
        );

        if (existingItemIndex >= 0) {
          // Cập nhật số lượng nếu sản phẩm đã tồn tại
          existingItems[existingItemIndex].quantity += newItem.quantity;
          await cartRef.update({
            'items': existingItems.map((item) => item.toMap()).toList(),
          });
        } else {
          // Thêm sản phẩm mới
          await cartRef.update({
            'items': FieldValue.arrayUnion([newItem.toMap()]),
          });
        }
      } else {
        // Tạo giỏ hàng mới
        await cartRef.set({
          'userId': cart.userId,
          'items': [newItem.toMap()],
        });
      }
    } catch (e) {
      print('Error adding item to cart: $e');
      throw Exception('Failed to add item to cart');
    }
  }

  // Cập nhật số lượng của một item trong giỏ hàng
  Future<void> updateItemQuantity(
    Cart cart,
    String itemId,
    int newQuantity,
  ) async {
    try {
      if (newQuantity <= 0) {
        throw Exception('Quantity must be greater than 0');
      }

      final cartRef = _db.collection('carts').doc(cart.userId);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        throw Exception('Cart not found');
      }

      final items = List<CartItem>.from(
        (cartDoc.data()?['items'] as List).map(
          (item) => CartItem.fromMap(item),
        ),
      );

      final itemIndex = items.indexWhere((item) => item.id == itemId);
      if (itemIndex < 0) {
        throw Exception('Item not found in cart');
      }

      items[itemIndex].quantity = newQuantity;
      await cartRef.update({
        'items': items.map((item) => item.toMap()).toList(),
      });
    } catch (e) {
      print('Error updating item quantity: $e');
      throw Exception('Failed to update item quantity: $e');
    }
  }

  // Xóa một item khỏi giỏ hàng
  Future<void> removeItem(Cart cart, String itemId) async {
    try {
      final cartRef = _db.collection('carts').doc(cart.userId);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        throw Exception('Cart not found');
      }

      final items = List<CartItem>.from(
        (cartDoc.data()?['items'] as List).map(
          (item) => CartItem.fromMap(item),
        ),
      );

      final initialLength = items.length;
      items.removeWhere((item) => item.id == itemId);

      if (items.length == initialLength) {
        throw Exception('Item not found in cart');
      }

      await cartRef.update({
        'items': items.map((item) => item.toMap()).toList(),
      });
    } catch (e) {
      print('Error removing item from cart: $e');
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  // Xóa toàn bộ giỏ hàng
  Future<void> clearCart(Cart cart) async {
    try {
      final cartRef = _db.collection('carts').doc(cart.userId);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        throw Exception('Cart not found');
      }

      await cartRef.update({'items': []});
    } catch (e) {
      print('Error clearing cart: $e');
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Lưu giỏ hàng vào Firebase
  Future<void> saveCart(Cart cart) async {
    try {
      if (cart.userId.isEmpty) {
        throw Exception('Invalid user ID');
      }

      await _db.collection('carts').doc(cart.userId).set(cart.toMap());
    } catch (e) {
      print('Error saving cart: $e');
      throw Exception('Failed to save cart: $e');
    }
  }

  // Lấy giỏ hàng từ Firebase
  Future<Cart> getCart(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Invalid user ID');
      }

      final cartDoc = await _db.collection('carts').doc(userId).get();

      if (cartDoc.exists) {
        return Cart.fromMap(cartDoc.data()!);
      }

      // Tạo giỏ hàng mới nếu chưa tồn tại
      final newCart = Cart(userId: userId);
      await saveCart(newCart);
      return newCart;
    } catch (e) {
      print('Error loading cart: $e');
      throw Exception('Failed to load cart: $e');
    }
  }
}

Future<void> syncCartWithServer(Cart cart) async {
  try {
    if (cart.userId.isEmpty) {
      throw Exception('Invalid user ID');
    }
    // Gửi dữ liệu giỏ hàng lên server
    // await apiClient.updateCart(cart.userId, cart.toMap());
  } catch (e) {
    print('Error syncing cart with server: $e');
    throw Exception('Failed to sync cart with server: $e');
  }
}
