package com.samuelegalasso.pocketsvault

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews

/** Month balance with quick entry; texts are written by the app on sync. */
class PocketVaultWidgetProvider : android.appwidget.AppWidgetProvider() {
  override fun onUpdate(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
  ) {
    val data = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    fun text(key: String, fallback: Int) = data.getString(key, null) ?: context.getString(fallback)
    fun value(key: String) = data.getString(key, null) ?: "—"

    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.pocket_vault_widget).apply {
        setTextViewText(R.id.widget_month, data.getString("month", "") ?: "")
        setTextViewText(R.id.widget_balance_label, text("balanceLabel", R.string.widget_default_balance))
        setTextViewText(R.id.widget_balance, value("balance"))
        setTextColor(
          R.id.widget_balance,
          context.getColor(
            if (data.getBoolean("balanceNegative", false)) R.color.widget_expense else R.color.widget_ink,
          ),
        )
        setTextViewText(R.id.widget_income_label, text("incomeLabel", R.string.widget_default_incomes))
        setTextViewText(R.id.widget_income, value("income"))
        setTextViewText(R.id.widget_expense_label, text("expenseLabel", R.string.widget_default_expenses))
        setTextViewText(R.id.widget_expenses, value("expense"))
        setTextViewText(R.id.widget_add, "+ " + text("addExpenseLabel", R.string.widget_default_expense))
        setTextViewText(R.id.widget_add_income, "+ " + text("addIncomeLabel", R.string.widget_default_income))
        setTextViewText(R.id.widget_scan, text("receiptLabel", R.string.widget_default_receipt))

        setOnClickPendingIntent(R.id.widget_container, launchIntent(context, null))
        setOnClickPendingIntent(R.id.widget_add, launchIntent(context, Uri.parse("pocketvault:///add")))
        setOnClickPendingIntent(
          R.id.widget_add_income,
          launchIntent(context, Uri.parse("pocketvault:///add?flow=income")),
        )
        setOnClickPendingIntent(R.id.widget_scan, launchIntent(context, Uri.parse("pocketvault:///scan")))
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

  companion object {
    const val PREFS = "PocketVaultWidget"
  }
}
