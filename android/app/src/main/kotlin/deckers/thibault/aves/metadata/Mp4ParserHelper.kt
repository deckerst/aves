package deckers.thibault.aves.metadata

import android.content.Context
import android.net.Uri
import deckers.thibault.aves.utils.StorageUtils
import org.mp4parser.*
import org.mp4parser.boxes.UserBox
import org.mp4parser.boxes.apple.AppleGPSCoordinatesBox
import org.mp4parser.boxes.iso14496.part12.*
import org.mp4parser.support.AbstractBox
import org.mp4parser.support.Matrix
import org.mp4parser.tools.Path
import java.io.ByteArrayOutputStream
import java.io.FileInputStream
import java.nio.channels.Channels

object Mp4ParserHelper {
    // arbitrary size to detect boxes that may yield an OOM
    const val BOX_SIZE_DANGER_THRESHOLD = 3 * (1 shl 20) // MB

    fun computeEdits(context: Context, uri: Uri, modifier: (isoFile: IsoFile) -> Unit): List<Pair<Long, ByteArray>> {
        // we can skip uninteresting boxes with a seekable data source
        val pfd = StorageUtils.openInputFileDescriptor(context, uri) ?: throw Exception("failed to open file descriptor for uri=$uri")
        pfd.use {
            FileInputStream(it.fileDescriptor).use { stream ->
                stream.channel.use { channel ->
                    val boxParser = PropertyBoxParserImpl().apply {
                        // do not skip anything inside `MovieBox` as it will be parsed and rewritten for editing
                        // do not skip weird boxes (like trailing "0000" box), to fail fast if it is large
                        val skippedTypes = listOf(
                            // parsing `MediaDataBox` can take a long time
                            MediaDataBox.TYPE,
                        )
                        setBoxSkipper { type, size ->
                            if (skippedTypes.contains(type)) return@setBoxSkipper true
                            if (size > BOX_SIZE_DANGER_THRESHOLD) throw Exception("box (type=$type size=$size) is too large")
                            false
                        }
                    }
                    // creating `IsoFile` with a `File` or a `File.inputStream()` yields `No such device`
                    IsoFile(channel, boxParser).use { isoFile ->
                        val lastContentBox = isoFile.boxes.reversed().firstOrNull { box ->
                            when {
                                box == isoFile.movieBox -> false
                                testXmpBox(box) -> false
                                box is FreeBox -> false
                                else -> true
                            }
                        }
                        lastContentBox ?: throw Exception("failed to find last context box")
                        val oldFileSize = isoFile.size
                        var appendOffset = (isoFile.getBoxOffset { box -> box == lastContentBox })!! + lastContentBox.size

                        val edits = arrayListOf<Pair<Long, ByteArray>>()
                        fun addFreeBoxEdit(offset: Long, size: Long) = edits.add(Pair(offset, FreeBox(size.toInt() - 8).toBytes()))

                        // replace existing movie box by a free box
                        isoFile.getBoxOffset { box -> box.type == MovieBox.TYPE }?.let { offset ->
                            addFreeBoxEdit(offset, isoFile.movieBox.size)
                        }

                        // replace existing XMP box by a free box
                        isoFile.getBoxOffset { box -> testXmpBox(box) }?.let { offset ->
                            addFreeBoxEdit(offset, isoFile.xmpBox!!.size)
                        }

                        modifier(isoFile)

                        // write edited movie box
                        val movieBoxBytes = isoFile.movieBox.toBytes()
                        edits.removeAll { (offset, _) -> offset == appendOffset }
                        edits.add(Pair(appendOffset, movieBoxBytes))
                        appendOffset += movieBoxBytes.size

                        // write edited XMP box
                        isoFile.xmpBox?.let { box ->
                            edits.removeAll { (offset, _) -> offset == appendOffset }
                            edits.add(Pair(appendOffset, box.toBytes()))
                            appendOffset += box.size
                        }

                        // write trailing free box instead of truncating
                        val trailing = oldFileSize - appendOffset
                        if (trailing > 0) {
                            addFreeBoxEdit(appendOffset, trailing)
                        }

                        return edits
                    }
                }
            }
        }
    }

    // according to XMP Specification Part 3 - Storage in Files,
    // XMP is embedded in MPEG-4 files using a top-level UUID box
    private fun testXmpBox(box: Box): Boolean {
        if (box is UserBox) {
            if (!box.isParsed) {
                box.parseDetails()
            }
            return box.userType.contentEquals(XMP.mp4Uuid)
        }
        return false
    }

