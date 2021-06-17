package deckers.thibault.aves.metadata

import com.drew.lang.Rational
import com.drew.metadata.Directory
import com.drew.metadata.exif.ExifIFD0Directory
import java.text.SimpleDateFormat
import java.util.*

object MetadataExtractorHelper {
    const val PNG_TIME_DIR_NAME = "PNG-tIME"
    val PNG_LAST_MODIFICATION_TIME_FORMAT = SimpleDateFormat("yyyy:MM:dd HH:mm:ss", Locale.ROOT)

    // extensions

    fun Directory.getSafeString(tag: Int, save: (value: String) -> Unit) {
        if (this.containsTag(tag)) save(this.getString(tag))
    }

    fun Directory.getSafeBoolean(tag: Int, save: (value: Boolean) -> Unit) {
        if (this.containsTag(tag)) save(this.getBoolean(tag))
    }

    fun Directory.getSafeInt(tag: Int, save: (value: Int) -> Unit) {
        if (this.containsTag(tag)) save(this.getInt(tag))
    }

    fun Directory.getSafeLong(tag: Int, save: (value: Long) -> Unit) {
        if (this.containsTag(tag)) save(this.getLong(tag))
    }

    fun Directory.getSafeRational(tag: Int, save: (value: Rational) -> Unit) {
        if (this.containsTag(tag)) save(this.getRational(tag))
    }

    fun Directory.getSafeDateMillis(tag: Int, save: (value: Long) -> Unit) {
        if (this.containsTag(tag)) save(this.getDate(tag, null, TimeZone.getDefault()).time)
    }

    // geotiff

    /*
    cf http://docs.opengeospatial.org/is/19-008r4/19-008r4.html#_underlying_tiff_requirements
    - One of ModelTiepointTag or ModelTransformationTag SHALL be included in an Image File Directory (IFD)
    - If the ModelTransformationTag is included in an IFD, then a ModelPixelScaleTag SHALL NOT be included
    - If the ModelPixelScaleTag is included in an IFD, then a ModelTiepointTag SHALL also be included.
     */
    fun ExifIFD0Directory.isGeoTiff(): Boolean {
        if (!this.containsTag(TiffTags.TAG_GEO_KEY_DIRECTORY)) return false

        val modelTiepoint = this.containsTag(TiffTags.TAG_MODEL_TIEPOINT)
        val modelTransformation = this.containsTag(TiffTags.TAG_MODEL_TRANSFORMATION)
        if (!modelTiepoint && !modelTransformation) return false

        val modelPixelScale = this.containsTag(TiffTags.TAG_MODEL_PIXEL_SCALE)
        if ((modelTransformation && modelPixelScale) || (modelPixelScale && !modelTiepoint)) return false

        return true
    }
}