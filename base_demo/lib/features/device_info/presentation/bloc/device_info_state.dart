import 'package:equatable/equatable.dart';

abstract class DeviceInfoState extends Equatable {
  const DeviceInfoState();

  @override
  List<Object> get props => [];
}

class DeviceInfoInitial extends DeviceInfoState {
  const DeviceInfoInitial();
}

class DeviceInfoLoading extends DeviceInfoState {
  const DeviceInfoLoading();
}

class DeviceInfoLoaded extends DeviceInfoState {
  final String deviceName;
  final String osVersion;
  final int batteryLevel;
  final String platform;

  const DeviceInfoLoaded({
    required this.deviceName,
    required this.osVersion,
    required this.batteryLevel,
    required this.platform,
  });

  @override
  List<Object> get props => [deviceName, osVersion, batteryLevel, platform];

  DeviceInfoLoaded copyWith({
    String? deviceName,
    String? osVersion,
    int? batteryLevel,
    String? platform,
  }) {
    return DeviceInfoLoaded(
      deviceName: deviceName ?? this.deviceName,
      osVersion: osVersion ?? this.osVersion,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      platform: platform ?? this.platform,
    );
  }
}

class DeviceInfoError extends DeviceInfoState {
  final String message;

  const DeviceInfoError({required this.message});

  @override
  List<Object> get props => [message];
}
