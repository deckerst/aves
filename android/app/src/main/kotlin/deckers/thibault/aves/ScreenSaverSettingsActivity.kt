package deckers.thibault.aves

import android.content.Intent

class ScreenSaverSettingsActivity : MainActivity() {
    override fun extractIntentData(intent: Intent?): MutableMap<String, Any?> {
        return hashMapOf(
            INTENT_DATA_KEY_ACTION to INTENT_ACTION_SCREEN_SAVER_SETTINGS,
        )
    }
}