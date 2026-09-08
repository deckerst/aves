package deckers.thibault.aves.utils

import android.os.Build
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.nio.channels.Channels
import java.nio.channels.FileChannel
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.StandardCopyOption
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

    // returns whether file was successfully deleted
    fun delete(file: File): Boolean {
        if (!file.exists()) return true

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Files.deleteIfExists(Paths.get(file.absolutePath))
        } else {
            file.delete()
        }
    }

    // move, replacing existing target file, if any
    fun move(sourceFile: File, targetFile: File) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Files.move(
                Paths.get(sourceFile.absolutePath),
                Paths.get(targetFile.absolutePath),
                StandardCopyOption.REPLACE_EXISTING,
            )
        } else {
            if (targetFile.exists()) {
                if (!targetFile.delete()) {
                    throw IOException("failed to delete existing target file=$targetFile")
                }
            }
            if (!sourceFile.renameTo(targetFile)) {
                copy(sourceFile, targetFile)
                if (!sourceFile.delete()) {
                    if (!targetFile.delete()) {
                        throw IOException("failed to delete target file=$targetFile")
                    }
                    throw IOException("failed to delete source file=$sourceFile")
                }
            }
        }
    }

    fun copy(sourceFile: File, targetFile: File) {
        FileInputStream(sourceFile).use { inputStream ->
            FileOutputStream(targetFile).use { outputStream ->
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    android.os.FileUtils.copy(inputStream, outputStream)
                } else {
                    // `FileChannel.transferFrom`/`FileChannel.transferTo` documentation:
                    // "This method is potentially much more efficient than a simple loop that reads from the
                    // source channel and writes to this channel. Many operating systems can transfer bytes
                    // directly from the source channel into the filesystem cache without actually copying them."
                    val inChannel = inputStream.getChannel()
                    val outChannel = outputStream.getChannel()
                    inChannel.transferTo(0, sourceFile.length(), outChannel)
                }
            }
        }
    }

    // use `FileChannel` when possible, as it is potentially more efficient according to documentation
    fun File.copyFrom(inputStream: InputStream?, streamLength: Long?) {
        inputStream ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && streamLength != null) {
            FileChannel.open(
                toPath(),
                StandardOpenOption.WRITE,
                StandardOpenOption.TRUNCATE_EXISTING,
                StandardOpenOption.CREATE,
            ).use { fileOutput ->
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

    // use `FileChannel` when possible, as it is potentially more efficient according to documentation
    fun File.copyTo(outputStream: OutputStream) {
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