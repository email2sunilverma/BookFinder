import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../data/services/sensor_service.dart';
import 'sensor_event.dart';
import 'sensor_state.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  final SensorService sensorService;
  StreamSubscription<Map<String, double>>? _gyroscopeSubscription;

  SensorBloc({required this.sensorService}) : super(const SensorInitial()) {
    on<ToggleFlashlightEvent>(_onToggleFlashlight);
    on<StartGyroscopeEvent>(_onStartGyroscope);
    on<StopGyroscopeEvent>(_onStopGyroscope);
    on<UpdateGyroscopeEvent>(_onUpdateGyroscope);
  }

  Future<void> _onToggleFlashlight(
    ToggleFlashlightEvent event,
    Emitter<SensorState> emit,
  ) async {
    try {
      emit(const SensorLoading());
      final bool isFlashlightOn = await sensorService.toggleFlashlight();
      
      final currentState = state;
      if (currentState is SensorLoaded) {
        emit(currentState.copyWith(isFlashlightOn: isFlashlightOn));
      } else {
        emit(SensorLoaded(
          isFlashlightOn: isFlashlightOn,
          gyroscopeData: const {'x': 0.0, 'y': 0.0, 'z': 0.0},
          isGyroscopeActive: false,
        ));
      }
    } catch (e) {
      emit(SensorError(message: e.toString()));
    }
  }

  Future<void> _onStartGyroscope(
    StartGyroscopeEvent event,
    Emitter<SensorState> emit,
  ) async {
    try {
      await sensorService.startGyroscopeStream();
      
      final currentState = state;
      if (currentState is SensorLoaded) {
        emit(currentState.copyWith(isGyroscopeActive: true));
      } else {
        emit(const SensorLoaded(
          isFlashlightOn: false,
          gyroscopeData: {'x': 0.0, 'y': 0.0, 'z': 0.0},
          isGyroscopeActive: true,
        ));
      }

      // Subscribe to gyroscope data stream
      _gyroscopeSubscription = sensorService.gyroscopeStream.listen(
        (data) => add(UpdateGyroscopeEvent(data: data)),
        onError: (error) => add(UpdateGyroscopeEvent(data: const {'x': 0.0, 'y': 0.0, 'z': 0.0})),
      );
    } catch (e) {
      emit(SensorError(message: e.toString()));
    }
  }

  Future<void> _onStopGyroscope(
    StopGyroscopeEvent event,
    Emitter<SensorState> emit,
  ) async {
    try {
      await sensorService.stopGyroscopeStream();
      await _gyroscopeSubscription?.cancel();
      _gyroscopeSubscription = null;
      
      final currentState = state;
      if (currentState is SensorLoaded) {
        emit(currentState.copyWith(
          isGyroscopeActive: false,
          gyroscopeData: const {'x': 0.0, 'y': 0.0, 'z': 0.0},
        ));
      }
    } catch (e) {
      emit(SensorError(message: e.toString()));
    }
  }

  void _onUpdateGyroscope(
    UpdateGyroscopeEvent event,
    Emitter<SensorState> emit,
  ) {
    final currentState = state;
    if (currentState is SensorLoaded && currentState.isGyroscopeActive) {
      emit(currentState.copyWith(gyroscopeData: event.data));
    }
  }

  @override
  Future<void> close() {
    _gyroscopeSubscription?.cancel();
    sensorService.dispose();
    return super.close();
  }
}
