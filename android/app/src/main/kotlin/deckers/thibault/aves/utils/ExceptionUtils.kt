package deckers.thibault.aves.utils

inline fun <reified T : Throwable> Exception.anyCauseIs(): Boolean {
    var cause: Throwable? = this
    while (cause != null) {
        if (cause is T) return true
        cause = cause.cause
    }
    return false
}
