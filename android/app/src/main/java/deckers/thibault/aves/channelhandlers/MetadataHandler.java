package deckers.thibault.aves.channelhandlers;

import android.content.Context;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
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
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.exif.ExifSubIFDDirectory;
import com.drew.metadata.exif.GpsDirectory;
import com.drew.metadata.gif.GifAnimationDirectory;
import com.drew.metadata.webp.WebpDirectory;
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
import deckers.thibault.aves.utils.MimeTypes;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MetadataHandler implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "deckers.thibault/aves/metadata";

    // catalog metadata
    private static final String KEY_DATE_MILLIS = "dateMillis";
    private static final String KEY_IS_ANIMATED = "isAnimated";
    private static final String KEY_LATITUDE = "latitude";
    private static final String KEY_LONGITUDE = "longitude";
    private static final String KEY_VIDEO_ROTATION = "videoRotation";
    private static final String KEY_XMP_SUBJECTS = "xmpSubjects";
    private static final String KEY_XMP_TITLE_DESCRIPTION = "xmpTitleDescription";

    // overlay metadata
    private static final String KEY_APERTURE = "aperture";
    private static final String KEY_EXPOSURE_TIME = "exposureTime";
    private static final String KEY_FOCAL_LENGTH = "focalLength";
    private static final String KEY_ISO = "iso";

    // XMP
    private static final String XMP_DC_SCHEMA_NS = "http://purl.org/dc/elements/1.1/";
    private static final String XMP_SUBJECT_PROP_NAME = "dc:subject";
    private static final String XMP_TITLE_PROP_NAME = "dc:title";
    private static final String XMP_DESCRIPTION_PROP_NAME = "dc:description";
    private static final String XMP_GENERIC_LANG = "";
    private static final String XMP_SPECIFIC_LANG = "en-US";

    private static final Pattern VIDEO_LOCATION_PATTERN = Pattern.compile("([+-][.0-9]+)([+-][.0-9]+)/?");

    private Context context;

    public MetadataHandler(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getAllMetadata":
                new Thread(() -> getAllMetadata(call, new MethodResultWrapper(result))).start();
                break;
            case "getCatalogMetadata":
                new Thread(() -> getCatalogMetadata(call, new MethodResultWrapper(result))).start();
                break;
            case "getOverlayMetadata":
                new Thread(() -> getOverlayMetadata(call, new MethodResultWrapper(result))).start();
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private boolean isVideo(@Nullable String mimeType) {
        return mimeType != null && mimeType.startsWith(MimeTypes.VIDEO);
    }

    private InputStream getInputStream(String path, String uri) throws FileNotFoundException {
        // FileInputStream is faster than input stream from ContentResolver
        return path != null ? new FileInputStream(path) : context.getContentResolver().openInputStream(Uri.parse(uri));
    }

    private void getAllMetadata(MethodCall call, MethodChannel.Result result) {
        String path = call.argument("path");
        String uri = call.argument("uri");

        Map<String, Map<String, String>> metadataMap = new HashMap<>();

        try (InputStream is = getInputStream(path, uri)) {
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
            result.error("getAllMetadata-filenotfound", "failed to get metadata for uri=" + uri + ", path=" + path, e.getMessage());
        } catch (Exception e) {
            result.error("getAllMetadata-exception", "failed to get metadata for uri=" + uri + ", path=" + path, e.getMessage());
        }
    }

    private void getAllVideoMetadataFallback(MethodCall call, MethodChannel.Result result) {
        String path = call.argument("path");
        String uri = call.argument("uri");

        Map<String, Map<String, String>> metadataMap = new HashMap<>();
        Map<String, String> dirMap = new HashMap<>();
        // unnamed fallback directory
        metadataMap.put("", dirMap);

        MediaMetadataRetriever retriever = new MediaMetadataRetriever();
        try {
            if (path != null) {
                retriever.setDataSource(path);
            } else {
                retriever.setDataSource(context, Uri.parse(uri));
            }
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
            result.success(metadataMap);
        } catch (Exception e) {
            result.error("getAllVideoMetadataFallback-exception", "failed to get metadata for uri=" + uri + ", path=" + path, e.getMessage());
        } finally {
            retriever.release();
        }
    }

    private void getCatalogMetadata(MethodCall call, MethodChannel.Result result) {
        String mimeType = call.argument("mimeType");
        String path = call.argument("path");
        String uri = call.argument("uri");

        Map<String, Object> metadataMap = new HashMap<>();

        try (InputStream is = getInputStream(path, uri)) {
            if (!MimeTypes.MP2T.equals(mimeType)) {
                Metadata metadata = ImageMetadataReader.readMetadata(is);

                // EXIF
                putDateFromDirectoryTag(metadataMap, KEY_DATE_MILLIS, metadata, ExifSubIFDDirectory.class, ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL);
                if (!metadataMap.containsKey(KEY_DATE_MILLIS)) {
                    putDateFromDirectoryTag(metadataMap, KEY_DATE_MILLIS, metadata, ExifIFD0Directory.class, ExifIFD0Directory.TAG_DATETIME);
                }

                // GPS
                GpsDirectory gpsDir = metadata.getFirstDirectoryOfType(GpsDirectory.class);
                if (gpsDir != null) {
                    GeoLocation geoLocation = gpsDir.getGeoLocation();
                    if (geoLocation != null) {
                        metadataMap.put(KEY_LATITUDE, geoLocation.getLatitude());
                        metadataMap.put(KEY_LONGITUDE, geoLocation.getLongitude());
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
                            metadataMap.put(KEY_XMP_SUBJECTS, sb.toString());
                        }

                        putLocalizedTextFromXmp(metadataMap, KEY_XMP_TITLE_DESCRIPTION, xmpMeta, XMP_TITLE_PROP_NAME);
                        if (!metadataMap.containsKey(KEY_XMP_TITLE_DESCRIPTION)) {
                            putLocalizedTextFromXmp(metadataMap, KEY_XMP_TITLE_DESCRIPTION, xmpMeta, XMP_DESCRIPTION_PROP_NAME);
                        }
                    } catch (XMPException e) {
                        e.printStackTrace();
                    }
                }

                // Animated GIF & WEBP
                if (MimeTypes.GIF.equals(mimeType)) {
                    metadataMap.put(KEY_IS_ANIMATED, metadata.containsDirectoryOfType(GifAnimationDirectory.class));
                } else if (MimeTypes.WEBP.equals(mimeType)) {
                    WebpDirectory webpDir = metadata.getFirstDirectoryOfType(WebpDirectory.class);
                    if (webpDir != null) {
                        if (webpDir.containsTag(WebpDirectory.TAG_IS_ANIMATION)) {
                            metadataMap.put(KEY_IS_ANIMATED, webpDir.getBoolean(WebpDirectory.TAG_IS_ANIMATION));
                        }
                    }
                }
            }

            if (isVideo(mimeType)) {
                MediaMetadataRetriever retriever = new MediaMetadataRetriever();
                try {
                    if (path != null) {
                        retriever.setDataSource(path);
                    } else {
                        retriever.setDataSource(context, Uri.parse(uri));
                    }
                    String dateString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE);
                    String rotationString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION);
                    String locationString = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_LOCATION);

                    if (dateString != null) {
                        long dateMillis = MetadataHelper.parseVideoMetadataDate(dateString);
                        // some entries have an invalid default date (19040101T000000.000Z) that is before Epoch time
                        if (dateMillis > 0) {
                            metadataMap.put(KEY_DATE_MILLIS, dateMillis);
                        }
                    }
                    if (rotationString != null) {
                        metadataMap.put(KEY_VIDEO_ROTATION, Integer.parseInt(rotationString));
                    }
                    if (locationString != null) {
                        Matcher locationMatcher = VIDEO_LOCATION_PATTERN.matcher(locationString);
                        if (locationMatcher.find() && locationMatcher.groupCount() == 2) {
                            String latitudeString = locationMatcher.group(1);
                            String longitudeString = locationMatcher.group(2);
                            if (latitudeString != null && longitudeString != null) {
                                try {
                                    double latitude = Double.parseDouble(latitudeString);
                                    double longitude = Double.parseDouble(longitudeString);
                                    if (latitude != 0 && longitude != 0) {
                                        metadataMap.put(KEY_LATITUDE, latitude);
                                        metadataMap.put(KEY_LONGITUDE, longitude);
                                    }
                                } catch (NumberFormatException ex) {
                                    // ignore
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    result.error("getCatalogMetadata-exception", "failed to get video metadata for uri=" + uri + ", path=" + path, e.getMessage());
                } finally {
                    retriever.release();
                }
            }
            result.success(metadataMap);
        } catch (ImageProcessingException e) {
            result.error("getCatalogMetadata-imageprocessing", "failed to get metadata for uri=" + uri + ", path=" + path, e.getMessage());
        } catch (FileNotFoundException e) {
            result.error("getCatalogMetadata-filenotfound", "failed to get metadata for uri=" + uri + ", path=" + path, e.getMessage());
        } catch (Exception e) {
            result.error("getCatalogMetadata-exception", "failed to get metadata for uri=" + uri + ", path=" + path, e.getMessage());
        }
    }

    private void getOverlayMetadata(MethodCall call, MethodChannel.Result result) {
        String mimeType = call.argument("mimeType");
        String path = call.argument("path");
        String uri = call.argument("uri");

        Map<String, Object> metadataMap = new HashMap<>();

        if (isVideo(mimeType)) {
            result.success(metadataMap);
            return;
        }

        try (InputStream is = getInputStream(path, uri)) {
            Metadata metadata = ImageMetadataReader.readMetadata(is);
            ExifSubIFDDirectory directory = metadata.getFirstDirectoryOfType(ExifSubIFDDirectory.class);
            if (directory != null) {
                putDescriptionFromTag(metadataMap, KEY_APERTURE, directory, ExifSubIFDDirectory.TAG_FNUMBER);
                putStringFromTag(metadataMap, KEY_EXPOSURE_TIME, directory, ExifSubIFDDirectory.TAG_EXPOSURE_TIME);
                putDescriptionFromTag(metadataMap, KEY_FOCAL_LENGTH, directory, ExifSubIFDDirectory.TAG_FOCAL_LENGTH);
                if (directory.containsTag(ExifSubIFDDirectory.TAG_ISO_EQUIVALENT)) {
                    metadataMap.put(KEY_ISO, "ISO" + directory.getDescription(ExifSubIFDDirectory.TAG_ISO_EQUIVALENT));
                }
            }
            result.success(metadataMap);
        } catch (ImageProcessingException e) {
            result.error("getOverlayMetadata-imageprocessing", "failed to get metadata for uri=" + uri + ", path=" + path, e.getMessage());
        } catch (FileNotFoundException e) {
            result.error("getOverlayMetadata-filenotfound", "failed to get metadata for uri=" + uri + ", path=" + path, e.getMessage());
        } catch (Exception e) {
            result.error("getOverlayMetadata-exception", "failed to get metadata for uri=" + uri + ", path=" + path, e.getMessage());
        }
    }

    // convenience methods

    private static <T extends Directory> void putDateFromDirectoryTag(Map<String, Object> metadataMap, String key, Metadata metadata, Class<T> dirClass, int tag) {
        Directory dir = metadata.getFirstDirectoryOfType(dirClass);
        if (dir != null) {
            putDateFromTag(metadataMap, key, dir, tag);
        }
    }

    private static void putDateFromTag(Map<String, Object> metadataMap, String key, Directory dir, int tag) {
        if (dir.containsTag(tag)) {
            metadataMap.put(key, dir.getDate(tag, null, TimeZone.getDefault()).getTime());
        }
    }

    private static void putDescriptionFromTag(Map<String, Object> metadataMap, String key, Directory dir, int tag) {
        if (dir.containsTag(tag)) {
            metadataMap.put(key, dir.getDescription(tag));
        }
    }

    private static void putStringFromTag(Map<String, Object> metadataMap, String key, Directory dir, int tag) {
        if (dir.containsTag(tag)) {
            metadataMap.put(key, dir.getString(tag));
        }
    }

    private static void putLocalizedTextFromXmp(Map<String, Object> metadataMap, String key, XMPMeta xmpMeta, String propName) throws XMPException {
        if (xmpMeta.doesPropertyExist(XMP_DC_SCHEMA_NS, propName)) {
            XMPProperty item = xmpMeta.getLocalizedText(XMP_DC_SCHEMA_NS, propName, XMP_GENERIC_LANG, XMP_SPECIFIC_LANG);
            // double check retrieved items as the property sometimes is reported to exist but it is actually null
            if (item != null) {
                metadataMap.put(key, item.getValue());
            }
        }
    }
}