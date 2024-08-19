import 'dart:async';
import 'dart:io';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_app01/constants/string_images.dart';
import 'package:weather_app01/controllers/get_adcode_from_address.dart';
import 'package:weather_app01/models/weather/weather_info.dart';

import '../constants/api.dart';
import '../models/weather/cast.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Future<String?> getAddressFromLatLng(
      double latitude, double longitude) async {
    const String apiKey = "ca5d840008b86fe2276e7a42b938c622"; // 替换成你的API Key
    const String url = "https://restapi.amap.com/v3/geocode/regeo";

    Dio dio = Dio();
    try {
      final response = await dio.get(url, queryParameters: {
        "output": "json",
        "location": "$longitude,$latitude",
        "key": apiKey,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data["status"] == "1") {
          final address = data["regeocode"]["formatted_address"];
          return address;
        } else {
          print("高德API请求失败: ${data["info"]}");
          return null;
        }
      } else {
        print("网络请求失败，状态码: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("请求发生错误: $e");
      return null;
    }
  }

  Map<String, Object>? _locationResult;
  StreamSubscription<Map<String, Object>>? _locationListener;
  final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();

  final dio = Dio();
  late Future<WeatherInfo> _futureWeather;
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureWeather = fetchWeatherData("北京");

    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);
    requestPermission();
    AMapFlutterLocation.setApiKey(
        "1dbf56e2e8a4d0e4cdc2df9efd36bc71", "dfb64c0463cb53927914364b5c09aba0");

    if (Platform.isIOS) {
      requestAccuracyAuthorization();
    }

    _locationListener = _locationPlugin
        .onLocationChanged()
        .listen((Map<String, Object> result) {
      // 确保 latitude 和 longitude 被转换为 double 类型
      dynamic latitudeValue = result["latitude"];
      dynamic longitudeValue = result["longitude"];

      double? latitude = (latitudeValue is String)
          ? double.tryParse(latitudeValue)
          : latitudeValue as double?;
      double? longitude = (longitudeValue is String)
          ? double.tryParse(longitudeValue)
          : longitudeValue as double?;

      if (latitude != null && longitude != null) {
        print("定位成功: 纬度: $latitude, 经度: $longitude");
        _getAddressFromLocation(latitude, longitude);
      }

      if (_locationResult != result) {
        setState(() {
          _locationResult = result;
        });
      }
    });

    _startLocation(); // 自动启动定位
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _setLocationOption() {
    AMapLocationOption locationOption = AMapLocationOption();
    locationOption.onceLocation = false;
    locationOption.needAddress = true;
    locationOption.geoLanguage = GeoLanguage.DEFAULT;
    locationOption.desiredLocationAccuracyAuthorizationMode =
        AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;
    locationOption.fullAccuracyPurposeKey = "AMapLocationScene";
    locationOption.locationInterval = 2000;
    locationOption.locationMode = AMapLocationMode.Hight_Accuracy;
    locationOption.distanceFilter = -1;
    locationOption.desiredAccuracy = DesiredAccuracy.Best;
    locationOption.pausesLocationUpdatesAutomatically = false;
    _locationPlugin.setLocationOption(locationOption);
  }

  void _startLocation() {
    _setLocationOption();
    _locationPlugin.startLocation();
  }

  void _stopLocation() {
    _locationPlugin.stopLocation();
  }

  Future<WeatherInfo> fetchWeatherData(String address) async {
    final adCode =
        await GetAdCodeFromAddress(address: address).getAdCodeFromAddress();

    final response = await dio.get(
        '${Api.baseUrl}${Api.weatherUrl}?Key=${Api.key}&city=$adCode&extensions=all');
    final data = response.data;

    if (data != null) {
      return WeatherInfo.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: '输入你想知道的城市',
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          final trimmedAddress = _addressController.text.trim();
                          if (trimmedAddress.isNotEmpty) {
                            setState(() {
                              _futureWeather = fetchWeatherData(trimmedAddress);
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.location_city,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    onSubmitted: (value) {
                      final trimmedAddress = _addressController.text.trim();
                      if (trimmedAddress.isNotEmpty) {
                        // 当用户按下键盘上的确认键时，获取新的天气数据
                        setState(() {
                          _futureWeather = fetchWeatherData(value.trim());
                        });
                      }
                    }),
              ),
              FutureBuilder<WeatherInfo>(
                future: _futureWeather,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final weatherInfo = snapshot.data!;
                    final forecast = weatherInfo.forecasts.first;
                    final todayForecast = forecast.casts.first;
                    final tomorrowForecast = forecast.casts[1];
                    final dayAfterTomorrowForecast = forecast.casts[2];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              children: [
                                Text(
                                  "${forecast.city}今日：",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge!
                                      .apply(color: Colors.blueAccent)
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildTodayCaseCard(context, todayForecast),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  "接下来几天：",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge!
                                      .apply(color: Colors.blueAccent)
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            _buildForecastCard(context, '今日', todayForecast),
                            const SizedBox(height: 16),
                            _buildForecastCard(context, '明日', tomorrowForecast),
                            const SizedBox(height: 16),
                            _buildForecastCard(
                                context, '后日', dayAfterTomorrowForecast),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayCaseCard(BuildContext context, Cast forecast) {
    final String weatherCondition = forecast.dayweather;
    final String imagePath =
        StringImages.weatherImageMap[weatherCondition] ?? StringImages.cloud;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.blueAccent.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 80,
            ),
            Text(
              weatherCondition,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              forecast.date,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '${forecast.nighttemp_float}-${forecast.daytemp_float}°C',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.white54, thickness: 2),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWindInfo("风向", forecast.daywind),
                _buildWindInfo("风力", forecast.daypower),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastCard(BuildContext context, String day, Cast forecast) {
    final String weatherCondition = forecast.dayweather;
    final String imagePath = StringImages.weatherImageMap[weatherCondition] ??
        StringImages.lightRain;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weatherCondition,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
            Image.asset(
              imagePath,
              height: 50,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${forecast.daytemp}°C',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  void requestAccuracyAuthorization() async {
    AMapAccuracyAuthorization currentAccuracyAuthorization =
        await _locationPlugin.getSystemAccuracyAuthorization();
    if (currentAccuracyAuthorization ==
        AMapAccuracyAuthorization.AMapAccuracyAuthorizationFullAccuracy) {
      print("精确定位类型");
    } else if (currentAccuracyAuthorization ==
        AMapAccuracyAuthorization.AMapAccuracyAuthorizationReducedAccuracy) {
      print("模糊定位类型");
    } else {
      print("未知定位类型");
    }
  }

  void requestPermission() async {
    bool hasLocationPermission = await requestLocationPermission();
    if (hasLocationPermission) {
      print("定位权限申请通过");
    } else {
      print("定位权限申请不通过");
    }
  }

  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      status = await Permission.location.request();
      return status == PermissionStatus.granted;
    }
  }

  void _getAddressFromLocation(double latitude, double longitude) async {
    String? address = await getAddressFromLatLng(latitude, longitude);
    if (address != null) {
      setState(() {
        _locationResult?["address"] = address; // 将地址添加到位置结果中
        _futureWeather = fetchWeatherData(address); // 更新天气数据
      });
      print("当前地理位置: $address");
    } else {
      print("无法获取地理位置");
    }
  }
}
