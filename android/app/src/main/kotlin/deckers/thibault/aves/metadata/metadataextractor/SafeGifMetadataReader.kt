package deckers.thibault.aves.metadata.metadataextractor

import com.adobe.internal.xmp.options.ParseOptions
import com.drew.lang.StreamReader
import com.drew.metadata.Metadata
import java.io.InputStream

object SafeGifMetadataReader {
    fun readMetadata(inputStream: InputStream, xmpParseOptions: ParseOptions): Metadata {
        val metadata = Metadata()
        SafeGifReader(xmpParseOptions).extract(StreamReader(inputStream), metadata)
        return metadata
    }
}