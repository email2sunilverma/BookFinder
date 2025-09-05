import 'package:bloc/bloc.dart';
import '../../data/services/device_info_service.dart';
import 'device_info_event.dart';
import 'device_info_state.dart';

class DeviceInfoBloc extends Bloc<DeviceInfoEvent, DeviceInfoState> {
  final DeviceInfoService deviceInfoService;

  DeviceInfoBloc({required this.deviceInfoService}) 
      : super(const DeviceInfoInitial()) {
    on<LoadDeviceInfoEvent>(_onLoadDeviceInfo);
    on<RefreshBatteryEvent>(_onRefreshBattery);
  }

  Future<void> _onLoadDeviceInfo(
    LoadDeviceInfoEvent event,
    Emitter<DeviceInfoState> emit,
  ) async {
    emit(const DeviceInfoLoading());

    try {
      final deviceInfo = await deviceInfoService.getDeviceInfo();
      
      emit(DeviceInfoLoaded(
        deviceName: deviceInfo['deviceName'],
        osVersion: deviceInfo['osVersion'],
        batteryLevel: deviceInfo['batteryLevel'],
        platform: deviceInfo['platform'],
      ));
    } catch (e) {
      emit(DeviceInfoError(message: e.toString()));
    }
  }

  Future<void> _onRefreshBattery(
    RefreshBatteryEvent event,
    Emitter<DeviceInfoState> emit,
  ) async {
    final currentState = state;
    if (currentState is DeviceInfoLoaded) {
      try {
        final batteryLevel = await deviceInfoService.getBatteryLevel();
        emit(currentState.copyWith(batteryLevel: batteryLevel));
      } catch (e) {
        emit(DeviceInfoError(message: e.toString()));
      }
    }
  }
}
