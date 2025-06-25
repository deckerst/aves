package deckers.thibault.aves.channel.calls

import android.content.Context
import android.location.Address
import android.location.Geocoder
import deckers.thibault.aves.channel.calls.Coresult.Companion.safe
import deckers.thibault.aves.utils.getFromLocationCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.util.Locale

// as of 2021/03/10, geocoding packages exist but:
// - `geocoder` is unmaintained
// - `geocoding` method does not return `addressLine` (v2.0.0)
class GeocodingHandler(private val context: Context) : MethodCallHandler {
    private val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private var geocoder: Geocoder? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getAddress" -> ioScope.launch { safe(call, result, ::getAddress) }
            else -> result.notImplemented()
        }
    }

    private fun getAddress(call: MethodCall, result: MethodChannel.Result) {
        val latitude = call.argument<Number>("latitude")?.toDouble()
        val longitude = call.argument<Number>("longitude")?.toDouble()
        val localeLanguageTag = call.argument<String>("localeLanguageTag")
        val maxResults = call.argument<Int>("maxResults") ?: 1
        if (latitude == null || longitude == null) {
            result.error("getAddress-args", "missing arguments", null)
            return
        }

        if (!Geocoder.isPresent()) {
            result.error("getAddress-unavailable", "Geocoder is unavailable", null)
            return
        }

        geocoder = geocoder ?: if (localeLanguageTag != null) {
            Geocoder(context, Locale.forLanguageTag(localeLanguageTag))
        } else {
            Geocoder(context)
        }

        fun processAddresses(addresses: List<Address>) {
            if (addresses.isEmpty()) {
                result.error("getAddress-empty", "failed to find any address for latitude=$latitude, longitude=$longitude", null)
            } else {
                val addressMapList: ArrayList<Map<String, String?>> = ArrayList(addresses.map { address ->
                    hashMapOf(
                        "addressLine" to (0..address.maxAddressLineIndex).joinToString(", ") { i -> address.getAddressLine(i) },
                        "adminArea" to address.adminArea,
                        "countryCode" to address.countryCode,
                        "countryName" to address.countryName,
                        "featureName" to address.featureName,
                        "locality" to address.locality,
                        "postalCode" to address.postalCode,
                        "subAdminArea" to address.subAdminArea,
                        "subLocality" to address.subLocality,
                        "subThoroughfare" to address.subThoroughfare,
                        "thoroughfare" to address.thoroughfare,
                    )
                })
                result.success(addressMapList)
            }
        }

        geocoder!!.getFromLocationCompat(
            latitude, longitude, maxResults, ::processAddresses,
        ) { code, message, details -> result.error(code, message, details) }
    }

    companion object {
        const val CHANNEL = "deckers.thibault/aves/geocoding"
    }
}
