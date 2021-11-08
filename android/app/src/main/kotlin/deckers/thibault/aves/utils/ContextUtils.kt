package deckers.thibault.aves.utils

import android.app.ActivityManager
import android.app.Service
import android.content.ContentResolver
import android.content.Context
import android.net.Uri

object ContextUtils {
    fun Context.resourceUri(resourceId: Int): Uri = with(resources) {
        Uri.Builder()
            .scheme(ContentResolver.SCHEME_ANDROID_RESOURCE)
            .authority(getResourcePackageName(resourceId))
            .appendPath(getResourceTypeName(resourceId))
            .appendPath(getResourceEntryName(resourceId))
            .build()
    }

    fun Context.isMyServiceRunning(serviceClass: Class<out Service>): Boolean {
        val am = this.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager?
        am ?: return false
        @Suppress("deprecation")
        return am.getRunningServices(Integer.MAX_VALUE).any { it.service.className == serviceClass.name }
    }
}
