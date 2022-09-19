package deckers.thibault.aves.channel

import android.util.Log
import deckers.thibault.aves.utils.LogUtils
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

    override fun encodeSuccessEnvelope(result: Any?): ByteBuffer {
        if (result is ByteArray) {
            val size = result.size
            return ByteBuffer.allocateDirect(4 + size).apply {
                put(0)
                put(result)
            }
        }

        Log.e(LOG_TAG, "encodeSuccessEnvelope failed with result=$result")
        return ByteBuffer.allocateDirect(0)
    }

    override fun encodeErrorEnvelope(errorCode: String, errorMessage: String?, errorDetails: Any?): ByteBuffer {
        Log.e(LOG_TAG, "encodeErrorEnvelope failed with errorCode=$errorCode, errorMessage=$errorMessage, errorDetails=$errorDetails")
        return ByteBuffer.allocateDirect(0)
    }

    override fun encodeErrorEnvelopeWithStacktrace(errorCode: String, errorMessage: String?, errorDetails: Any?, errorStacktrace: String?): ByteBuffer {
        Log.e(LOG_TAG, "encodeErrorEnvelopeWithStacktrace failed with errorCode=$errorCode, errorMessage=$errorMessage, errorDetails=$errorDetails, errorStacktrace=$errorStacktrace")
        return ByteBuffer.allocateDirect(0)
    }

    companion object {
        private val LOG_TAG = LogUtils.createTag<AvesByteSendingMethodCodec>()
        val INSTANCE = AvesByteSendingMethodCodec()
        private val STANDARD = StandardMethodCodec(StandardMessageCodec.INSTANCE)
    }
}