class StringImages {
  static const String cloud = 'assets/images/icons8-cloud-96.png';
  static const String thunderstorm = 'assets/images/icons8-thunderstorm-96.png';
  static const String rain = 'assets/images/icons8-rain-96.png';
  static const String lightRain = 'assets/images/icons8-light-rain-96.png';


  // 映射表，用于将天气状况映射到图片资源
   static final Map<String, String> weatherImageMap = {
    '雷阵雨': thunderstorm,
    '小雨': lightRain,
    '多云': cloud,
  };
}