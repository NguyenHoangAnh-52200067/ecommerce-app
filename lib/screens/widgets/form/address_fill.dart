import 'package:ecomerce_app/services/address_api_service.dart';
import 'package:flutter/material.dart';

class AddressSearchField extends StatefulWidget {
  const AddressSearchField({super.key});
  @override
  AddressSearchFieldState createState() => AddressSearchFieldState();
}

class AddressSearchFieldState extends State<AddressSearchField> {
  final AddressApiService apiService = AddressApiService();
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];

  void _onSearchChanged(String query) {
    apiService.debounceSearch(query, (suggestions) {
      setState(() {
        _suggestions = suggestions;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            width: 360,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Số nhà + Tên đường',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                prefixIcon: Icon(Icons.location_on),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
            ),
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
                            _controller.text = suggestion['description'];
                            setState(() {
                              _suggestions = [];
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
