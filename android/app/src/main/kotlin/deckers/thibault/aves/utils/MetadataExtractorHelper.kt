package deckers.thibault.aves.utils

import com.drew.metadata.Directory
import java.util.*

object MetadataExtractorHelper {
    // extensions

    fun Directory.getSafeInt(tag: Int, save: (value: Int) -> Unit) {
        if (this.containsTag(tag)) save(this.getInt(tag))
    }

    fun Directory.getSafeLong(tag: Int, save: (value: Long) -> Unit) {
        if (this.containsTag(tag)) save(this.getLong(tag))
    }

    fun Directory.getSafeDateMillis(tag: Int, save: (value: Long) -> Unit) {
        if (this.containsTag(tag)) save(this.getDate(tag, null, TimeZone.getDefault()).time)
    }
}