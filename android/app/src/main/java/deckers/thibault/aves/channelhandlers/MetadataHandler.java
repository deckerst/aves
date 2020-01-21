package deckers.thibault.aves.channelhandlers;

import android.content.Context;
import android.media.MediaMetadataRetriever;
import android.text.format.Formatter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.adobe.internal.xmp.XMPException;
import com.adobe.internal.xmp.XMPIterator;
import com.adobe.internal.xmp.XMPMeta;
import com.adobe.internal.xmp.properties.XMPProperty;
import com.adobe.internal.xmp.properties.XMPPropertyInfo;
import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.lang.GeoLocation;
import com.drew.metadata.Directory;
import com.drew.metadata.Metadata;
import com.drew.metadata.Tag;
import com.drew.metadata.exif.ExifSubIFDDirectory;
import com.drew.metadata.exif.GpsDirectory;
import com.drew.metadata.xmp.XmpDirectory;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import deckers.thibault.aves.utils.Constants;
import deckers.thibault.aves.utils.MetadataHelper;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MetadataHandler implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "deckers.thibault/aves/metadata";

    private static final String XMP_DC_SCHEMA_NS = "http://purl.org/dc/elements/1.1/";
    private static final String XMP_SUBJECT_PROP_NAME = "dc:subject";
    private static final Pattern videoLocationPattern = Pattern.compile("([+-][.0-9]+)([+-][.0-9]+)/?");

    private Context context;

    public MetadataHandler(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getAllMetadata":
                getAllMetadata(call, result);
                break;
            case "getCatalogMetadata":
                getCatalogMetadata(call, result);
                break;
            case "getOverlayMetadata":
                getOverlayMetadata(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private boolean isVideo(@Nullable String mimeType) {
        return mimeType != null && mimeType.startsWith(Constants.MIME_VIDEO);
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
            result.error("getAllMetadata-filenotfound", "failed to get metadata for path=" + path, e.getMessage());
        } catch (Exception e) {
            result.error("getAllMetadata-exception", "failed to get metadata for path=" + path, e.getMessage());
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
            result.error("getAllVideoMetadataFallback-exception", "failed to get metadata for path=" + path, e.getMessage());
        }
    }

    private void getCatalogMetadata(MethodCall call, MethodChannel.Result result) {
        String path = call.argument("path");
        String mimeType = call.argument("mimeType");
        try (InputStream is = new FileInputStream(path)) {
            Map<String, Object> metadataMap = new HashMap<>();
            if (!Constants.MIME_MP2T.equalsIgnoreCase(mimeType)) {
                Metadata metadata = ImageMetadataReader.readMetadata(is);

                // EXIF Sub-IFD
                ExifSubIFDDirectory exifSubDir = metadata.getFirstDirectoryOfType(ExifSubIFDDirectory.class);
                if (exifSubDir != null) {
                    if (exifSubDir.containsTag(ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL)) {
                        metadataMap.put("dateMillis", exifSubDir.getDate(ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL, null, TimeZone.getDefault()).getTime());
                    }
                }

                // GPS
                GpsDirectory gpsDir = metadata.getFirstDirectoryOfType(GpsDirectory.class);
                if (gpsDir != null) {
                    GeoLocation geoLocation = gpsDir.getGeoLocation();
                    if (geoLocation != null) {
                        metadataMap.put("latitude", geoLocation.getLatitude());
                        metadataMap.put("longitude", geoLocation.getLongitude());
                    }
                }

                // XMP
                XmpDirectory xmpDir = metadata.getFirstDirectoryOfType(XmpDirectory.class);
                if (xmpDir != null) {
                    XMPMeta xmpMeta = xmpDir.getXMPMeta();
                    try {
                        if (xmpMeta.doesPropertyExist(XMP_DC_SCHEMA_NS, XMP_SUBJECT_PROP_NAME)) {
                            StringBuilder sb = new StringBuilder();
                            int count = xmpMeta.countArrayItems(XMP_DC_SCHEMA_NS, XMP_SUBJECT_PROP_NAME);
                            for (int i = 1; i < count + 1; i++) {
                                XMPProperty item = xmpMeta.getArrayItem(XMP_DC_SCHEMA_NS, XMP_SUBJECT_PROP_NAME, i);
                                sb.append(";").append(item.getValue());
                            }
                            metadataMap.put("xmpSubjects", sb.toString());
                        }
                    } catch (XMPException e) {
                        e.printStackTrace();
                    }
                }
            }

            if (isVideo(call.argument("mimeType"))) {
                try {
                    MediaMetadataRetriever retriever = new MediaMetadataRetriever();
                    retriever.setDataSource(path);
                    String dateString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE);
                    String rotationString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION);
                    String locationString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_LOCATION);
                    retriever.release();

                    if (dateString != null) {
                        long dateMillis = MetadataHelper.parseVideoMetadataDate(dateString);
                        // some videos have an invalid default date (19040101T000000.000Z) that is before Epoch time
                        if (dateMillis > 0) {
                            metadataMap.put("dateMillis", dateMillis);
                        }
                    }
                    if (rotationString != null) {
                        metadataMap.put("videoRotation", Integer.parseInt(rotationString));
                    }
                    if (locationString != null) {
                        Matcher locationMatcher = videoLocationPattern.matcher(locationString);
                        if (locationMatcher.find() && locationMatcher.groupCount() == 2) {
                            String latitudeString = locationMatcher.group(1);
                            String longitudeString = locationMatcher.group(2);
                            if (latitudeString != null && longitudeString != null) {
                                try {
                                    double latitude = Double.parseDouble(latitudeString);
                                    double longitude = Double.parseDouble(longitudeString);
                                    if (latitude != 0 && longitude != 0) {
                                        metadataMap.put("latitude", latitude);
                                        metadataMap.put("longitude", longitude);
                                    }
                                } catch (NumberFormatException ex) {
                                    // ignore
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    result.error("getCatalogMetadata-exception", "failed to get video metadata for path=" + path, e.getMessage());
                }
            }
            result.success(metadataMap);
        } catch (ImageProcessingException e) {
            result.error("getCatalogMetadata-imageprocessing", "failed to get metadata for path=" + path, e.getMessage());
        } catch (FileNotFoundException e) {
            result.error("getCatalogMetadata-filenotfound", "failed to get metadata for path=" + path, e.getMessage());
        } catch (Exception e) {
            result.error("getCatalogMetadata-exception", "failed to get metadata for path=" + path, e.getMessage());
        }
    }

    private void getOverlayMetadata(MethodCall call, MethodChannel.Result result) {
        Map<String, String> metadataMap = new HashMap<>();

        if (isVideo(call.argument("mimeType"))) {
            result.success(metadataMap);
            return;
        }

        String path = call.argument("path");
        try (InputStream is = new FileInputStream(path)) {
            Metadata metadata = ImageMetadataReader.readMetadata(is);
            ExifSubIFDDirectory directory = metadata.getFirstDirectoryOfType(ExifSubIFDDirectory.class);
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
            result.error("getOverlayMetadata-imageprocessing", "failed to get metadata for path=" + path, e.getMessage());
        } catch (FileNotFoundException e) {
            result.error("getOverlayMetadata-filenotfound", "failed to get metadata for path=" + path, e.getMessage());
        } catch (Exception e) {
            result.error("getOverlayMetadata-exception", "failed to get metadata for path=" + path, e.getMessage());
        }
    }
}