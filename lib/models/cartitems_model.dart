class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String? variantName;
  final String? imageUrl;
  final double price;
  int quantity;
  final double? discountRate;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.variantName,
    this.imageUrl,
    required this.price,
    required this.quantity,
    this.discountRate,
  });

  // Tính tổng tiền của item này
  double get totalPrice {
    double discountedPrice =
        discountRate != null && discountRate! > 0
            ? price * (1 - discountRate! / 100)
            : price;
    return discountedPrice * quantity;
  }

  // Phương thức tạo bản sao CartItem với các thuộc tính có thể thay đổi
  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? variantName,
    String? imageUrl,
    double? price,
    int? quantity,
    double? discountRate,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      discountRate: discountRate ?? this.discountRate,
    );
  }

  // Chuyển đổi CartItem thành Map để lưu vào Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'variantName': variantName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'discountRate': discountRate,
    };
  }

  // Tạo CartItem từ Map (để đọc từ Database)
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      productId: map['productId'],
      productName: map['productName'],
      variantName: map['variantName'],
      imageUrl: map['imageUrl'],
      price: map['price'],
      quantity: map['quantity'],
      discountRate: map['discountRate'],
    );
  }
}
