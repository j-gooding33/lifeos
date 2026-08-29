package app.lifeos.life_os

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject

private const val DATA_KEY = "today_tasks"

// §22.4. Widgets never open the database and never make network calls —
// this only ever reads the JSON string the Flutter side already computed
// and wrote via HomeWidget.saveWidgetData, matching the spec's data-flow
// rule. Five fixed rows (hidden via GONE when unused) stand in for a real
// RemoteViewsFactory collection widget, which "up to 5" doesn't justify.
class TodayTasksWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val payload = widgetData.getString(DATA_KEY, null)
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.today_tasks_widget)
            render(context, views, payload)
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
            )
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private val rowIds =
        intArrayOf(
            R.id.widget_row_1,
            R.id.widget_row_2,
            R.id.widget_row_3,
            R.id.widget_row_4,
            R.id.widget_row_5,
        )

    private fun render(
        context: Context,
        views: RemoteViews,
        payload: String?,
    ) {
        val json = payload?.let { runCatching { JSONObject(it) }.getOrNull() }
        if (json == null || !json.optBoolean("signedIn", false)) {
            showMessage(views, context.getString(R.string.widget_open_app))
            return
        }

        val titles = json.optJSONArray("titles")
        if (titles == null || titles.length() == 0) {
            showMessage(views, context.getString(R.string.widget_nothing_today))
            return
        }

        views.setViewVisibility(R.id.widget_empty, View.GONE)
        for (i in rowIds.indices) {
            if (i < titles.length()) {
                views.setViewVisibility(rowIds[i], View.VISIBLE)
                views.setTextViewText(rowIds[i], "•  " + titles.optString(i))
            } else {
                views.setViewVisibility(rowIds[i], View.GONE)
            }
        }
    }

    private fun showMessage(
        views: RemoteViews,
        message: String,
    ) {
        for (id in rowIds) {
            views.setViewVisibility(id, View.GONE)
        }
        views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
        views.setTextViewText(R.id.widget_empty, message)
    }
}
