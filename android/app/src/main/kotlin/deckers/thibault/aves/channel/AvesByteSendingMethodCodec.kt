package deckers.thibault.aves.channel

import android.util.Log
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MemoryUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodCodec
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.common.StandardMethodCodec
import java.nio.ByteBuffer

class AvesByteSendingMethodCodec private constructor() : MethodCodec {
    override fun decodeMethodCall(methodCall: ByteBuffer): MethodCall {
        return STANDARD.decodeMethodCall(methodCall)
    }

    override fun decodeEnvelope(envelope: ByteBuffer): Any {
        return STANDARD.decodeEnvelope(envelope)
    }

    override fun encodeMethodCall(methodCall: MethodCall): ByteBuffer {
        return STANDARD.encodeMethodCall(methodCall)
    }

    override fun encodeErrorEnvelope(errorCode: String, errorMessage: String?, errorDetails: Any?): ByteBuffer {
        return STANDARD.encodeErrorEnvelope(errorCode, errorMessage, errorDetails)
    }

    override fun encodeErrorEnvelopeWithStacktrace(errorCode: String, errorMessage: String?, errorDetails: Any?, errorStacktrace: String?): ByteBuffer {
        return STANDARD.encodeErrorEnvelopeWithStacktrace(errorCode, errorMessage, errorDetails, errorStacktrace)
    }

    // `StandardMethodCodec` writes the result to a `ByteArrayOutputStream`, then writes the stream to a `ByteBuffer`.
    // Here we only handle `ByteArray` results, but we avoid the intermediate stream.
    override fun encodeSuccessEnvelope(result: Any?): ByteBuffer {
        if (result !is ByteArray) {
            Log.e(LOG_TAG, "encodeSuccessEnvelope failed with result=$result")
            return encodeErrorEnvelope("invalid-result-type", "Called success with a result which is not a `ByteArray`, type=${result?.javaClass}", null)
        }

        val resultSize = result.size
        if (!MemoryUtils.canAllocate(resultSize)) {
            Log.e(LOG_TAG, "encodeSuccessEnvelope failed with result size=$resultSize")
            return encodeErrorEnvelope("large-result", "Called success with a result which is too large, size=$resultSize", null)
        }

        return ByteBuffer.allocateDirect(1 + resultSize).apply {
            // following `StandardMethodCodec`:
            // First byte is zero in success case, and non-zero otherwise.
            put(0)
            put(result)
        }
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<AvesByteSendingMethodCodec>()
        val INSTANCE = AvesByteSendingMethodCodec()
        private val STANDARD = StandardMethodCodec(StandardMessageCodec.INSTANCE)
    }
}