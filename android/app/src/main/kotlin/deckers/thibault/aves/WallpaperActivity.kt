package deckers.thibault.aves

import android.content.Intent
import android.net.Uri
import deckers.thibault.aves.channel.calls.AppAdapterHandler
import deckers.thibault.aves.model.FieldMap
import deckers.thibault.aves.utils.getParcelableExtraCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import androidx.core.net.toUri

class WallpaperActivity : MainActivity() {
    private var originalIntent: String? = null

    override fun extractIntentData(intent: Intent?): FieldMap {
        if (intent != null) {
            when (intent.action) {
                Intent.ACTION_ATTACH_DATA, Intent.ACTION_SET_WALLPAPER -> {
                    (intent.data ?: intent.getParcelableExtraCompat<Uri>(Intent.EXTRA_STREAM))?.let { uri ->
                        // MIME type is optional
                        val type = intent.type ?: intent.resolveType(this)
                        return hashMapOf(
                            INTENT_DATA_KEY_ACTION to INTENT_ACTION_SET_WALLPAPER,
                            INTENT_DATA_KEY_MIME_TYPE to type,
                            INTENT_DATA_KEY_URI to uri.toString(),
                        )
                    }

                    // if the media URI is not provided we need to pick one first
                    originalIntent = intent.action
                    intent.action = Intent.ACTION_PICK
                }
            }
        }

        return super.extractIntentData(intent)
    }

    override fun submitPickedItems(call: MethodCall, result: MethodChannel.Result) {
        if (originalIntent != null) {
            val pickedUris = call.argument<List<String>>("uris")
            if (!pickedUris.isNullOrEmpty()) {
                val toUri = { uriString: String -> AppAdapterHandler.getShareableUri(this, uriString.toUri()) }
                onNewIntent(Intent().apply {
                    action = originalIntent
                    data = toUri(pickedUris.first())
                })
            } else {
                setResult(RESULT_CANCELED)
                finish()
            }
        } else {
            super.submitPickedItems(call, result)
        }
    }
}
