// 定义 WeatherInfo 类
import 'forecast.dart';

class WeatherInfo {
  String status;
  String count;
  String info;
  String infocode;
  List<Forecast> forecasts;

  WeatherInfo({required this.status, required this.count, required this.info, required this.infocode, required this.forecasts});

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    var list = json['forecasts'] as List<dynamic>;
    List<Forecast> forecasts = list.map((i) => Forecast.fromJson(i)).toList();
    return WeatherInfo(
      status: json['status'],
      count: json['count'],
      info: json['info'],
      infocode: json['infocode'],
      forecasts: forecasts,
    );
  }
}