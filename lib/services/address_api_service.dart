import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class AddressApiService {
  final String apiKey = 'KeONrT42qDbhvyFK5oLjywhE0EAcrxeHh0NTznDz';
  final String baseUrl = 'https://rsapi.goong.io/Place';
  final String sessionToken = Uuid().v4();
  Timer? _debounce;

  void debounceSearch(String query, Function(List<dynamic>) onResult) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () async {
      if (query.length < 2) {
        onResult([]);
        return;
      }
      List<dynamic> suggestions = await fetchAddressSuggestions(query);
      onResult(suggestions);
    });
  }

  Future<List<dynamic>> fetchAddressSuggestions(String query) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/AutoComplete?api_key=$apiKey&input=${Uri.encodeComponent(query)}&sessiontoken=$sessionToken',
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        return data['predictions'];
      }
    }
    return [];
  }

  Future<Map<String, dynamic>?> fetchAddressDetails(String placeId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/Detail?place_id=$placeId&api_key=$apiKey&sessiontoken=$sessionToken',
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK' &&
          data['result'] != null &&
          data['result']['geometry'] != null) {
        return {
          'lat': data['result']['geometry']['location']['lat'],
          'lng': data['result']['geometry']['location']['lng'],
          'province': data['result']['compound']?['province'] ?? '',
          'district': data['result']['compound']?['district'] ?? '',
          'ward': data['result']['compound']?['commune'] ?? '',
        };
      }
    }
    return null;
  }
}
