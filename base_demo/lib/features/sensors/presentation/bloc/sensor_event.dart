import 'package:equatable/equatable.dart';

abstract class SensorEvent extends Equatable {
  const SensorEvent();

  @override
  List<Object> get props => [];
}

class ToggleFlashlightEvent extends SensorEvent {
  const ToggleFlashlightEvent();
}

class StartGyroscopeEvent extends SensorEvent {
  const StartGyroscopeEvent();
}

class StopGyroscopeEvent extends SensorEvent {
  const StopGyroscopeEvent();
}

class UpdateGyroscopeEvent extends SensorEvent {
  final Map<String, double> data;

  const UpdateGyroscopeEvent({required this.data});

  @override
  List<Object> get props => [data];
}
