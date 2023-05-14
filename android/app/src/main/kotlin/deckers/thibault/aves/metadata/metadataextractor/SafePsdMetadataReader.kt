package deckers.thibault.aves.metadata.metadataextractor

import com.drew.lang.StreamReader
import com.drew.metadata.Metadata
import java.io.InputStream

object SafePsdMetadataReader {
    fun readMetadata(inputStream: InputStream): Metadata {
        val metadata = Metadata()
        SafePsdReader().extract(StreamReader(inputStream), metadata)
        return metadata
    }
}