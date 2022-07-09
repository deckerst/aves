package deckers.thibault.aves.aves_platform_meta

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build

fun PackageManager.getApplicationInfoCompat(packageName: String, flags: Int): ApplicationInfo {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        getApplicationInfo(packageName, PackageManager.ApplicationInfoFlags.of(flags.toLong()))
    } else {
        @Suppress("deprecation")
        getApplicationInfo(packageName, flags)
    }
}