    // extensions

    fun IsoFile.updateLocation(locationIso6709: String?) {
        // Apple GPS Coordinates Box can be in various locations:
        // - moov[0]/udta[0]/©xyz
        // - moov[0]/meta[0]/ilst/©xyz
        // - others?
        removeBoxes(AppleGPSCoordinatesBox::class.java, true)

        locationIso6709 ?: return

        var userDataBox = Path.getPath<UserDataBox>(movieBox, UserDataBox.TYPE)
        if (userDataBox == null) {
            userDataBox = UserDataBox()
            movieBox.addBox(userDataBox)
        }

        userDataBox.addBox(AppleGPSCoordinatesBox().apply {
            value = locationIso6709
        })
    }

    fun IsoFile.updateRotation(degrees: Int): Boolean {
        val matrix: Matrix = when (degrees) {
            0 -> Matrix.ROTATE_0
            90 -> Matrix.ROTATE_90
            180 -> Matrix.ROTATE_180
            270 -> Matrix.ROTATE_270
            else -> throw Exception("failed because of invalid rotation degrees=$degrees")
        }

        var success = false
        movieBox.getBoxes(TrackHeaderBox::class.java, true).filter { tkhd ->
            if (!tkhd.isParsed) {
                tkhd.parseDetails()
            }
            tkhd.width > 0 && tkhd.height > 0
        }.forEach { tkhd ->
            if (!setOf(Matrix.ROTATE_0, Matrix.ROTATE_90, Matrix.ROTATE_180, Matrix.ROTATE_270).contains(tkhd.matrix)) {
                throw Exception("failed because existing matrix is not a simple rotation matrix")
            }
            tkhd.matrix = matrix
            success = true
        }
        return success
    }

    fun IsoFile.updateXmp(xmp: String?) {
        val xmpBox = xmpBox
        if (xmp != null) {
            val xmpData = xmp.toByteArray(Charsets.UTF_8)
            if (xmpBox == null) {
                addBox(UserBox(XMP.mp4Uuid).apply {
                    data = xmpData
                })
            } else {
                xmpBox.data = xmpData
            }
        } else if (xmpBox != null) {
            removeBox(xmpBox)
        }
    }

    private fun IsoFile.getBoxOffset(test: (box: Box) -> Boolean): Long? {
        var offset = 0L
        for (box in boxes) {
            if (test(box)) {
                return offset
            }
            offset += box.size
        }
        return null
    }

    private val IsoFile.xmpBox: UserBox?
        get() = boxes.firstOrNull { testXmpBox(it) } as UserBox?

    fun <T : Box> Container.processBoxes(clazz: Class<T>, recursive: Boolean, apply: (box: T, parent: Container) -> Unit) {
        // use a copy, in case box processing removes boxes
        for (box in ArrayList(boxes)) {
            if (clazz.isInstance(box)) {
                @Suppress("unchecked_cast")
                apply(box as T, this)
            }
            if (recursive && box is Container) {
                box.processBoxes(clazz, true, apply)
            }
        }
    }

    private fun <T : Box> Container.removeBoxes(clazz: Class<T>, recursive: Boolean) {
        processBoxes(clazz, recursive) { box, parent -> parent.removeBox(box) }
    }

    private fun Container.removeBox(box: Box) {
        boxes = boxes.apply { remove(box) }
    }

    fun Container.dumpBoxes(sb: StringBuilder, indent: Int = 0) {
        for (box in boxes) {
            val boxType = box.type
            try {
                if (box is AbstractBox && !box.isParsed) {
                    box.parseDetails()
                }
                when (box) {
                    is BasicContainer -> {
                        sb.appendLine("${"\t".repeat(indent)}[$boxType] ${box.javaClass.simpleName}")
                        box.dumpBoxes(sb, indent + 1)
                    }
                    is UserBox -> {
                        val userTypeHex = box.userType.joinToString("") { "%02x".format(it) }
                        sb.appendLine("${"\t".repeat(indent)}[$boxType] userType=$userTypeHex $box")
                    }
                    else -> sb.appendLine("${"\t".repeat(indent)}[$boxType] $box")
                }
            } catch (e: Exception) {
                sb.appendLine("${"\t".repeat(indent)}failed to access box type=$boxType exception=${e.message}")
            }
        }
    }

    fun Box.toBytes(): ByteArray {
        val stream = ByteArrayOutputStream(size.toInt())
        Channels.newChannel(stream).use { getBox(it) }
        return stream.toByteArray()
    }
}
