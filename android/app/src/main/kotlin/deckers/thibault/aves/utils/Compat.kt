package deckers.thibault.aves.utils

import android.app.Activity
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.graphics.BitmapRegionDecoder
import android.location.Address
import android.location.Geocoder
import android.os.Build
import android.os.Parcelable
import android.view.Display
import java.io.IOException
import java.io.InputStream

inline fun <reified T> Intent.getParcelableExtraCompat(name: String): T? {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        getParcelableExtra(name, T::class.java)
    } else {
        @Suppress("deprecation")
        getParcelableExtra<Parcelable>(name) as? T
    }
}

fun Activity.getDisplayCompat(): Display? {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        display
    } else {
        @Suppress("deprecation")
        windowManager.defaultDisplay
    }
}

fun PackageManager.getApplicationInfoCompat(packageName: String, flags: Int): ApplicationInfo {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        getApplicationInfo(packageName, PackageManager.ApplicationInfoFlags.of(flags.toLong()))
    } else {
        getApplicationInfo(packageName, flags)
    }
}

fun PackageManager.queryIntentActivitiesCompat(intent: Intent, flags: Int): List<ResolveInfo> {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(flags.toLong()))
    } else {
        queryIntentActivities(intent, flags)
    }
}

fun Geocoder.getFromLocationCompat(
    latitude: Double,
    longitude: Double,
    maxResults: Int,
    processAddresses: (addresses: List<Address>) -> Unit,
    onError: (errorCode: String, errorMessage: String?, errorDetails: Any?) -> Unit,
) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        getFromLocation(latitude, longitude, maxResults, object : Geocoder.GeocodeListener {
            override fun onGeocode(addresses: List<Address?>) = processAddresses(addresses.filterNotNull())

            override fun onError(errorMessage: String?) {
                onError("getAddress-asyncerror", "failed to get address", errorMessage)
            }
        })
    } else {
        try {
            @Suppress("deprecation")
            val addresses = getFromLocation(latitude, longitude, maxResults) ?: ArrayList()
            processAddresses(addresses)
        } catch (e: IOException) {
            // `grpc failed`, etc.
            onError("getAddress-network", "failed to get address because of network issues", e.message)
        } catch (e: Exception) {
            onError("getAddress-exception", "failed to get address", e.message)
        }
    }
}

object BitmapRegionDecoderCompat {
    @Throws(IOException::class)
    fun newInstance(input: InputStream): BitmapRegionDecoder? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            BitmapRegionDecoder.newInstance(input)
        } else {
            @Suppress("deprecation")
            BitmapRegionDecoder.newInstance(input, false)
        }
    }
}
