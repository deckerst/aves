package deckers.thibault.aves.utils

import android.os.Build
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.nio.channels.Channels
import java.nio.channels.FileChannel
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.StandardOpenOption

object FileUtils {
    fun getFolderSize(f: File): Long {
        var size: Long = 0
        if (f.isDirectory) {
            for (file in f.listFiles()!!) {
                size += getFolderSize(file)
            }
        } else {
            size = f.length()
        }
        return size
    }

    fun getFileSize(path: String): Long {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Files.size(Paths.get(path))
        } else {
            File(path).length()
        }
    }

    fun File.transferFrom(inputStream: InputStream?, streamLength: Long?) {
        inputStream ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && streamLength != null) {
            FileChannel.open(toPath(), StandardOpenOption.WRITE).use { fileOutput ->
                Channels.newChannel(inputStream).use { input ->
                    val actuallyTransferred = fileOutput.transferFrom(input, 0, streamLength)
                    if (actuallyTransferred != streamLength) {
                        throw Exception("failed to transfer $streamLength bytes, only transferred $actuallyTransferred bytes from input stream to file=$this")
                    }
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