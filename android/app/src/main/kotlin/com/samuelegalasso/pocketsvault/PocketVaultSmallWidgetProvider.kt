package com.samuelegalasso.pocketsvault

import android.appwidget.AppWidgetManager
import android.content.Context
import android.net.Uri
import android.view.View
import android.widget.RemoteViews

/** Small 2×2 widget: "+" opens a new expense, the rest opens the app. */
class PocketVaultSmallWidgetProvider : android.appwidget.AppWidgetProvider() {
  override fun onUpdate(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
  ) {
    val data = context.getSharedPreferences(PocketVaultWidgetProvider.PREFS, Context.MODE_PRIVATE)
    val percent = data.getInt("spentPercent", -1)
    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.pocket_vault_widget_small).apply {
        setTextViewText(R.id.small_month, data.getString("monthName", "") ?: "")
        setTextViewText(
          R.id.small_available_label,
          data.getString("availableLabel", null) ?: context.getString(R.string.widget_default_balance),
        )
        setTextViewText(R.id.small_available, data.getString("available", null) ?: "—")
        setTextColor(
          R.id.small_available,
          context.getColor(
            if (data.getBoolean("availableNegative", false)) R.color.widget_expense else R.color.widget_ink,
          ),
        )
        setProgressBar(R.id.small_ring, 100, percent.coerceIn(0, 100), false)
        setTextViewText(R.id.small_percent, if (percent >= 0) "$percent%" else "—")
        setTextViewText(R.id.small_caption, data.getString("spentCaption", "") ?: "")
        setViewVisibility(R.id.small_caption, View.VISIBLE)
        setOnClickPendingIntent(
          R.id.small_container,
          PocketVaultWidgetProvider.launchIntent(context, null),
        )
        setOnClickPendingIntent(
          R.id.small_add,
          PocketVaultWidgetProvider.launchIntent(context, Uri.parse("pocketvault:///add")),
        )
      }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
