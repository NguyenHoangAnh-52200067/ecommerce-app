import 'package:ecomerce_app/models/cartitems_model.dart';
import 'package:ecomerce_app/screens/cart/address_screen.dart';
import 'package:ecomerce_app/screens/widgets/form/address_fill.dart';
import 'package:ecomerce_app/utils/utils.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedShippingMethod = 'Standard';
  String addressSelected = '';
  String paymentMethod = 'Cash on Delivery';
  String voucherCode = '';
  final TextEditingController addressController = TextEditingController();
  final TextEditingController voucherController = TextEditingController();

  final List<Map<String, dynamic>> shippingMethods = [
    {'name': 'Standard', 'selected': false, 'fee': 0.0},
    {'name': 'Express', 'selected': false, 'fee': 100000.0},
  ];
  late final List<CartItem> cartItems;

  void getAddressSelected(String address) {
    setState(() {
      addressSelected = address;
    });
    print("Địa chỉ được chọn " + addressSelected);
    ;
  }

  double voucherDiscount = 0.0;

  double get totalCartPrice =>
      cartItems.fold(0.0, (total, item) => total + item.price * item.quantity);
  double get shippingFee =>
      shippingMethods.firstWhere(
        (m) => m['selected'],
        orElse: () => {'fee': 0.0},
      )['fee'];
  double get totalPayment => totalCartPrice + shippingFee - voucherDiscount;
  @override
  void initState() {
    super.initState();
    cartItems = widget.cartItems;

    selectedShippingMethod = 'Nhanh';
    for (var method in shippingMethods) {
      method['selected'] = method['name'] == 'Standard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 238, 238),
      appBar: AppBar(
        title: Text('Thanh toán'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddressScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16),
                  backgroundColor: Colors.white,
                  textStyle: TextStyle(color: Colors.black, fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: const Color.fromARGB(255, 72, 178, 235),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Trần Đỗ Khánh Minh",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  "(+84) 345 738 256",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "B134, Đường Số 7, KDC Kim Sơn, Quận 7, TP. HCM ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    softWrap: true,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Sản phẩm:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  cartItems[index].imageUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16.0,
                                      ),
                                      child: Text(
                                        cartItems[index].productName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),

                                    ListTile(
                                      title: Text(
                                        'Giá: ${Utils.formatCurrency(cartItems[index].price)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      trailing: Text(
                                        'Số lượng: ${cartItems[index].quantity}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Phương thức thanh toán:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                margin: EdgeInsets.only(top: 8, bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.payment,
                      color: const Color.fromARGB(255, 72, 178, 235),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Thanh toán khi nhận hàng",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Icon(Icons.check_circle, color: Colors.blue),
                  ],
                ),
              ),

              SizedBox(height: 10),
              Text(
                'Phương thức vận chuyển:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // Set default shipping method to 'Nhanh' in initState
              Container(
                margin: EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color:
                              selectedShippingMethod == 'Nhanh'
                                  ? Colors.blue
                                  : const Color.fromARGB(255, 59, 59, 59),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedShippingMethod = 'Nhanh';
                            for (var method in shippingMethods) {
                              method['selected'] = method['name'] == 'Standard';
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Nhanh',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.local_shipping_rounded,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Đảm bảo nhận hàng trong 3 đến 5 ngày',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedShippingMethod == 'Nhanh')
                              Icon(Icons.check_circle, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color:
                              selectedShippingMethod != 'Nhanh'
                                  ? Colors.blue
                                  : const Color.fromARGB(255, 59, 59, 59),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedShippingMethod = 'Siêu tốc';
                            for (var method in shippingMethods) {
                              method['selected'] = method['name'] == 'Express';
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Hỏa tốc',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.flight_takeoff,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Đảm bảo nhận hàng vào ngày hôm sau',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedShippingMethod == 'Siêu tốc')
                              Icon(Icons.check_circle, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),
              Text(
                'Địa chỉ giao hàng:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              AddressSearchField(onAddressSelect: getAddressSelected),
              SizedBox(height: 20),
              Text(
                'Mã giảm giá:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: voucherController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nhập mã giảm giá',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Chi tiết thanh toán',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Tổng tiền hàng'),
                      trailing: Text(Utils.formatCurrency(totalCartPrice)),
                    ),
                    ListTile(
                      title: Text('Tổng phí vận chuyển'),
                      trailing: Text(Utils.formatCurrency(shippingFee)),
                    ),
                    ListTile(
                      title: Text('Voucher giảm giá:'),
                      trailing: Text(
                        '- ' + Utils.formatCurrency(voucherDiscount),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        'Tổng thanh toán:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        Utils.formatCurrency(totalPayment),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tổng cộng ${Utils.formatCurrency(totalPayment)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                if (addressSelected.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng nhập địa chỉ giao hàng')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đặt hàng thành công!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              ),
              child: Text(
                'Đặt hàng',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
