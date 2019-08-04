package deckers.thibault.aves.channelhandlers;

import android.content.Context;
import android.media.MediaMetadataRetriever;
import android.text.format.Formatter;

import androidx.annotation.NonNull;

import com.adobe.xmp.XMPException;
import com.adobe.xmp.XMPIterator;
import com.adobe.xmp.XMPMeta;
import com.adobe.xmp.properties.XMPPropertyInfo;
import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.Directory;
import com.drew.metadata.Metadata;
import com.drew.metadata.Tag;
import com.drew.metadata.exif.ExifSubIFDDirectory;
import com.drew.metadata.xmp.XmpDirectory;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

import deckers.thibault.aves.utils.Constants;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MetadataHandler implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "deckers.thibault/aves/metadata";

    private Context context;

    public MetadataHandler(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getOverlayMetadata":
                getOverlayMetadata(call, result);
                break;
            case "getAllMetadata":
                getAllMetadata(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void getOverlayMetadata(MethodCall call, MethodChannel.Result result) {
        String path = call.argument("path");
        try (InputStream is = new FileInputStream(path)) {
            Metadata metadata = ImageMetadataReader.readMetadata(is);
            ExifSubIFDDirectory directory = metadata.getFirstDirectoryOfType(ExifSubIFDDirectory.class);
            Map<String, String> metadataMap = new HashMap<>();
            if (directory != null) {
                if (directory.containsTag(ExifSubIFDDirectory.TAG_FNUMBER)) {
                    metadataMap.put("aperture", directory.getDescription(ExifSubIFDDirectory.TAG_FNUMBER));
                }
                if (directory.containsTag(ExifSubIFDDirectory.TAG_EXPOSURE_TIME)) {
                    metadataMap.put("exposureTime", directory.getString(ExifSubIFDDirectory.TAG_EXPOSURE_TIME));
                }
                if (directory.containsTag(ExifSubIFDDirectory.TAG_FOCAL_LENGTH)) {
                    metadataMap.put("focalLength", directory.getDescription(ExifSubIFDDirectory.TAG_FOCAL_LENGTH));
                }
                if (directory.containsTag(ExifSubIFDDirectory.TAG_ISO_EQUIVALENT)) {
                    metadataMap.put("iso", "ISO" + directory.getDescription(ExifSubIFDDirectory.TAG_ISO_EQUIVALENT));
                }
            }
            result.success(metadataMap);
        } catch (ImageProcessingException e) {
            result.error("getOverlayMetadata-imageprocessing", "failed to get metadata for path=" + path + " (" + e.getMessage() + ")", null);
        } catch (FileNotFoundException e) {
            result.error("getOverlayMetadata-filenotfound", "failed to get metadata for path=" + path + " (" + e.getMessage() + ")", null);
        } catch (Exception e) {
            result.error("getOverlayMetadata-exception", "failed to get metadata for path=" + path, e);
        }
    }

    private void getAllMetadata(MethodCall call, MethodChannel.Result result) {
        String path = call.argument("path");
        try (InputStream is = new FileInputStream(path)) {
            Map<String, Map<String, String>> metadataMap = new HashMap<>();
            Metadata metadata = ImageMetadataReader.readMetadata(is);
            for (Directory dir : metadata.getDirectories()) {
                if (dir.getTagCount() > 0) {
                    Map<String, String> dirMap = new HashMap<>();
                    // directory name
                    metadataMap.put(dir.getName(), dirMap);
                    // tags
                    for (Tag tag : dir.getTags()) {
                        dirMap.put(tag.getTagName(), tag.getDescription());
                    }
                    if (dir instanceof XmpDirectory) {
                        try {
                            XmpDirectory xmpDir = (XmpDirectory) dir;
                            XMPMeta xmpMeta = xmpDir.getXMPMeta();
                            xmpMeta.sort();
                            XMPIterator xmpIterator = xmpMeta.iterator();
                            while (xmpIterator.hasNext()) {
                                XMPPropertyInfo prop = (XMPPropertyInfo) xmpIterator.next();
                                String xmpPath = prop.getPath();
                                String xmpValue = prop.getValue();
                                if (xmpPath != null && !xmpPath.isEmpty() && xmpValue != null && !xmpValue.isEmpty()) {
                                    dirMap.put(xmpPath, xmpValue);
                                }
                            }
                        } catch (XMPException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
            result.success(metadataMap);
        } catch (ImageProcessingException e) {
            getAllVideoMetadataFallback(call, result);
        } catch (FileNotFoundException e) {
            result.error("getAllMetadata-filenotfound", "failed to get metadata for path=" + path + " (" + e.getMessage() + ")", null);
        } catch (Exception e) {
            result.error("getAllMetadata-exception", "failed to get metadata for path=" + path, e);
        }
    }

    private void getAllVideoMetadataFallback(MethodCall call, MethodChannel.Result result) {
        String path = call.argument("path");

        try {
            Map<String, Map<String, String>> metadataMap = new HashMap<>();
            Map<String, String> dirMap = new HashMap<>();
            // unnamed fallback directory
            metadataMap.put("", dirMap);

            MediaMetadataRetriever retriever = new MediaMetadataRetriever();
            retriever.setDataSource(path);
            for (Map.Entry<Integer, String> kv : Constants.MEDIA_METADATA_KEYS.entrySet()) {
                Integer key = kv.getKey();
                String value = retriever.extractMetadata(key);
                if (value != null) {
                    switch (key) {
                        case MediaMetadataRetriever.METADATA_KEY_BITRATE:
                            value = Formatter.formatFileSize(context, Long.parseLong(value)) + "/sec";
                            break;
                        case MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION:
                            value += "°";
                            break;
                    }
                    dirMap.put(kv.getValue(), value);
                }
            }
            retriever.release();

            result.success(metadataMap);
        } catch (Exception e) {
            result.error("getAllVideoMetadataFallback-exception", "failed to get metadata for path=" + path, e);
        }
    }
}