import 'package:ecomerce_app/models/cartitems_model.dart';

class Cart {
  String userId;
  List<CartItem> items;

  Cart({required this.userId, this.items = const []});

  // Các phương thức tính toán nội bộ nên giữ lại trong model
  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Phương thức chuyển đổi dữ liệu
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      userId: map['userId'],
      items:
          (map['items'] as List).map((item) => CartItem.fromMap(item)).toList(),
    );
  }
}
