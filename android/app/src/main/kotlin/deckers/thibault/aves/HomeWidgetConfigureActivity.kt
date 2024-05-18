package deckers.thibault.aves

import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import deckers.thibault.aves.model.FieldMap
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class HomeWidgetSettingsActivity : MainActivity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // cancel if user does not complete widget setup
        setResult(RESULT_CANCELED)

        intent.extras?.let {
            appWidgetId = it.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            intentDataMap = extractIntentData(intent)
        }

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "configure" -> {
                    result.success(null)
                    saveWidget()
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveWidget() {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val widgetInfo = appWidgetManager.getAppWidgetOptions(appWidgetId)
        HomeWidgetProvider().onAppWidgetOptionsChanged(this, appWidgetManager, appWidgetId, widgetInfo)

        val intent = Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        setResult(RESULT_OK, intent)
        finish()
    }

    override fun extractIntentData(intent: Intent?): FieldMap {
        return hashMapOf(
            INTENT_DATA_KEY_ACTION to INTENT_ACTION_WIDGET_SETTINGS,
            INTENT_DATA_KEY_WIDGET_ID to appWidgetId,
        )
    }

    companion object {
        private const val CHANNEL = "deckers.thibault/aves/widget_configure"
    }
}

