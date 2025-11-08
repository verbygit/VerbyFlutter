package com.hotel.verby

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class LockTaskPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel : MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "lock_task_service")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startLockTask" -> {
                startLockTask(result)
            }
            "stopLockTask" -> {
                stopLockTask(result)
            }
            "checkLockTask" -> {
                checkLockTask(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun startLockTask(result: Result) {
        try {
            activity?.let { act ->
                // Try to start lock task mode
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                    act.startLockTask()
                    result.success(true)
                } else {
                    result.success(false)
                }
            } ?: run {
                result.success(false)
            }
        } catch (e: Exception) {
            // If lock task fails (e.g., not device owner), return false
            result.success(false)
        }
    }

    private fun stopLockTask(result: Result) {
        try {
            activity?.let { act ->
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                    act.stopLockTask()
                    result.success(true)
                } else {
                    result.success(false)
                }
            } ?: run {
                result.success(false)
            }
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun checkLockTask(result: Result) {
        try {
            // For now, just return false since we can't easily check lock task status
            // without being device owner
            result.success(false)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
