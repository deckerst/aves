package deckers.thibault.aves.channel.calls.window

import android.app.Activity
import android.content.ClipData
import android.content.Context
import android.content.pm.ActivityInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Matrix.ScaleToFit
import android.graphics.Point
import android.graphics.RectF
import android.os.Build
import android.util.Log
import android.view.View
import android.view.WindowManager
import androidx.core.graphics.createBitmap
import androidx.core.net.toUri
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import deckers.thibault.aves.channel.calls.AppAdapterHandler.Companion.getShareableUri
import deckers.thibault.aves.utils.ContextUtils.devicePixelRatio
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.getDisplayCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer
import kotlin.math.roundToInt

class ActivityWindowHandler(private val activity: Activity) : WindowHandler(activity) {
    override fun isActivity(call: MethodCall, result: MethodChannel.Result) {
        result.success(true)
    }

    private fun setWindowFlag(call: MethodCall, result: MethodChannel.Result, flag: Int) {
        val on = call.argument<Boolean>("on")
        if (on == null) {
            result.error("keepOn-args", "missing arguments", null)
            return
        }

        val window = activity.window
        val old = (window.attributes.flags and flag) != 0
        if (old != on) {
            if (on) {
                window.addFlags(flag)
            } else {
                window.clearFlags(flag)
            }
        }
        result.success(null)
    }

    override fun keepScreenOn(call: MethodCall, result: MethodChannel.Result) {
        setWindowFlag(call, result, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun secureScreen(call: MethodCall, result: MethodChannel.Result) {
        setWindowFlag(call, result, WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun isInMultiWindowMode(call: MethodCall, result: MethodChannel.Result) {
        result.success(activity.isInMultiWindowMode)
    }

    override fun isCrossWindowBlurEnabled(call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val windowManager = activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            result.success(windowManager.isCrossWindowBlurEnabled)
        } else {
            result.success(false)
        }
    }

    override fun isInPictureInPictureMode(call: MethodCall, result: MethodChannel.Result) {
        result.success(activity.isInPictureInPictureMode)
    }

    // display orientation in degrees
    override fun getOrientation(call: MethodCall, result: MethodChannel.Result) {
        val displayRotation = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            activity.display.rotation
        } else {
            val windowManager = activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            @Suppress("deprecation")
            windowManager.defaultDisplay.rotation
        }
        result.success(displayRotation * 90)
    }

    override fun requestOrientation(call: MethodCall, result: MethodChannel.Result) {
        val orientation = call.argument<Int>("orientation")
        if (orientation == null) {
            result.error("requestOrientation-args", "missing arguments", null)
            return
        }
        activity.requestedOrientation = orientation
        result.success(true)
    }

    override fun showSystemUI(call: MethodCall, result: MethodChannel.Result) {
        val visible = call.argument<Boolean>("visible")
        if (visible == null) {
            result.error("showSystemUI-args", "missing arguments", null)
            return
        }

        val window = activity.window
        WindowCompat.enableEdgeToEdge(window)

        val insetsController = WindowCompat.getInsetsController(window, window.decorView)
        val types = WindowInsetsCompat.Type.systemBars()
        if (visible) {
            insetsController.show(types)
            insetsController.systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_DEFAULT
        } else {
            insetsController.hide(types)
            insetsController.systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
        result.success(true)
    }

    override fun isCutoutAware(call: MethodCall, result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
    }

    override fun getCutoutInsets(call: MethodCall, result: MethodChannel.Result) {
        val safeInsetsDpi = getCutoutInsetsDpi(activity)
        result.success(
            hashMapOf(
                "left" to safeInsetsDpi.left,
                "top" to safeInsetsDpi.top,
                "right" to safeInsetsDpi.right,
                "bottom" to safeInsetsDpi.bottom,
            )
        )
    }

    override fun supportsWideGamut(call: MethodCall, result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && activity.resources.configuration.isScreenWideColorGamut)
    }

    override fun supportsHdr(call: MethodCall, result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && activity.resources.configuration.isScreenHdr)
    }

    override fun isInWideColorGamutMode(call: MethodCall, result: MethodChannel.Result) {
        result.success(
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                    && activity.window.colorMode == ActivityInfo.COLOR_MODE_WIDE_COLOR_GAMUT
                    && activity.resources.configuration.isScreenWideColorGamut
        )
    }

    override fun isInHdrMode(call: MethodCall, result: MethodChannel.Result) {
        result.success(
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                    && activity.window.colorMode == ActivityInfo.COLOR_MODE_HDR
                    && activity.resources.configuration.isScreenHdr
        )
    }

    override fun getDisplayHdrSdrRatio(call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            result.success(activity.display.hdrSdrRatio)
            return
        }

        result.success(null)
    }

