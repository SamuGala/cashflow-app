package com.samuelegalasso.pocketsvault

import android.appwidget.AppWidgetManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews

class PocketVaultWidgetProvider : android.appwidget.AppWidgetProvider() {
  override fun onUpdate(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
  ) {
    val widgetData = context.getSharedPreferences("PocketVaultWidget", Context.MODE_PRIVATE)
    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.pocket_vault_widget).apply {
        setTextViewText(
          R.id.widget_balance,
          widgetData.getString("balance", "EUR 0,00"),
        )
        setTextViewText(
          R.id.widget_expenses,
          widgetData.getString("monthlyExpenses", "EUR 0,00"),
        )
        setOnClickPendingIntent(
          R.id.widget_container,
          launchIntent(context, null),
        )
        setOnClickPendingIntent(
          R.id.widget_add,
          launchIntent(context, Uri.parse("pocketvault:///add")),
        )
      }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }

  private fun launchIntent(context: Context, uri: Uri?): PendingIntent {
    val intent = if (uri == null) {
      Intent(context, MainActivity::class.java)
    } else {
      Intent(Intent.ACTION_VIEW, uri, context, MainActivity::class.java)
    }.apply {
      flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
    }
    return PendingIntent.getActivity(
      context,
      uri?.hashCode() ?: 0,
      intent,
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
  }
}
