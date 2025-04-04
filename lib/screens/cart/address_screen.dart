import 'package:ecomerce_app/screens/cart/new_address_screen.dart';
import 'package:flutter/material.dart';

class AddressScreen extends StatefulWidget {
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Map<String, dynamic>> addresses = [
    {
      "name": "Trần Đỗ Khánh Minh",
      "phone": "(+84) 345 738 256",
      "address":
          "B134, Đường Số 7, Khu Dân Cư Kim Sơn, Phường Tân Phong, Quận 7, TP. Hồ Chí Minh",
      "isDefault": true,
    },
    {
      "name": "Nguyễn Văn A",
      "phone": "(+84) 912 345 678",
      "address": "123 Lê Lợi, Quận 1, TP. Hồ Chí Minh",
      "isDefault": false,
    },
  ];

  int selectedAddressIndex = 0;

  void _setDefaultAddress(int index) {
    setState(() {
      for (var i = 0; i < addresses.length; i++) {
        addresses[i]['isDefault'] = (i == index);
      }
      selectedAddressIndex = index;
    });
  }

  void _editAddress(int index) {
    // Hiển thị màn hình chỉnh sửa (có thể sử dụng `NewAddressScreen`)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewAddressScreen()),
    );
  }

  void _addNewAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewAddressScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chọn địa chỉ nhận hàng")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Radio<int>(
                      value: index,
                      groupValue: selectedAddressIndex,
                      onChanged: (int? value) {
                        _setDefaultAddress(index);
                      },
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          addresses[index]["name"],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => _editAddress(index),
                          child: Text(
                            "Sửa",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(addresses[index]["phone"]),
                        Text(addresses[index]["address"]),
                        if (addresses[index]["isDefault"])
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "Mặc định",
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: _addNewAddress,
              icon: Icon(Icons.add),
              label: Text("Thêm Địa Chỉ Mới"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
