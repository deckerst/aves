package deckers.thibault.aves.channel.calls.fetchers

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Rect
import android.graphics.RectF
import android.net.Uri
import androidx.core.graphics.createBitmap
import com.caverock.androidsvg.PreserveAspectRatio
import com.caverock.androidsvg.RenderOptions
import com.caverock.androidsvg.SVG
import com.caverock.androidsvg.SVGParseException
import deckers.thibault.aves.metadata.SVGParserBufferedInputStream
import deckers.thibault.aves.metadata.SvgHelper.normalizeSize
import deckers.thibault.aves.utils.BitmapUtils
import deckers.thibault.aves.utils.MemoryUtils
import deckers.thibault.aves.utils.StorageUtils
import io.flutter.plugin.common.MethodChannel
import kotlin.math.ceil

class SvgRegionFetcher internal constructor(
    private val context: Context,
) {
    fun fetch(
        uri: Uri,
        sizeBytes: Long?,
        scale: Int,
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

        try {
            val svg = getOrCreateDecoder(uri)
            if (svg == null) {
                result.error("fetch-read-null", "failed to open file for uri=$uri regionRect=$regionRect", null)
                return
            }

            // we scale the requested region accordingly to the viewbox size
            val viewBox = svg.documentViewBox
            val svgWidth = viewBox.width()
            val svgHeight = viewBox.height()
            val xf = imageWidth / scale / ceil(svgWidth)
            val yf = imageHeight / scale / ceil(svgHeight)
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
            effectiveRect.offset(viewBox.left, viewBox.top)

            val renderOptions = RenderOptions()
            renderOptions.viewBox(effectiveRect.left, effectiveRect.top, effectiveRect.width(), effectiveRect.height())
            renderOptions.preserveAspectRatio(PreserveAspectRatio.FULLSCREEN_START)

            val targetBitmapWidth = regionRect.width()
            val targetBitmapHeight = regionRect.height()
            val canvasWidth = targetBitmapWidth + bleedX * 2
            val canvasHeight = targetBitmapHeight + bleedY * 2

            val config = PREFERRED_CONFIG
            val pixelCount = canvasWidth * canvasHeight
            val targetBitmapSizeBytes = BitmapUtils.getExpectedImageSize(pixelCount.toLong(), config)
            if (!MemoryUtils.canAllocate(targetBitmapSizeBytes)) {
                // decoding a region that large would yield an OOM when creating the bitmap
                result.error("fetch-read-large-region", "SVG region too large for uri=$uri regionRect=$regionRect", null)
                return
            }

            var bitmap = createBitmap(canvasWidth, canvasHeight, config)
            val canvas = Canvas(bitmap)
            svg.renderToCanvas(canvas, renderOptions)

            bitmap = Bitmap.createBitmap(bitmap, bleedX, bleedY, targetBitmapWidth, targetBitmapHeight)
            val bytes = BitmapUtils.getRawBytes(bitmap, recycle = true)
            result.success(bytes)
        } catch (e: SVGParseException) {
            result.error("fetch-parse", "failed to parse SVG for uri=$uri regionRect=$regionRect", null)
        } catch (e: Exception) {
            result.error("fetch-read-exception", "failed to initialize region decoder for uri=$uri regionRect=$regionRect", e.message)
        }
    }

    private fun getOrCreateDecoder(uri: Uri): SVG? {
        var decoderRef = decoderPool.firstOrNull { it.uri == uri }
        if (decoderRef == null) {
            val newDecoder = StorageUtils.openInputStream(context, uri)?.use { input ->
                SVG.getFromInputStream(SVGParserBufferedInputStream(input))
            }
            if (newDecoder == null) {
                return null
            }
            newDecoder.normalizeSize()
            decoderRef = DecoderRef(uri, newDecoder)
        } else {
            decoderPool.remove(decoderRef)
        }
        decoderPool.add(0, decoderRef)
        while (decoderPool.size > DECODER_POOL_SIZE) {
            decoderPool.removeAt(decoderPool.size - 1)
        }
        return decoderRef.decoder
    }

    private data class DecoderRef(
        val uri: Uri,
        val decoder: SVG,
    )

    companion object {
        private val PREFERRED_CONFIG = Bitmap.Config.ARGB_8888
        private const val DECODER_POOL_SIZE = 3
        private val decoderPool = ArrayList<DecoderRef>()
    }
}
