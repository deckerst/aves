package deckers.thibault.aves.channel.calls

import android.appwidget.AppWidgetManager
import android.content.Context
import deckers.thibault.aves.HomeWidgetProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class HomeWidgetHandler(private val context: Context) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "update" -> Coresult.safe(call, result, ::update)
            else -> result.notImplemented()
        }
    }

    private fun update(call: MethodCall, result: MethodChannel.Result) {
        val widgetId = call.argument<Int>("widgetId")
        if (widgetId == null) {
            result.error("update-args", "missing arguments", null)
            return
        }

        val appWidgetManager = AppWidgetManager.getInstance(context)
        HomeWidgetProvider().onUpdate(context, appWidgetManager, intArrayOf(widgetId))
        result.success(null)
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/widget_update"
    }
}