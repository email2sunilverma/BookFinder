import 'package:equatable/equatable.dart';

abstract class DeviceInfoEvent extends Equatable {
  const DeviceInfoEvent();

  @override
  List<Object> get props => [];
}

class LoadDeviceInfoEvent extends DeviceInfoEvent {
  const LoadDeviceInfoEvent();
}

class RefreshBatteryEvent extends DeviceInfoEvent {
  const RefreshBatteryEvent();
}
