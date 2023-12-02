package deckers.thibault.aves.metadata.metadataextractor

import com.drew.lang.RandomAccessReader
import com.drew.metadata.Directory
import com.drew.metadata.Metadata
import com.drew.metadata.exif.ExifIFD0Directory
import com.drew.metadata.exif.ExifSubIFDDirectory
import com.drew.metadata.exif.ExifTiffHandler
import java.io.IOException

class SafeExifTiffHandler(metadata: Metadata, parentDirectory: Directory?, exifStartOffset: Int) : ExifTiffHandler(metadata, parentDirectory, exifStartOffset) {
    @Throws(IOException::class)
    override fun customProcessTag(
        tagOffset: Int,
        processedIfdOffsets: MutableSet<Int>?,
        tiffHeaderOffset: Int,
        reader: RandomAccessReader?,
        tagId: Int,
        byteCount: Int,
    ): Boolean {
        if (tagId == ExifSubIFDDirectory.TAG_APPLICATION_NOTES && (_currentDirectory is ExifIFD0Directory || _currentDirectory is ExifSubIFDDirectory)) {
            SafeXmpReader().extract(reader!!.getNullTerminatedBytes(tagOffset, byteCount), _metadata, _currentDirectory)
            return true
        }

        return super.customProcessTag(tagOffset, processedIfdOffsets, tiffHeaderOffset, reader, tagId, byteCount)
    }
}