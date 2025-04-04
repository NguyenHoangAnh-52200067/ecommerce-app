import 'package:ecomerce_app/repository/user_repository.dart';
import 'package:ecomerce_app/services/address_api_service.dart';
import 'package:flutter/material.dart';

class NewAddressScreen extends StatefulWidget {
  @override
  _NewAddressScreenState createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final AddressApiService addressApiService = AddressApiService();
  final UserRepository _userRepository = UserRepository();

  bool isDefault = false;

  String selectedAddress = ""; // Địa chỉ đã chọn
  String selectedDistrict = ""; // Quận/Huyện đã chọn
  String selectedWard = ""; // Phường/Xã đã chọn
  String selectedCity = ""; // Tỉnh/Thành phố đã chọn
  String selectedStreet = ""; // Đường đã chọn
  String addressType = "Văn Phòng"; // Mặc định
  String suggestion = ""; // Địa chỉ gợi ý từ API
  List<dynamic> _suggestions = [];
  void _saveAddress() {
    // Xử lý lưu địa chỉ
    Navigator.pop(context);
  }

  void _onSearchChanged(String query) {
    addressApiService.debounceSearch(query, (suggestions) {
      setState(() {
        _suggestions = suggestions;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Địa chỉ mới"), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form nhập địa chỉ
            Text(
              "Địa chỉ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Họ và tên"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Số điện thoại"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Tỉnh/Thành phố, Quận/Huyện, Phường/Xã",
              ),
              onChanged: _onSearchChanged,
            ),
            if (_suggestions.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 250,
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        _suggestions.map((suggestion) {
                          return ListTile(
                            title: Text(suggestion['description']),
                            onTap: () {
                              addressController.text =
                                  suggestion['description'];

                              setState(() {
                                _suggestions = [];
                              });
                            },
                          );
                        }).toList(),
                  ),
                ),
              ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: "Tên đường, Tòa nhà, Số nhà",
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("HOÀN THÀNH"),
            ),
          ],
        ),
      ),
    );
  }
}
