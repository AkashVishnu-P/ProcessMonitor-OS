package com.processmonitor.process_monitor

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Environment
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.processmonitor.process_monitor/hardware"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getMemoryInfo" -> {
                    try {
                        val actManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        val memInfo = ActivityManager.MemoryInfo()
                        actManager.getMemoryInfo(memInfo)

                        val data = mapOf(
                            "totalMem" to memInfo.totalMem,
                            "availMem" to memInfo.availMem,
                            "lowMemory" to memInfo.lowMemory,
                            "threshold" to memInfo.threshold
                        )
                        result.success(data)
                    } catch (e: Exception) {
                        result.error("MEM_ERROR", e.localizedMessage, null)
                    }
                }
                "getStorageInfo" -> {
                    try {
                        val dataDir = Environment.getDataDirectory()
                        val stat = StatFs(dataDir.path)
                        val blockSize = stat.blockSizeLong
                        val totalBlocks = stat.blockCountLong
                        val availableBlocks = stat.availableBlocksLong

                        val totalBytes = totalBlocks * blockSize
                        val availableBytes = availableBlocks * blockSize
                        val freeBytes = stat.freeBlocksLong * blockSize

                        val data = mapOf(
                            "totalBytes" to totalBytes,
                            "availableBytes" to availableBytes,
                            "freeBytes" to freeBytes
                        )
                        result.success(data)
                    } catch (e: Exception) {
                        result.error("STORAGE_ERROR", e.localizedMessage, null)
                    }
                }
                "getBatteryExtraInfo" -> {
                    try {
                        val batteryIntent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                        val rawTemp = batteryIntent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0
                        val temperature = rawTemp / 10.0
                        val health = batteryIntent?.getIntExtra(BatteryManager.EXTRA_HEALTH, BatteryManager.BATTERY_HEALTH_UNKNOWN) ?: 0
                        val voltage = batteryIntent?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, 0) ?: 0

                        val data = mapOf(
                            "temperature" to temperature,
                            "health" to health,
                            "voltage" to voltage
                        )
                        result.success(data)
                    } catch (e: Exception) {
                        result.error("BATTERY_ERROR", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
