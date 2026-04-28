package com.example.med_assist

import android.app.Activity
import android.content.Intent
import android.media.AudioAttributes
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "med_assist/ringtone"
    private val pickRequestCode = 9281
    private var pendingResult: MethodChannel.Result? = null
    private var previewRingtone: Ringtone? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickRingtone" -> handlePickRingtone(call, result)
                    "getRingtoneTitle" -> handleGetTitle(call, result)
                    "playRingtone" -> handlePlayRingtone(call, result)
                    "stopRingtone" -> handleStopRingtone(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun handlePickRingtone(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result,
    ) {
        if (pendingResult != null) {
            result.error("BUSY", "Picker already open", null)
            return
        }
        val existingUri = call.argument<String?>("existingUri")
        val title = call.argument<String?>("title") ?: "Select Notification Sound"
        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
            putExtra(
                RingtoneManager.EXTRA_RINGTONE_TYPE,
                RingtoneManager.TYPE_NOTIFICATION,
            )
            putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, title)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
            putExtra(
                RingtoneManager.EXTRA_RINGTONE_DEFAULT_URI,
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION),
            )
            if (!existingUri.isNullOrEmpty()) {
                try {
                    putExtra(
                        RingtoneManager.EXTRA_RINGTONE_EXISTING_URI,
                        Uri.parse(existingUri),
                    )
                } catch (_: Exception) {
                    // ignore bad URI
                }
            }
        }
        pendingResult = result
        try {
            startActivityForResult(intent, pickRequestCode)
        } catch (e: Exception) {
            pendingResult = null
            result.error("UNAVAILABLE", "No ringtone picker available", e.message)
        }
    }

    private fun handleGetTitle(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result,
    ) {
        val uriStr = call.argument<String>("uri")
        if (uriStr.isNullOrEmpty()) {
            result.success(null)
            return
        }
        try {
            val uri = Uri.parse(uriStr)
            val ringtone = RingtoneManager.getRingtone(applicationContext, uri)
            result.success(ringtone?.getTitle(applicationContext))
        } catch (_: Exception) {
            result.success(null)
        }
    }

    private fun handlePlayRingtone(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result,
    ) {
        val uriStr = call.argument<String>("uri")
        if (uriStr.isNullOrEmpty()) {
            result.success(false)
            return
        }
        try {
            previewRingtone?.stop()
            previewRingtone = null
            val uri = Uri.parse(uriStr)
            val ringtone = RingtoneManager.getRingtone(applicationContext, uri)
            if (ringtone == null) {
                result.success(false)
                return
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                ringtone.audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            }
            ringtone.play()
            previewRingtone = ringtone
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun handleStopRingtone(result: MethodChannel.Result) {
        try {
            previewRingtone?.stop()
        } catch (_: Exception) {
            // ignore
        }
        previewRingtone = null
        result.success(null)
    }

    override fun onDestroy() {
        try {
            previewRingtone?.stop()
        } catch (_: Exception) {
            // ignore
        }
        previewRingtone = null
        super.onDestroy()
    }

    @Deprecated("Required for ringtone picker result")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == pickRequestCode) {
            val callback = pendingResult
            pendingResult = null
            if (resultCode == Activity.RESULT_OK && data != null) {
                @Suppress("DEPRECATION")
                val uri: Uri? = data.getParcelableExtra(
                    RingtoneManager.EXTRA_RINGTONE_PICKED_URI,
                )
                if (uri == null) {
                    callback?.success(null)
                } else {
                    val title = try {
                        RingtoneManager.getRingtone(applicationContext, uri)
                            ?.getTitle(applicationContext)
                    } catch (_: Exception) {
                        null
                    }
                    callback?.success(
                        mapOf("uri" to uri.toString(), "title" to title),
                    )
                }
            } else {
                callback?.success(null)
            }
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}
