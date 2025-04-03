import 'package:ecomerce_app/models/cart_model.dart';
import 'package:ecomerce_app/models/cartitems_model.dart';
import 'package:ecomerce_app/repository/cart_repository.dart';
import 'package:ecomerce_app/screens/cart/checkout_screen.dart';
import 'package:ecomerce_app/utils/utils.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final Cart cart;
  const CartScreen({super.key, required this.cart});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartRepository _cartRepository = CartRepository();
  List<CartItem> cartItemsList = [];
  Set<String> selectedItems = {};

  @override
  void initState() {
    super.initState();
    cartItemsList = widget.cart.items;
  }

  double getSelectedTotal() {
    double total = 0;
    for (var item in cartItemsList) {
      if (selectedItems.contains(item.id)) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  int getSelectedCount() {
    return selectedItems.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 238, 238),
      appBar: AppBar(title: Text('Giỏ hàng')),
      body: SingleChildScrollView(
        child: Column(
          children: cartItemsList.map((item) => buildCartItem(item)).toList(),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 233, 233, 233),
        child: Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng: ${Utils.formatCurrency(getSelectedTotal())}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                ),
                onPressed:
                    selectedItems.isEmpty
                        ? null
                        : () {
                          List<CartItem> sanPhamDaChon = [];
                          for (var item in cartItemsList) {
                            if (selectedItems.contains(item.id)) {
                              sanPhamDaChon.add(item);
                            }
                          }
                          // Chuyển đến màn hình đặt hàng
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      CheckoutScreen(cartItems: sanPhamDaChon),
                            ),
                          );
                        },
                child: Text(
                  'Mua hàng (${getSelectedCount()})',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCartItem(CartItem item) {
    return Dismissible(
      key: Key(item.id.toString()),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        await _cartRepository.removeItem(widget.cart, item.id);
        setState(() {
          cartItemsList.remove(item);
        });
      },
      child: Card(
        margin: EdgeInsets.all(8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Checkbox(
                value: selectedItems.contains(item.id),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedItems.add(item.id);
                    } else {
                      selectedItems.remove(item.id);
                    }
                  });
                },
              ),
            ),
            Expanded(
              child: ListTile(
                leading:
                    item.imageUrl != null
                        ? Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                        : SizedBox(
                          width: 70,
                          height: 70,
                          child: Icon(Icons.image_not_supported),
                        ),
                title: Text(
                  item.productName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Giá: ${Utils.formatCurrency(item.price)}'),
                    if (item.discountRate != null && item.discountRate! > 0)
                      Text(
                        'Giảm giá: ${item.discountRate}%',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () async {
                        if (item.quantity > 1) {
                          await _cartRepository.updateItemQuantity(
                            widget.cart,
                            item.id,
                            item.quantity - 1,
                          );
                          setState(() {
                            item.quantity--;
                          });
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Xác nhận'),
                                content: Text(
                                  'Bạn có muốn xóa sản phẩm này khỏi giỏ hàng?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Không',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _cartRepository.removeItem(
                                        widget.cart,
                                        item.id,
                                      );
                                      setState(() {
                                        cartItemsList.remove(item);
                                      });
                                    },
                                    child: Text(
                                      'Đồng ý',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                    Text('${item.quantity}'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        await _cartRepository.updateItemQuantity(
                          widget.cart,
                          item.id,
                          item.quantity + 1,
                        );
                        setState(() {
                          item.quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
