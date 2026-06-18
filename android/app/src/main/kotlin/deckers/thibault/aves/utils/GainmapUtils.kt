package deckers.thibault.aves.utils

import android.graphics.Bitmap
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.graphics.get
import com.google.android.material.math.MathUtils.lerp
import java.lang.Math.clamp
import kotlin.math.exp
import kotlin.math.ln
import kotlin.math.pow

typealias PixelTransformer = (pixelIndex: Int, basePixel: FloatArray) -> FloatArray

object GainmapUtils {
    /*
     * `targetHdrToSdrRatio` in [0, 1]
     */
    @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    fun getGainmapPixelTransformer(baseBitmap: Bitmap, targetHdrToSdrRatio: Float? = null): PixelTransformer? {
        val gainmap = baseBitmap.gainmap ?: return null

        val ratioMinRgb = gainmap.ratioMin // default: 1f, 1f, 1f
        val ratioMaxRgb = gainmap.ratioMax // default: 2f, 2f, 2f
        val gammaRgb = gainmap.gamma // default: 1f, 1f, 1f
        val epsilonSdrRgb = gainmap.epsilonSdr // default: 0f, 0f, 0f
        val epsilonHdrRgb = gainmap.epsilonHdr // default: 0f, 0f, 0f
        val minDisplayRatioForHdrTransition = gainmap.minDisplayRatioForHdrTransition // default: 1f
        val displayRatioForFullHdr = gainmap.displayRatioForFullHdr // default: 2f

        val targetRatio = (targetHdrToSdrRatio ?: 1f) * (displayRatioForFullHdr - minDisplayRatioForHdrTransition) + minDisplayRatioForHdrTransition
        val weight = clamp((ln(targetRatio) - ln(minDisplayRatioForHdrTransition)) / (ln(displayRatioForFullHdr) - ln(minDisplayRatioForHdrTransition)), 0f, 1f)

        val baseWidth = baseBitmap.width
        val baseHeight = baseBitmap.height
        val gainmapBitmap = gainmap.gainmapContents
        val gainmapScaleX = gainmapBitmap.width.toFloat() / baseWidth
        val gainmapScaleY = gainmapBitmap.height.toFloat() / baseHeight

        fun getGainmapPixelRgb(basePixelIndex: Int): FloatArray {
            val baseX = basePixelIndex % baseWidth
            val baseY = basePixelIndex / baseWidth
            val gainmapX = (baseX * gainmapScaleX).toInt()
            val gainmapY = (baseY * gainmapScaleY).toInt()
            // non-premultiplied ARGB values in the sRGB color space
            val value = gainmapBitmap[gainmapX, gainmapY]
            val b = (value and 0xff) / BitmapConversion.MAX_8_BITS_FLOAT
            val g = (value shr 8 and 0xff) / BitmapConversion.MAX_8_BITS_FLOAT
            val r = (value shr 16 and 0xff) / BitmapConversion.MAX_8_BITS_FLOAT
            return floatArrayOf(r, g, b)
        }

        val ratioMinLnRgb = floatArrayOf(
            ln(ratioMinRgb[0]),
            ln(ratioMinRgb[1]),
            ln(ratioMinRgb[2]),
        )
        val ratioMaxLnRgb = floatArrayOf(
            ln(ratioMaxRgb[0]),
            ln(ratioMaxRgb[1]),
            ln(ratioMaxRgb[2]),
        )

        val applyGainmapToPixel = fun(pixelIndex: Int, basePixel: FloatArray): FloatArray {
            val gainmapPixelRgb = getGainmapPixelRgb(pixelIndex)

            val gainmapPixelLogSpaceRgb = floatArrayOf(
                lerp(ratioMinLnRgb[0], ratioMaxLnRgb[0], gainmapPixelRgb[0].pow(gammaRgb[0])),
                lerp(ratioMinLnRgb[1], ratioMaxLnRgb[1], gainmapPixelRgb[1].pow(gammaRgb[1])),
                lerp(ratioMinLnRgb[2], ratioMaxLnRgb[2], gainmapPixelRgb[2].pow(gammaRgb[2])),
            )
            val displayedPixelRgb = floatArrayOf(
                (basePixel[0] + epsilonSdrRgb[0]) * exp(gainmapPixelLogSpaceRgb[0] * weight) - epsilonHdrRgb[0],
                (basePixel[1] + epsilonSdrRgb[1]) * exp(gainmapPixelLogSpaceRgb[1] * weight) - epsilonHdrRgb[1],
                (basePixel[2] + epsilonSdrRgb[2]) * exp(gainmapPixelLogSpaceRgb[2] * weight) - epsilonHdrRgb[2]
            )

            return displayedPixelRgb
        }

        return applyGainmapToPixel
    }
}