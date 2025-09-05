import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../bloc/sensor_bloc.dart';
import '../bloc/sensor_event.dart';
import '../bloc/sensor_state.dart';

class SensorInfoScreen extends StatefulWidget {
  const SensorInfoScreen({super.key});

  @override
  State<SensorInfoScreen> createState() => _SensorInfoScreenState();
}

class _SensorInfoScreenState extends State<SensorInfoScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _gyroController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _gyroController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gyroController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _gyroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Controls'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<SensorBloc, SensorState>(
        listener: (context, state) {
          if (state is SensorLoaded && state.isGyroscopeActive) {
            // Trigger rotation animation when new gyroscope data arrives
            _gyroController.forward().then((_) => _gyroController.reset());
          }
        },
        child: BlocBuilder<SensorBloc, SensorState>(
          builder: (context, state) {
            return _buildBody(state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(SensorState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.sensors,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sensor Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Control flashlight and monitor gyroscope',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Flashlight Control Section
          _buildFlashlightSection(state),

          const SizedBox(height: 24),

          // Gyroscope Section
          _buildGyroscopeSection(state),

          const SizedBox(height: 24),

          // Status Section
          _buildStatusSection(state),
        ],
      ),
    );
  }

  Widget _buildFlashlightSection(SensorState state) {
    bool isFlashlightOn = state is SensorLoaded ? state.isFlashlightOn : false;
    bool isLoading = state is SensorLoading;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isFlashlightOn
                ? [Colors.amber.withAlpha(51), Colors.orange.withAlpha(26)]
                : [Colors.grey.withAlpha(26), Colors.grey.withAlpha(13)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Flashlight Control',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Flashlight Icon with Animation
            GestureDetector(
              onTap: isLoading ? null : () {
                if (!mounted) return;
                context.read<SensorBloc>().add(const ToggleFlashlightEvent());
              },
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isFlashlightOn ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFlashlightOn ? Colors.amber : Colors.grey[300],
                        boxShadow: isFlashlightOn ? [
                          BoxShadow(
                            color: Colors.amber.withAlpha(153),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ] : null,
                      ),
                      child: Icon(
                        isFlashlightOn ? Icons.flashlight_on : Icons.flashlight_off,
                        size: 60,
                        color: isFlashlightOn ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              isFlashlightOn ? 'Flashlight is ON' : 'Flashlight is OFF',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isFlashlightOn ? Colors.amber[800] : Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Tap the icon to toggle',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGyroscopeSection(SensorState state) {
    bool isStreaming = state is SensorLoaded && state.isGyroscopeActive;
    
    double x = 0.0, y = 0.0, z = 0.0;
    if (state is SensorLoaded) {
      x = state.gyroscopeData['x'] ?? 0.0;
      y = state.gyroscopeData['y'] ?? 0.0;
      z = state.gyroscopeData['z'] ?? 0.0;
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.withAlpha(26), Colors.cyan.withAlpha(13)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gyroscope Monitor',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Switch(
                  value: isStreaming,
                  onChanged: (value) {
                    if (!mounted) return;
                    if (value) {
                      context.read<SensorBloc>().add(const StartGyroscopeEvent());
                    } else {
                      context.read<SensorBloc>().add(const StopGyroscopeEvent());
                    }
                  },
                  activeTrackColor: Colors.blue,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Gyroscope Visualization
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * math.pi * 2,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: isStreaming
                            ? [Colors.blue, Colors.cyan, Colors.lightBlue]
                            : [Colors.grey[400]!, Colors.grey[300]!],
                      ),
                      boxShadow: isStreaming ? [
                        BoxShadow(
                          color: Colors.blue.withAlpha(102),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      Icons.rotate_right,
                      size: 40,
                      color: isStreaming ? Colors.white : Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Gyroscope Data Display
            if (isStreaming) ...[
              _buildGyroDataRow('X-axis', x, Colors.red),
              const SizedBox(height: 8),
              _buildGyroDataRow('Y-axis', y, Colors.green),
              const SizedBox(height: 8),
              _buildGyroDataRow('Z-axis', z, Colors.blue),
            ] else
              Text(
                'Enable gyroscope to see data',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGyroDataRow(String axis, double value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            axis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value.toStringAsFixed(3),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(SensorState state) {
    String statusText = 'Ready';
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;

    if (state is SensorLoading) {
      statusText = 'Processing...';
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
    } else if (state is SensorError) {
      statusText = 'Error: ${state.message}';
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else if (state is SensorLoaded && state.isGyroscopeActive) {
      statusText = 'Gyroscope streaming active';
      statusColor = Colors.blue;
      statusIcon = Icons.sensors;
    } else if (state is SensorLoaded && state.isFlashlightOn) {
      statusText = 'Flashlight is active';
      statusColor = Colors.amber[700]!;
      statusIcon = Icons.flashlight_on;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