    override fun getDesiredHdrHeadroom(call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            result.success(activity.window.desiredHdrHeadroom)
            return
        }

        result.success(null)
    }

    override fun setColorMode(call: MethodCall, result: MethodChannel.Result) {
        val wideColorGamut = call.argument<Boolean>("wideColorGamut")
        val hdr = call.argument<Boolean>("hdr")
        val desiredHdrHeadroom = call.argument<Number>("desiredHdrHeadroom")?.toFloat()
        if (wideColorGamut == null || hdr == null) {
            result.error("setColorMode-args", "missing arguments", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            activity.window.colorMode = if (hdr) {
                ActivityInfo.COLOR_MODE_HDR
            } else if (wideColorGamut) {
                ActivityInfo.COLOR_MODE_WIDE_COLOR_GAMUT
            } else {
                ActivityInfo.COLOR_MODE_DEFAULT
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM
            && activity.window.colorMode == ActivityInfo.COLOR_MODE_HDR
            && desiredHdrHeadroom != null
        ) {
            activity.window.desiredHdrHeadroom = desiredHdrHeadroom
        }

        result.success(null)
    }

    override fun startGlobalDrag(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.toUri()
        val label = call.argument<String>("label")
        val shadowWidthDip = call.argument<Number>("shadowWidthDip")?.toFloat()
        val shadowHeightDip = call.argument<Number>("shadowHeightDip")?.toFloat()
        val shadowBytes = call.argument<ByteArray>("shadowBytes")

        if (uri == null || shadowWidthDip == null || shadowHeightDip == null || shadowBytes == null) {
            result.error("startGlobalDrag-args", "missing arguments", null)
            return
        }

        val clip = ClipData.newUri(activity.contentResolver, label, getShareableUri(activity, uri))

        val density = activity.devicePixelRatio()
        val widthPx = (shadowWidthDip * density).roundToInt()
        val heightPx = (shadowHeightDip * density).roundToInt()

        val shadowBuilder: View.DragShadowBuilder = try {
            val bitmap = createBitmap(widthPx, heightPx, Bitmap.Config.ARGB_8888).also {
                it.copyPixelsFromBuffer(ByteBuffer.wrap(shadowBytes))
            }

            val scaleToFit = Matrix()
            val src = RectF(0f, 0f, bitmap.width.toFloat(), bitmap.height.toFloat())
            val dst = RectF(0f, 0f, heightPx.toFloat(), heightPx.toFloat())
            scaleToFit.setRectToRect(src, dst, ScaleToFit.CENTER)

            object : View.DragShadowBuilder() {
                override fun onProvideShadowMetrics(outShadowSize: Point, outShadowTouchPoint: Point) {
                    outShadowSize.set(widthPx, heightPx)
                    outShadowTouchPoint.set(outShadowSize.x / 2, outShadowSize.y / 2)
                }

                override fun onDrawShadow(canvas: Canvas) {
                    canvas.drawBitmap(bitmap, scaleToFit, null)
                }
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "failed to draw widget", e)
            View.DragShadowBuilder()
        }

        activity.window.decorView.startDragAndDrop(
            clip,
            shadowBuilder,
            null,
            View.DRAG_FLAG_GLOBAL or View.DRAG_FLAG_GLOBAL_URI_READ
        )
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<ActivityWindowHandler>()

        fun getCutoutInsetsDpi(activity: Activity): RectF {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val cutout = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    activity.getDisplayCompat()?.cutout
                } else {
                    activity.window.decorView.rootWindowInsets.displayCutout
                }

                if (cutout != null) {
                    val density = activity.devicePixelRatio()
                    return RectF(
                        cutout.safeInsetLeft / density,
                        cutout.safeInsetTop / density,
                        cutout.safeInsetRight / density,
                        cutout.safeInsetBottom / density
                    )
                }
            }
            return RectF()
        }
    }
}