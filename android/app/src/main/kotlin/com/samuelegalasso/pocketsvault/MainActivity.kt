package com.samuelegalasso.pocketsvault

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
  private var launchChannel: MethodChannel? = null

  /** A tapped reminder that arrived before Flutter asked for it. */
  private var pendingRoute: String? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    // Before super: Flutter starts there and may ask for the pending route.
    rememberNotificationTap(intent)
    super.onCreate(savedInstanceState)
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    rememberNotificationTap(intent)?.let { route ->
      launchChannel?.invokeMethod("open", route, object : MethodChannel.Result {
        override fun success(result: Any?) {
          pendingRoute = null
        }
        override fun error(code: String, message: String?, details: Any?) {}
        override fun notImplemented() {}
      })
    }
  }

  /**
   * Local notifications open the app with SELECT_NOTIFICATION and their
   * payload. Turned into the app's own routes, so a tap works the same
   * whether the activity is new, recreated or already running.
   */
  private fun rememberNotificationTap(intent: Intent?): String? {
    if (intent?.action != "SELECT_NOTIFICATION") return null
    val route = when (intent.getStringExtra("payload")) {
      "quickAdd" -> "/add"
      "recurring" -> "/recurring"
      "budget" -> "/home"
      else -> return null
    }
    Log.d("PocketsVault", "notification tap -> $route")
    pendingRoute = route
    return route
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    launchChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pocket_vault/launch")
      .also { channel ->
        channel.setMethodCallHandler { call, result ->
          if (call.method != "takePending") {
            result.notImplemented()
            return@setMethodCallHandler
          }
          result.success(pendingRoute)
          pendingRoute = null
        }
      }
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pocket_vault/widget")
      .setMethodCallHandler { call, result ->
        if (call.method != "sync") {
          result.notImplemented()
          return@setMethodCallHandler
        }
        val editor = getSharedPreferences(PocketVaultWidgetProvider.PREFS, MODE_PRIVATE).edit()
        (call.arguments as? Map<*, *>)?.forEach { (key, value) ->
          when (value) {
            is String -> editor.putString(key as String, value)
            is Boolean -> editor.putBoolean(key as String, value)
          is Int -> editor.putInt(key as String, value)
          }
        }
        editor.apply()

        val manager = AppWidgetManager.getInstance(this)
        for (provider in listOf(
          PocketVaultWidgetProvider::class.java,
          PocketVaultSmallWidgetProvider::class.java,
        )) {
          val ids = manager.getAppWidgetIds(ComponentName(this, provider))
          sendBroadcast(
            Intent(this, provider).apply {
              action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
              putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            },
          )
        }
        result.success(null)
      }

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pocket_vault/receipt_ocr")
      .setMethodCallHandler { call, result ->
        if (call.method != "recognize") {
          result.notImplemented()
          return@setMethodCallHandler
        }
        val path = call.argument<String>("path")
        if (path.isNullOrBlank()) {
          result.error("invalid_path", "The receipt image path is missing.", null)
          return@setMethodCallHandler
        }
        val file = File(path)
        if (!file.exists()) {
          result.error("missing_file", "The receipt image does not exist.", null)
          return@setMethodCallHandler
        }

        val image = try {
          InputImage.fromFilePath(this, Uri.fromFile(file))
        } catch (error: Exception) {
          result.error("invalid_image", error.localizedMessage, null)
          return@setMethodCallHandler
        }
        val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
        recognizer.process(image)
          .addOnSuccessListener { recognized ->
            val lines = recognized.textBlocks
              .flatMap { it.lines }
              .sortedWith(
                compareBy<com.google.mlkit.vision.text.Text.Line> {
                  it.boundingBox?.top ?: Int.MAX_VALUE
                }.thenBy { it.boundingBox?.left ?: Int.MAX_VALUE },
              )
              .map { line ->
                val bounds = line.boundingBox
                mapOf(
                  "text" to line.text,
                  "confidence" to (line.confidence ?: 0f).toDouble(),
                  "x" to (bounds?.left ?: 0).toDouble(),
                  "y" to (bounds?.top ?: 0).toDouble(),
                  "width" to (bounds?.width() ?: 0).toDouble(),
                  "height" to (bounds?.height() ?: 0).toDouble(),
                )
              }
            recognizer.close()
            result.success(lines)
          }
          .addOnFailureListener { error ->
            recognizer.close()
            result.error("recognition_failed", error.localizedMessage, null)
          }
      }
  }
}
