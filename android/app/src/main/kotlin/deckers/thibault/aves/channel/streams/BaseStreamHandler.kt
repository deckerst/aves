package deckers.thibault.aves.channel.streams

import android.os.Handler
import android.os.Looper
import android.util.Log
import deckers.thibault.aves.utils.MemoryUtils
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import java.io.InputStream

abstract class BaseStreamHandler : EventChannel.StreamHandler {
    val ioScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private lateinit var eventSink: EventChannel.EventSink
    private lateinit var handler: Handler

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
        this.eventSink = eventSink
        handler = Handler(Looper.getMainLooper())
        onCall(arguments)
    }

    override fun onCancel(arguments: Any?) {
        // nothing
    }

    open fun success(event: Any?) {
        handler.post {
            try {
                eventSink.success(event)
            } catch (e: Exception) {
                Log.w(logTag, "failed to use event sink", e)
            }
        }
    }

    open fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        handler.post {
            try {
                eventSink.error(errorCode, errorMessage, errorDetails)
            } catch (e: Exception) {
                Log.w(logTag, "failed to use event sink", e)
            }
        }
    }

    open fun endOfStream() {
        handler.post {
            try {
                eventSink.endOfStream()
            } catch (e: Exception) {
                Log.w(logTag, "failed to use event sink", e)
            }
        }
    }

    fun streamBytes(inputStream: InputStream): Boolean {
        val buffer = ByteArray(BUFFER_SIZE)
        var len: Int
        while (inputStream.read(buffer).also { len = it } != -1) {
            // cannot decode image on Flutter side when using `buffer` directly
            if (MemoryUtils.canAllocate(len)) {
                success(buffer.copyOf(len))
            } else {
                error("streamBytes-memory", "not enough memory to allocate $len bytes", null)
                return false
            }
        }
        return true
    }

    fun safe(function: () -> Unit, closeStream: Boolean = true) {
        try {
            function()
        } catch (e: Exception) {
            error("safe-exception", e.message, e.stackTraceToString())
        }
        if (closeStream) {
            endOfStream()
        }
    }

    suspend fun safeSuspend(function: suspend () -> Unit, closeStream: Boolean = true) {
        try {
            function()
        } catch (e: Exception) {
            error("safeSuspend-exception", e.message, e.stackTraceToString())
        }
        if (closeStream) {
            endOfStream()
        }
    }

    abstract val logTag: String

    abstract fun onCall(args: Any?)

    companion object {
        const val BUFFER_SIZE = 1 shl 18 // 256kB
    }
}
