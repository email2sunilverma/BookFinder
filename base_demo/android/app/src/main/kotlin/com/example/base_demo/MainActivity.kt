package com.example.base_demo

import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.hardware.camera2.CameraManager
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import java.util.*

class MainActivity : FlutterActivity() {
    private val DEVICE_INFO_CHANNEL = "device_info_channel"
    private val SENSOR_CHANNEL = "sensor_channel"
    private val GYROSCOPE_STREAM_CHANNEL = "gyroscope_stream_channel"
    
    private lateinit var deviceInfoChannel: MethodChannel
    private lateinit var sensorChannel: MethodChannel
    private lateinit var gyroscopeStreamChannel: EventChannel
    
    private var cameraManager: CameraManager? = null
    private var cameraId: String? = null
    private var isFlashlightOn = false
    
    private var sensorManager: SensorManager? = null
    private var gyroscope: Sensor? = null
    private var gyroscopeListener: SensorEventListener? = null
    private var gyroscopeStreamHandler: GyroscopeStreamHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize camera manager
        cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        try {
            cameraId = cameraManager?.cameraIdList?.get(0)
        } catch (e: Exception) {
            // Handle camera not available
        }
        
        // Initialize sensor manager
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        gyroscope = sensorManager?.getDefaultSensor(Sensor.TYPE_GYROSCOPE)
        
        // Setup Device Info Channel
        deviceInfoChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_INFO_CHANNEL)
        deviceInfoChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> {
                    val deviceInfo = getDeviceInfo()
                    result.success(deviceInfo)
                }
                "getBatteryLevel" -> {
                    val batteryLevel = getBatteryLevel()
                    result.success(batteryLevel)
                }
                else -> result.notImplemented()
            }
        }
        
        // Setup Sensor Channel
        sensorChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SENSOR_CHANNEL)
        sensorChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "toggleFlashlight" -> {
                    toggleFlashlight(result)
                }
                "startGyroscopeStream" -> {
                    startGyroscopeStream(result)
                }
                "stopGyroscopeStream" -> {
                    stopGyroscopeStream(result)
                }
                else -> result.notImplemented()
            }
        }
        
        // Setup Gyroscope Stream Channel
        gyroscopeStreamHandler = GyroscopeStreamHandler()
        gyroscopeStreamChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, GYROSCOPE_STREAM_CHANNEL)
        gyroscopeStreamChannel.setStreamHandler(gyroscopeStreamHandler)
    }

    private fun getDeviceInfo(): Map<String, Any> {
        return mapOf(
            "deviceName" to Build.MODEL,
            "platform" to "Android",
            "osVersion" to Build.VERSION.RELEASE,
            "manufacturer" to Build.MANUFACTURER,
            "brand" to Build.BRAND
        )
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun toggleFlashlight(result: MethodChannel.Result) {
        try {
            if (cameraId != null && cameraManager != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    isFlashlightOn = !isFlashlightOn
                    cameraManager!!.setTorchMode(cameraId!!, isFlashlightOn)
                    result.success(mapOf("isOn" to isFlashlightOn))
                } else {
                    result.error("UNSUPPORTED", "Flashlight not supported on this device", null)
                }
            } else {
                result.error("NO_CAMERA", "Camera not available", null)
            }
        } catch (e: Exception) {
            result.error("FLASHLIGHT_ERROR", e.message, null)
        }
    }

    private fun startGyroscopeStream(result: MethodChannel.Result) {
        if (gyroscope != null && sensorManager != null) {
            gyroscopeStreamHandler?.startListening()
            result.success(mapOf("success" to true))
        } else {
            result.error("NO_GYROSCOPE", "Gyroscope not available", null)
        }
    }

    private fun stopGyroscopeStream(result: MethodChannel.Result) {
        gyroscopeStreamHandler?.stopListening()
        result.success(mapOf("success" to true))
    }

    inner class GyroscopeStreamHandler : EventChannel.StreamHandler, SensorEventListener {
        private var eventSink: EventChannel.EventSink? = null
        private val handler = Handler(Looper.getMainLooper())
        private var isListening = false

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            eventSink = events
        }

        override fun onCancel(arguments: Any?) {
            stopListening()
            eventSink = null
        }

        fun startListening() {
            if (!isListening && gyroscope != null && sensorManager != null) {
                isListening = true
                sensorManager!!.registerListener(this, gyroscope, SensorManager.SENSOR_DELAY_NORMAL)
            }
        }

        fun stopListening() {
            if (isListening && sensorManager != null) {
                isListening = false
                sensorManager!!.unregisterListener(this)
            }
        }

        override fun onSensorChanged(event: SensorEvent?) {
            if (event?.sensor?.type == Sensor.TYPE_GYROSCOPE && eventSink != null) {
                val gyroData = mapOf(
                    "x" to event.values[0].toDouble(),
                    "y" to event.values[1].toDouble(),
                    "z" to event.values[2].toDouble(),
                    "timestamp" to System.currentTimeMillis()
                )
                
                handler.post {
                    eventSink?.success(gyroData)
                }
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
            // Handle accuracy changes if needed
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up resources
        gyroscopeStreamHandler?.stopListening()
        if (isFlashlightOn && cameraId != null && cameraManager != null) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    cameraManager!!.setTorchMode(cameraId!!, false)
                }
            } catch (e: Exception) {
                // Handle error
            }
        }
    }
}
