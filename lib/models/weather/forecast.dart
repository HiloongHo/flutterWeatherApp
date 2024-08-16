// 定义 Forecast 类
import 'cast.dart';

class Forecast {
  String city;
  String adcode;
  String province;
  String reporttime;
  List<Cast> casts;

  Forecast({
    required this.city,
    required this.adcode,
    required this.province,
    required this.reporttime,
    required this.casts,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    var list = json['casts'] as List<dynamic>;
    List<Cast> casts = list.map((i) => Cast.fromJson(i)).toList();
    return Forecast(
      city: json['city'],
      adcode: json['adcode'],
      province: json['province'],
      reporttime: json['reporttime'],
      casts: casts,
    );
  }
}