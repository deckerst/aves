package deckers.thibault.aves.channel.calls.fetchers

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Rect
import android.graphics.RectF
import android.net.Uri
import com.caverock.androidsvg.PreserveAspectRatio
import com.caverock.androidsvg.RenderOptions
import com.caverock.androidsvg.SVG
import com.caverock.androidsvg.SVGParseException
import deckers.thibault.aves.metadata.SvgHelper.normalizeSize
import deckers.thibault.aves.utils.BitmapUtils.getBytes
import deckers.thibault.aves.utils.MemoryUtils
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.MethodChannel
import kotlin.math.ceil

class SvgRegionFetcher internal constructor(
    private val context: Context,
) {
    private var lastSvgRef: LastSvgRef? = null

    suspend fun fetch(
        uri: Uri,
        sizeBytes: Long?,
        regionRect: Rect,
        imageWidth: Int,
        imageHeight: Int,
        result: MethodChannel.Result,
    ) {
        if (!MemoryUtils.canAllocate(sizeBytes)) {
            // opening an SVG that large would yield an OOM during parsing from `com.caverock.androidsvg.SVGParser`
            result.error("fetch-read-large-file", "SVG too large at $sizeBytes bytes, for uri=$uri regionRect=$regionRect", null)
            return
        }

        // use `Long` as rect size could be unexpectedly large and go beyond `Int` max
        val targetBitmapSizeBytes: Long = ARGB_8888_BYTE_SIZE.toLong() * regionRect.width() * regionRect.height()
        if (!MemoryUtils.canAllocate(targetBitmapSizeBytes)) {
            // decoding a region that large would yield an OOM when creating the bitmap
            result.error("fetch-read-large-region", "SVG region too large for uri=$uri regionRect=$regionRect", null)
            return
        }

        var currentSvgRef = lastSvgRef
        if (currentSvgRef != null && currentSvgRef.uri != uri) {
            currentSvgRef = null
        }

        try {
            if (currentSvgRef == null) {
                val newSvg = StorageUtils.openInputStream(context, uri)?.use { input ->
                    try {
                        SVG.getFromInputStream(input)
                    } catch (ex: SVGParseException) {
                        result.error("fetch-parse", "failed to parse SVG for uri=$uri regionRect=$regionRect", null)
                        return
                    }
                }

                if (newSvg == null) {
                    result.error("fetch-read-null", "failed to open file for uri=$uri regionRect=$regionRect", null)
                    return
                }

                newSvg.normalizeSize()
                currentSvgRef = LastSvgRef(uri, newSvg)
            }
            val svg = currentSvgRef.svg
            lastSvgRef = currentSvgRef

            // we scale the requested region accordingly to the viewbox size
            val viewBox = svg.documentViewBox
            val svgWidth = viewBox.width()
            val svgHeight = viewBox.height()
            val xf = imageWidth / ceil(svgWidth)
            val yf = imageHeight / ceil(svgHeight)
            // some SVG paths do not respect the rendering viewbox and do not reach its edges
            // so we render to a slightly larger bitmap, using a slightly larger viewbox,
            // and crop that bitmap to the target region size
            val bleedX = xf.toInt()
            val bleedY = yf.toInt()
            val effectiveRect = RectF(
                (regionRect.left - bleedX) / xf,
                (regionRect.top - bleedY) / yf,
                (regionRect.right + bleedX) / xf,
                (regionRect.bottom + bleedY) / yf,
            )

            val renderOptions = RenderOptions()
            renderOptions.viewBox(effectiveRect.left, effectiveRect.top, effectiveRect.width(), effectiveRect.height())
            renderOptions.preserveAspectRatio(PreserveAspectRatio.FULLSCREEN_START)

            val targetBitmapWidth = regionRect.width()
            val targetBitmapHeight = regionRect.height()
            var bitmap = Bitmap.createBitmap(
                targetBitmapWidth + bleedX * 2,
                targetBitmapHeight + bleedY * 2,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            svg.renderToCanvas(canvas, renderOptions)

            bitmap = Bitmap.createBitmap(bitmap, bleedX, bleedY, targetBitmapWidth, targetBitmapHeight)
            result.success(bitmap.getBytes(canHaveAlpha = true, recycle = true))
        } catch (e: Exception) {
            result.error("fetch-read-exception", "failed to initialize region decoder for uri=$uri regionRect=$regionRect", e.message)
        }
    }

    private data class LastSvgRef(
        val uri: Uri,
        val svg: SVG,
    )

    companion object {
        const val ARGB_8888_BYTE_SIZE = 4
    }
}
