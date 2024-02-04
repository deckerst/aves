package deckers.thibault.aves.metadata

import android.content.Context
import android.net.Uri
import android.util.Log
import deckers.thibault.aves.metadata.xmp.XMP
import deckers.thibault.aves.utils.LogUtils
import deckers.thibault.aves.utils.MimeTypes
import deckers.thibault.aves.utils.StorageUtils
import deckers.thibault.aves.utils.toByteArray
import deckers.thibault.aves.utils.toHex
import org.mp4parser.*
import org.mp4parser.boxes.UnknownBox
import org.mp4parser.boxes.UserBox
import org.mp4parser.boxes.apple.AppleCoverBox
import org.mp4parser.boxes.apple.AppleGPSCoordinatesBox
import org.mp4parser.boxes.apple.AppleItemListBox
import org.mp4parser.boxes.apple.AppleVariableSignedIntegerBox
import org.mp4parser.boxes.apple.Utf8AppleDataBox
import org.mp4parser.boxes.iso14496.part12.*
import org.mp4parser.boxes.threegpp.ts26244.AuthorBox
import org.mp4parser.support.AbstractBox
import org.mp4parser.support.Matrix
import org.mp4parser.tools.Path
import java.io.ByteArrayOutputStream
import java.io.FileInputStream
import java.nio.channels.Channels

object Mp4ParserHelper {
    private val LOG_TAG = LogUtils.createTag<Mp4ParserHelper>()

