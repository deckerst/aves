package deckers.thibault.aves.utils

import android.app.ActivityManager
import android.app.Service
import android.content.ContentResolver
import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

object ContextUtils {
    fun Context.resourceUri(resourceId: Int): Uri = with(resources) {
        Uri.Builder()
            .scheme(ContentResolver.SCHEME_ANDROID_RESOURCE)
            .authority(getResourcePackageName(resourceId))
            .appendPath(getResourceTypeName(resourceId))
            .appendPath(getResourceEntryName(resourceId))
            .build()
    }

    suspend fun Context.runOnUiThread(r: Runnable) {
        if (Looper.myLooper() != mainLooper) {
            suspendCoroutine<Boolean> { cont ->
                Handler(mainLooper).post {
                    r.run()
                    cont.resume(true)
                }
            }
        } else {
            r.run()
        }
    }

    fun Context.isMyServiceRunning(serviceClass: Class<out Service>): Boolean {
        val am = this.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager?
        am ?: return false
        @Suppress("deprecation")
        return am.getRunningServices(Integer.MAX_VALUE).any { it.service.className == serviceClass.name }
    }
}
