package deckers.thibault.aves.metadata

import android.util.Log
import android.util.Xml
import deckers.thibault.aves.utils.LogUtils
import org.xmlpull.v1.XmlPullParser
import java.io.ByteArrayInputStream

// `xmlBytes`: bytes representing the XML embedded in a MP4 `uuid` box, according to Spherical Video V1 spec
class GSpherical(xmlBytes: ByteArray) {
    private var spherical: Boolean = false
    private var stitched: Boolean = false
    private var stitchingSoftware: String = ""
    private var projectionType: String = ""
    private var stereoMode: String? = null
    private var sourceCount: Int? = null
    private var initialViewHeadingDegrees: Int? = null
    private var initialViewPitchDegrees: Int? = null
    private var initialViewRollDegrees: Int? = null
    private var timestamp: Int? = null
    private var fullPanoWidthPixels: Int? = null
    private var fullPanoHeightPixels: Int? = null
    private var croppedAreaImageWidthPixels: Int? = null
    private var croppedAreaImageHeightPixels: Int? = null
    private var croppedAreaLeftPixels: Int? = null
    private var croppedAreaTopPixels: Int? = null

    init {
        try {
            ByteArrayInputStream(xmlBytes).use {
                val parser = Xml.newPullParser().apply {
                    setInput(it, null)
                    nextTag()
                    require(XmlPullParser.START_TAG, RDF_NS, "SphericalVideo")
                }
                while (parser.next() != XmlPullParser.END_TAG) {
                    if (parser.eventType != XmlPullParser.START_TAG) continue
                    if (parser.namespace == GSPHERICAL_NS) {
                        when (val tag = parser.name) {
                            "Spherical" -> spherical = readTag(parser, tag) == "true"
                            "Stitched" -> stitched = readTag(parser, tag) == "true"
                            "StitchingSoftware" -> stitchingSoftware = readTag(parser, tag)
                            "ProjectionType" -> projectionType = readTag(parser, tag)
                            "StereoMode" -> stereoMode = readTag(parser, tag)
                            "SourceCount" -> sourceCount = readTag(parser, tag).toInt()
                            "InitialViewHeadingDegrees" -> initialViewHeadingDegrees = readTag(parser, tag).toInt()
                            "InitialViewPitchDegrees" -> initialViewPitchDegrees = readTag(parser, tag).toInt()
                            "InitialViewRollDegrees" -> initialViewRollDegrees = readTag(parser, tag).toInt()
                            "Timestamp" -> timestamp = readTag(parser, tag).toInt()
                            "FullPanoWidthPixels" -> fullPanoWidthPixels = readTag(parser, tag).toInt()
                            "FullPanoHeightPixels" -> fullPanoHeightPixels = readTag(parser, tag).toInt()
                            "CroppedAreaImageWidthPixels" -> croppedAreaImageWidthPixels = readTag(parser, tag).toInt()
                            "CroppedAreaImageHeightPixels" -> croppedAreaImageHeightPixels = readTag(parser, tag).toInt()
                            "CroppedAreaLeftPixels" -> croppedAreaLeftPixels = readTag(parser, tag).toInt()
                            "CroppedAreaTopPixels" -> croppedAreaTopPixels = readTag(parser, tag).toInt()
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to parse XML", e)
        }
    }

    fun describe(): Map<String, String> = hashMapOf(
        "Spherical" to spherical.toString(),
        "Stitched" to stitched.toString(),
        "Stitching Software" to stitchingSoftware,
        "Projection Type" to projectionType,
        "Stereo Mode" to stereoMode,
        "Source Count" to sourceCount?.toString(),
        "Initial View Heading Degrees" to initialViewHeadingDegrees?.toString(),
        "Initial View Pitch Degrees" to initialViewPitchDegrees?.toString(),
        "Initial View Roll Degrees" to initialViewRollDegrees?.toString(),
        "Timestamp" to timestamp?.toString(),
        "Full Panorama Width Pixels" to fullPanoWidthPixels?.toString(),
        "Full Panorama Height Pixels" to fullPanoHeightPixels?.toString(),
        "Cropped Area Image Width Pixels" to croppedAreaImageWidthPixels?.toString(),
        "Cropped Area Image Height Pixels" to croppedAreaImageHeightPixels?.toString(),
        "Cropped Area Left Pixels" to croppedAreaLeftPixels?.toString(),
        "Cropped Area Top Pixels" to croppedAreaTopPixels?.toString(),
    ).filterValues { it != null }.mapValues { it.value as String }

    companion object SphericalVideo {
        private val LOG_TAG = LogUtils.createTag<SphericalVideo>()

        // cf https://github.com/google/spatial-media
        const val SPHERICAL_VIDEO_V1_UUID = "ffcc8263-f855-4a93-8814-587a02521fdd"

        const val RDF_NS = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        const val GSPHERICAL_NS = "http://ns.google.com/videos/1.0/spherical/"

        private fun readText(parser: XmlPullParser): String {
            var text = ""
            if (parser.next() == XmlPullParser.TEXT) {
                text = parser.text
                parser.nextTag()
            }
            return text
        }

        private fun readTag(parser: XmlPullParser, tag: String): String {
            parser.require(XmlPullParser.START_TAG, GSPHERICAL_NS, tag)
            val text = readText(parser)
            parser.require(XmlPullParser.END_TAG, GSPHERICAL_NS, tag)
            return text
        }
    }
}