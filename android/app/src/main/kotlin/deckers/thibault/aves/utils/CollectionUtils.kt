package deckers.thibault.aves.utils

import android.os.Build

// compatibility extension for `removeIf` for API < N
fun <E> MutableList<E>.compatRemoveIf(filter: (t: E) -> Boolean): Boolean {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        this.removeIf(filter)
    } else {
        var removed = false
        val each = this.iterator()
        while (each.hasNext()) {
            if (filter(each.next())) {
                each.remove()
                removed = true
            }
        }
        return removed
    }
}