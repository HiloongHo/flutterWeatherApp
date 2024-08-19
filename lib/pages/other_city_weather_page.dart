

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OtherCityWeatherPage extends StatefulWidget {
  const OtherCityWeatherPage({super.key});

  @override
  State<OtherCityWeatherPage> createState() => _OtherCityWeatherPageState();
}

class _OtherCityWeatherPageState extends State<OtherCityWeatherPage> {
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      body: Container(
        child: const Center(
          child: Text("其他城市天气"),
        ),
      ),
    );
  }
}
