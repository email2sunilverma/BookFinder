import 'package:flutter/services.dart';
import 'dart:async';

class SensorService {
  static const MethodChannel _channel = MethodChannel('sensor_channel');
  static const EventChannel _gyroscopeChannel = EventChannel('gyroscope_stream_channel');
  
  StreamSubscription<dynamic>? _gyroscopeSubscription;
  final StreamController<Map<String, double>> _gyroscopeController = 
      StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get gyroscopeStream => _gyroscopeController.stream;

  Future<bool> toggleFlashlight() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('toggleFlashlight');
      return result['isOn'] ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to toggle flashlight: ${e.message}');
    }
  }

  Future<Map<String, double>> getGyroscopeData() async {
    try {
      final Map<dynamic, dynamic> result = 
          await _channel.invokeMethod('getGyroscopeData');
      
      return {
        'x': (result['x'] ?? 0.0).toDouble(),
        'y': (result['y'] ?? 0.0).toDouble(),
        'z': (result['z'] ?? 0.0).toDouble(),
      };
    } on PlatformException catch (e) {
      throw Exception('Failed to get gyroscope data: ${e.message}');
    }
  }

  Future<void> startGyroscopeStream() async {
    try {
      await _channel.invokeMethod('startGyroscopeStream');
      
      // Start listening to the event channel
      _gyroscopeSubscription = _gyroscopeChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map<dynamic, dynamic>) {
            final Map<String, double> gyroData = {
              'x': (event['x'] ?? 0.0).toDouble(),
              'y': (event['y'] ?? 0.0).toDouble(),
              'z': (event['z'] ?? 0.0).toDouble(),
            };
            _gyroscopeController.add(gyroData);
          }
        },
        onError: (error) {
          _gyroscopeController.addError(error);
        }
      );
    } on PlatformException catch (e) {
      throw Exception('Failed to start gyroscope stream: ${e.message}');
    }
  }

  Future<void> stopGyroscopeStream() async {
    try {
      await _channel.invokeMethod('stopGyroscopeStream');
      await _gyroscopeSubscription?.cancel();
      _gyroscopeSubscription = null;
    } on PlatformException catch (e) {
      throw Exception('Failed to stop gyroscope stream: ${e.message}');
    }
  }

  void dispose() {
    _gyroscopeSubscription?.cancel();
    _gyroscopeController.close();
  }
}
