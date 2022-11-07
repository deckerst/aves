package deckers.thibault.aves.utils

import android.util.Log

object MemoryUtils {
    private val LOG_TAG = LogUtils.createTag<MemoryUtils>()

    fun canAllocate(byteSize: Number?): Boolean {
        byteSize ?: return true
        val availableHeapSize = Runtime.getRuntime().let { it.maxMemory() - (it.totalMemory() - it.freeMemory()) }
        val danger = byteSize.toLong() > availableHeapSize
        if (danger) {
            Log.e(LOG_TAG, "trying to handle $byteSize bytes, with only $availableHeapSize free bytes")
        }
        return !danger
    }
}