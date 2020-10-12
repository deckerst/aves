package deckers.thibault.aves.utils

import com.drew.lang.Rational
import com.drew.metadata.Directory
import java.util.*

object MetadataExtractorHelper {
    // extensions

    fun Directory.getSafeDescription(tag: Int, save: (value: String) -> Unit) {
        if (this.containsTag(tag)) save(this.getDescription(tag))
    }

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
}