package deckers.thibault.aves.model

import java.io.IOException

class ExifInterfaceException(ex: Exception) : RuntimeException(ex)

class FileDescriptorException(message: String, cause: Throwable? = null) : IOException(message, cause)

class Mp4TooLargeException(val type: String, message: String) : RuntimeException(message)

class Mp4FragmentedException(message: String) : RuntimeException(message)

class Mp4ZeroSizeBoxException(message: String, cause: Throwable) : RuntimeException(message, cause)
