package deckers.thibault.aves.channel.calls

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class SecurityHandler(private val context: Context) : MethodCallHandler {
    private var sharedPreferences: SharedPreferences? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "writeValue" -> safe(call, result, ::writeValue)
            "readValue" -> safe(call, result, ::readValue)
            else -> result.notImplemented()
        }
    }

    private fun getStore(): SharedPreferences {
        if (sharedPreferences == null) {
            val mainKey = MasterKey.Builder(context)
                .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                .build()
            sharedPreferences = EncryptedSharedPreferences.create(
                context,
                FILENAME,
                mainKey,
                EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
            )
        }
        return sharedPreferences!!
    }

    private fun writeValue(call: MethodCall, result: MethodChannel.Result) {
        val key = call.argument<String>("key")
        val value = call.argument<Any?>("value")
        if (key == null) {
            result.error("writeValue-args", "missing arguments", null)
            return
        }

        val preferences = getStore()
        preferences.edit {
            when (value) {
                is Boolean -> putBoolean(key, value)
                is Float -> putFloat(key, value)
                is Int -> putInt(key, value)
                is Long -> putLong(key, value)
                is String -> putString(key, value)
                null -> remove(key)
                else -> {
                    result.error("writeValue-type", "unsupported type for value=$value", null)
                    return
                }
            }
        }
        result.success(true)
    }

    private fun readValue(call: MethodCall, result: MethodChannel.Result) {
        val key = call.argument<String>("key")
        if (key == null) {
            result.error("readValue-args", "missing arguments", null)
            return
        }

        result.success(getStore().all[key])
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/security"
        const val FILENAME = "secret_shared_prefs"
    }
}