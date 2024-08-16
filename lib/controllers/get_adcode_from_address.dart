import 'package:dio/dio.dart';
import 'package:weather_app01/constants/api.dart';

class GetAdCodeFromAddress {

  late String address;

  GetAdCodeFromAddress({required this.address});

  // 定义一个简单的函数来获取adcode
  Future<String> getAdCodeFromAddress() async {
    final url = '${Api.baseUrl}${Api.geocodeUrl}?key=${Api.key}&address=$address';

    final dio = Dio();
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      final geocodes = data['geocodes'];
      if (geocodes.isNotEmpty) {
        final firstGeocode = geocodes[0];
        final adcode = firstGeocode['adcode'];
        return adcode;
      } else {
        throw Exception('No geocode data found in the response.');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }
}