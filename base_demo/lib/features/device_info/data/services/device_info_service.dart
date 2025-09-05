import 'package:flutter/services.dart';

class DeviceInfoService {
  static const MethodChannel _channel = MethodChannel('device_info_channel');

  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic> result = 
          await _channel.invokeMethod('getDeviceInfo');
      
      return {
        'deviceName': result['deviceName'] ?? 'Unknown Device',
        'osVersion': result['osVersion'] ?? 'Unknown OS',
        'batteryLevel': result['batteryLevel'] ?? 0,
        'platform': result['platform'] ?? 'Unknown Platform',
      };
    } on PlatformException catch (e) {
      throw Exception('Failed to get device info: ${e.message}');
    }
  }

  Future<int> getBatteryLevel() async {
    try {
      final int batteryLevel = await _channel.invokeMethod('getBatteryLevel');
      return batteryLevel;
    } on PlatformException catch (e) {
      throw Exception('Failed to get battery level: ${e.message}');
    }
  }
}
