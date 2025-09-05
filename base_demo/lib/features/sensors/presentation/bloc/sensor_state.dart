import 'package:equatable/equatable.dart';

abstract class SensorState extends Equatable {
  const SensorState();

  @override
  List<Object> get props => [];
}

class SensorInitial extends SensorState {
  const SensorInitial();
}

class SensorLoading extends SensorState {
  const SensorLoading();
}

class SensorLoaded extends SensorState {
  final bool isFlashlightOn;
  final Map<String, double> gyroscopeData;
  final bool isGyroscopeActive;

  const SensorLoaded({
    required this.isFlashlightOn,
    required this.gyroscopeData,
    required this.isGyroscopeActive,
  });

  @override
  List<Object> get props => [isFlashlightOn, gyroscopeData, isGyroscopeActive];

  SensorLoaded copyWith({
    bool? isFlashlightOn,
    Map<String, double>? gyroscopeData,
    bool? isGyroscopeActive,
  }) {
    return SensorLoaded(
      isFlashlightOn: isFlashlightOn ?? this.isFlashlightOn,
      gyroscopeData: gyroscopeData ?? this.gyroscopeData,
      isGyroscopeActive: isGyroscopeActive ?? this.isGyroscopeActive,
    );
  }
}

class SensorError extends SensorState {
  final String message;

  const SensorError({required this.message});

  @override
  List<Object> get props => [message];
}
