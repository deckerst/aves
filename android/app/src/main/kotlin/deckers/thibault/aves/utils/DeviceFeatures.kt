package deckers.thibault.aves.utils

import android.content.Context
import android.content.pm.PackageManager
import android.location.Geocoder
import android.os.Build

object DeviceFeatures {
    fun hasGeocoder(): Boolean = Geocoder.isPresent()

    fun hasStrongBox(context: Context): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && context.packageManager.hasSystemFeature(PackageManager.FEATURE_STRONGBOX_KEYSTORE)
    }

    fun supportPictureInPicture(context: Context): Boolean {
        // minimum version for `PictureInPictureParams.Builder#setAutoEnterEnabled`
        val supportPipOnLeave = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
        return supportPipOnLeave && context.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
    }
}