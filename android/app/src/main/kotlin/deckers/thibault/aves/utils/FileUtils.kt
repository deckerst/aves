package deckers.thibault.aves.utils

import android.os.Build
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.nio.channels.Channels
import java.nio.channels.FileChannel
import java.nio.file.StandardOpenOption

object FileUtils {
    fun File.transferFrom(inputStream: InputStream?, streamLength: Long?) {
        inputStream ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && streamLength != null) {
            FileChannel.open(toPath(), StandardOpenOption.WRITE).use { fileOutput ->
                Channels.newChannel(inputStream).use { input ->
                    fileOutput.transferFrom(input, 0, streamLength)
                }
            }
        } else {
            outputStream().use { fileOutput ->
                inputStream.use { input ->
                    input.copyTo(fileOutput)
                }
            }
        }
    }

    fun File.transferTo(outputStream: OutputStream) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            FileChannel.open(toPath()).use { fileInput ->
                Channels.newChannel(outputStream).use { output ->
                    fileInput.transferTo(0, fileInput.size(), output)
                }
            }
        } else {
            inputStream().use { fileInput ->
                outputStream.use { output ->
                    fileInput.copyTo(output)
                }
            }
        }
    }
}