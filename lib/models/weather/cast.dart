// 定义 Cast 类
class Cast {
  String date;
  String week;
  String dayweather;
  String nightweather;
  String daytemp;
  String nighttemp;
  String daywind;
  String nightwind;
  String daypower;
  String nightpower;
  String daytemp_float;
  String nighttemp_float;

  Cast({
    required this.date,
    required this.week,
    required this.dayweather,
    required this.nightweather,
    required this.daytemp,
    required this.nighttemp,
    required this.daywind,
    required this.nightwind,
    required this.daypower,
    required this.nightpower,
    required this.daytemp_float,
    required this.nighttemp_float,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      date: json['date'],
      week: json['week'],
      dayweather: json['dayweather'],
      nightweather: json['nightweather'],
      daytemp: json['daytemp'],
      nighttemp: json['nighttemp'],
      daywind: json['daywind'],
      nightwind: json['nightwind'],
      daypower: json['daypower'],
      nightpower: json['nightpower'],
      daytemp_float: json['daytemp_float'],
      nighttemp_float: json['nighttemp_float'],
    );
  }
}