package deckers.thibault.aves.utils

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.util.Log

object MemoryUtils {
    private val LOG_TAG = LogUtils.createTag<MemoryUtils>()
    private const val TYPE_ADVERTISED = "advertised"
    private const val TYPE_AVAILABLE = "available"
    private const val TYPE_FREE = "free"
    private const val TYPE_MAX = "max"
    private const val TYPE_TOTAL = "total"
    private const val TYPE_USED = "used"

    fun canAllocate(byteSize: Number?): Boolean {
        byteSize ?: return true
        val availableHeapSize = getAvailableHeapSize()
        val danger = byteSize.toLong() > availableHeapSize
        if (danger) {
            Log.e(LOG_TAG, "trying to handle $byteSize bytes, with only $availableHeapSize free bytes")
        }
        return !danger
    }

    fun getAvailableHeapSize() = getHeapSizes(listOf(TYPE_AVAILABLE))[TYPE_AVAILABLE] ?: 0

    fun getHeapSizes(types: List<String>): Map<String, Long?> {
        val result = HashMap<String, Long?>()
        val runtime = Runtime.getRuntime()
        val max = runtime.maxMemory()
        val total = runtime.totalMemory()
        val free = runtime.freeMemory()
        val used = total - free
        for (type in types) {
            result[type] = when (type) {
                TYPE_AVAILABLE -> max - used
                TYPE_FREE -> free
                TYPE_MAX -> max
                TYPE_TOTAL -> total
                TYPE_USED -> used
                else -> null
            }
        }
        return result
    }

    fun getRamSizes(context: Context, types: List<String>): Map<String, Long?> {
        val result = HashMap<String, Long?>()

        val memoryInfo = ActivityManager.MemoryInfo()
        val activityManager: ActivityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        activityManager.getMemoryInfo(memoryInfo)

        val available = memoryInfo.availMem
        val total = memoryInfo.totalMem
        val advertised = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) memoryInfo.advertisedMem else null
        val free = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CINNAMON_BUN) memoryInfo.freeMem else null
        for (type in types) {
            result[type] = when (type) {
                TYPE_ADVERTISED -> advertised
                TYPE_AVAILABLE -> available
                TYPE_FREE -> free
                TYPE_TOTAL -> total
                else -> null
            }
        }
        return result
    }
}