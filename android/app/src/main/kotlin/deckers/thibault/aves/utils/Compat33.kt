package deckers.thibault.aves.utils

import android.location.Address
import android.location.Geocoder
import android.os.Build
import androidx.annotation.RequiresApi

/**
 * Compatibility layer in a separate object to avoid class loading issues on older Android versions.
 * e.g. `ClassNotFoundException` for `android.location.Geocoder$GeocodeListener`
 */
@RequiresApi(Build.VERSION_CODES.TIRAMISU)
object Compat33 {
    fun geocoderGetFromLocation(
        geocoder: Geocoder,
        latitude: Double,
        longitude: Double,
        maxResults: Int,
        processAddresses: (addresses: List<Address>) -> Unit,
        onError: (errorCode: String, errorMessage: String?, errorDetails: Any?) -> Unit,
    ) {
        geocoder.getFromLocation(latitude, longitude, maxResults, object : Geocoder.GeocodeListener {
            override fun onGeocode(addresses: List<Address?>) = processAddresses(addresses.filterNotNull())

            override fun onError(errorMessage: String?) {
                onError("getAddress-asyncerror", "failed to get address", errorMessage)
            }
        })
    }
}