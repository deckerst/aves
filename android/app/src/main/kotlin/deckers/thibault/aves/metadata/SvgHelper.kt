package deckers.thibault.aves.metadata

import com.caverock.androidsvg.SVG
import java.io.BufferedInputStream
import java.io.InputStream
import kotlin.math.max

object SvgHelper {
    fun SVG.normalizeSize() {
        if (documentViewBox == null) {
            setDocumentViewBox(0f, 0f, documentWidth, documentHeight)
        }
        setDocumentWidth("100%")
        setDocumentHeight("100%")
    }
}

// As of AndroidSVG v1.4, SVGParser.ENTITY_WATCH_BUFFER_SIZE is set at 4096.
// This constant is not configurable and used for the internal buffer mark read limit.
// Parsing will fail if the SVG header is larger than this value.
// So we define and apply a minimum read limit.
class SVGParserBufferedInputStream(input: InputStream) : BufferedInputStream(input) {
    @Synchronized
    override fun mark(readlimit: Int) {
        super.mark(max(MINIMUM_READ_LIMIT, readlimit))
    }

    companion object {
        private const val MINIMUM_READ_LIMIT = 1 shl 14 // 16kB
    }
}
