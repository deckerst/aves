package deckers.thibault.aves.metadata

import com.caverock.androidsvg.SVG

object SvgHelper {
    fun SVG.normalizeSize() {
        if (documentViewBox == null) {
            setDocumentViewBox(0f, 0f, documentWidth, documentHeight)
        }
        setDocumentWidth("100%")
        setDocumentHeight("100%")
    }
}