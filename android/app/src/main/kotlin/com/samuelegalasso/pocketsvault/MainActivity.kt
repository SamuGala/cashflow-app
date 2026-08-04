package com.samuelegalasso.pocketsvault

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pocket_vault/widget")
      .setMethodCallHandler { call, result ->
        if (call.method != "sync") {
          result.notImplemented()
          return@setMethodCallHandler
        }
        val balance = call.argument<String>("balance") ?: "EUR 0,00"
        val expenses = call.argument<String>("monthlyExpenses") ?: "EUR 0,00"
        getSharedPreferences("PocketVaultWidget", MODE_PRIVATE)
          .edit()
          .putString("balance", balance)
          .putString("monthlyExpenses", expenses)
          .apply()

        val manager = AppWidgetManager.getInstance(this)
        val component = ComponentName(this, PocketVaultWidgetProvider::class.java)
        val ids = manager.getAppWidgetIds(component)
        sendBroadcast(
          Intent(this, PocketVaultWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
          },
        )
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