    // arbitrary size to detect boxes that may yield an OOM
    private const val BOX_SIZE_DANGER_THRESHOLD = 3 * (1 shl 20) // MB

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
                            if (size > BOX_SIZE_DANGER_THRESHOLD) throw Mp4TooLargeException(type, "box (type=$type size=$size) is too large")
                            false
                        }
                    }
                    // creating `IsoFile` with a `File` or a `File.inputStream()` yields `No such device`
                    IsoFile(channel, boxParser).use { isoFile ->
                        val fragmented = isoFile.boxes.any { box -> box is MovieFragmentBox || box is SegmentIndexBox }
                        if (fragmented) throw Exception("editing fragmented movies is not supported")

                        val lastContentBox = isoFile.boxes.reversed().firstOrNull { box ->
                            when {
                                box == isoFile.movieBox -> false
                                testXmpBox(box) -> false
                                box is FreeBox -> false
                                else -> true
                            }
                        }
                        lastContentBox ?: throw Exception("failed to find last content box")
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

                    is UserBox -> sb.appendLine("${"\t".repeat(indent)}[$boxType] userType=${box.userType.toHex()} $box")
                    else -> sb.appendLine("${"\t".repeat(indent)}[$boxType] $box")
                }
            } catch (e: Exception) {
                sb.appendLine("${"\t".repeat(indent)}failed to access box type=$boxType exception=${e.message}")
            }
        }
    }

    fun Box.toBytes(): ByteArray {
        if (size > BOX_SIZE_DANGER_THRESHOLD) throw Exception("box (type=$type size=$size) is too large")
        val stream = ByteArrayOutputStream(size.toInt())
        Channels.newChannel(stream).use { getBox(it) }
        return stream.toByteArray()
    }

    fun metadataBoxParser() = PropertyBoxParserImpl().apply {
        val skippedTypes = listOf(
            // parsing `MediaDataBox` can take a long time
            MediaDataBox.TYPE,
            // parsing `SampleTableBox` or `FreeBox` may yield OOM
            SampleTableBox.TYPE, FreeBox.TYPE,
            // some files are padded with `0` but the parser does not stop, reads type "0000",
            // then a large size from following "0000", which may yield OOM
            "0000",
        )
        setBoxSkipper { type, size ->
            if (skippedTypes.contains(type)) return@setBoxSkipper true
            if (size > BOX_SIZE_DANGER_THRESHOLD) throw Exception("box (type=$type size=$size) is too large")
            false
        }
    }

    fun getUserData(
        context: Context,
        mimeType: String,
        uri: Uri,
    ): MutableMap<String, String> {
        val fields = HashMap<String, String>()
        if (mimeType != MimeTypes.MP4) return fields
        try {
            // we can skip uninteresting boxes with a seekable data source
            val pfd = StorageUtils.openInputFileDescriptor(context, uri) ?: throw Exception("failed to open file descriptor for uri=$uri")
            pfd.use {
                FileInputStream(it.fileDescriptor).use { stream ->
                    stream.channel.use { channel ->
                        // creating `IsoFile` with a `File` or a `File.inputStream()` yields `No such device`
                        IsoFile(channel, metadataBoxParser()).use { isoFile ->
                            val userDataBox = Path.getPath<UserDataBox>(isoFile.movieBox, UserDataBox.TYPE)
                            if (userDataBox != null) {
                                fields.putAll(extractBoxFields(userDataBox))
                            }
                        }
                    }
                }
            }
        } catch (e: NoClassDefFoundError) {
            Log.w(LOG_TAG, "failed to parse MP4 for mimeType=$mimeType uri=$uri", e)
        } catch (e: Exception) {
            Log.w(LOG_TAG, "failed to get User Data box by MP4 parser for mimeType=$mimeType uri=$uri", e)
        }
        return fields
    }

    private fun extractBoxFields(container: Container): HashMap<String, String> {
        val fields = HashMap<String, String>()
        for (box in container.boxes) {
            if (box is AbstractBox && !box.isParsed) {
                box.parseDetails()
            }
            val type = box.type
            val key = boxTypeMetadataKey(type)
            when (box) {
                is AuthorBox -> fields[key] = box.author
                is AppleCoverBox -> fields[key] = "[${box.coverData.size} bytes]"
                is AppleGPSCoordinatesBox -> fields[key] = box.value
                is AppleItemListBox -> fields.putAll(extractBoxFields(box))
                is AppleVariableSignedIntegerBox -> fields[key] = box.value.toString()
                is Utf8AppleDataBox -> fields[key] = box.value

                is HandlerBox -> {}
                is MetaBox -> {
                    val handlerBox = Path.getPath<HandlerBox>(box, HandlerBox.TYPE).apply { parseDetails() }
                    when (val handlerType = handlerBox?.handlerType ?: MetaBox.TYPE) {
                        "mdir" -> fields.putAll(extractBoxFields(box))
                        else -> fields.putAll(extractBoxFields(box).map { Pair("$handlerType/${it.key}", it.value) }.toMap())
                    }
                }

                is UnknownBox -> {
                    val byteBuffer = box.data
                    val remaining = byteBuffer.remaining()
                    if (remaining > 512) {
                        fields[key] = "[$remaining bytes]"
                    } else {
                        val bytes = byteBuffer.toByteArray()
                        when (type) {
                            "SDLN",
                            "smrd" -> fields[key] = String(bytes)

                            else -> fields[key] = "0x${bytes.toHex()}"
                        }
                    }
                }

                else -> fields[key] = box.toString()
            }
        }
        return fields
    }

    // cf https://exiftool.org/TagNames/QuickTime.html
    private fun boxTypeMetadataKey(type: String) = when (type) {
        "auth" -> "Author"
        "catg" -> "Category"
        "covr" -> "Cover Art"
        "keyw" -> "Keyword"
        "mcvr" -> "Preview Image"
        "pcst" -> "Podcast"
        "SDLN" -> "Play Mode"
        "stik" -> "Media Type"
        "©alb" -> "Album"
        "©ART" -> "Artist"
        "©aut" -> "Author"
        "©cmt" -> "Comment"
        "©day" -> "Year"
        "©des" -> "Description"
        "©gen" -> "Genre"
        "©nam" -> "Title"
        "©too" -> "Encoder"
        "©xyz" -> "GPS Coordinates"
        else -> type
    }
}

class Mp4TooLargeException(val type: String, message: String) : RuntimeException(message)
