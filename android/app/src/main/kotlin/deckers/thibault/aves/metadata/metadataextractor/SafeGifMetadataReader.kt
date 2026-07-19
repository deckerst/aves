package deckers.thibault.aves.metadata.metadataextractor

import com.drew.lang.StreamReader
import com.drew.metadata.Metadata
import com.drew.metadata.gif.GifReader
import java.io.InputStream

object SafeGifMetadataReader {
    fun readMetadata(inputStream: InputStream): Metadata {
        val metadata = Metadata()
        SafeGifReader().extract(StreamReader(inputStream), metadata)
        return metadata
    }
}