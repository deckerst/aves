package deckers.thibault.aves.utils;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.SharedPreferences;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.MimeTypeMap;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.commonsware.cwac.document.DocumentFileCompat;
import com.google.common.base.Splitter;
import com.google.common.collect.Lists;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

public class StorageUtils {
    private static final String LOG_TAG = Utils.createLogTag(StorageUtils.class);

    /**
     * Volume paths
     */

    // volume paths, with trailing "/"
    private static String[] mStorageVolumePaths;

    // primary volume path, with trailing "/"
    private static String mPrimaryVolumePath;

    private static String getPrimaryVolumePath() {
        if (mPrimaryVolumePath == null) {
            mPrimaryVolumePath = findPrimaryVolumePath();
        }
        return mPrimaryVolumePath;
    }

    public static String[] getVolumePaths(Context context) {
        if (mStorageVolumePaths == null) {
            mStorageVolumePaths = findVolumePaths(context);
        }
        return mStorageVolumePaths;
    }

    public static Optional<String> getVolumePath(Context context, @NonNull String anyPath) {
        return Arrays.stream(getVolumePaths(context)).filter(anyPath::startsWith).findFirst();
    }

    @Nullable
    private static Iterator<String> getPathStepIterator(Context context, @NonNull String anyPath) {
        Optional<String> volumePathOpt = getVolumePath(context, anyPath);
        if (!volumePathOpt.isPresent()) return null;

        String relativePath = null, filename = null;
        int lastSeparatorIndex = anyPath.lastIndexOf(File.separator) + 1;
        int volumePathLength = volumePathOpt.get().length();
        if (lastSeparatorIndex > volumePathLength) {
            filename = anyPath.substring(lastSeparatorIndex);
            relativePath = anyPath.substring(volumePathLength, lastSeparatorIndex);
        }
        if (relativePath == null) return null;

        ArrayList<String> pathSteps = Lists.newArrayList(Splitter.on(File.separatorChar)
                .trimResults().omitEmptyStrings().split(relativePath));
        if (filename.length() > 0) {
            pathSteps.add(filename);
        }
        return pathSteps.iterator();
    }

    private static String findPrimaryVolumePath() {
        String primaryVolumePath = Environment.getExternalStorageDirectory().getAbsolutePath();
        if (!primaryVolumePath.endsWith(File.separator)) {
            primaryVolumePath += File.separator;
        }
        return primaryVolumePath;
    }

    /**
     * Returns all available SD-Cards in the system (include emulated)
     * <p/>
     * Warning: Hack! Based on Android source code of version 4.3 (API 18)
     * Because there is no standard way to get it.
     * Edited by hendrawd
     *
     * @return paths to all available SD-Cards in the system (include emulated)
     */
    @SuppressLint("ObsoleteSdkInt")
    private static String[] findVolumePaths(Context context) {
        // Final set of paths
        final Set<String> rv = new HashSet<>();

        // Primary emulated SD-CARD
        final String rawEmulatedStorageTarget = System.getenv("EMULATED_STORAGE_TARGET");

        if (TextUtils.isEmpty(rawEmulatedStorageTarget)) {
            // fix of empty raw emulated storage on marshmallow
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                List<File> files;
                boolean validFiles;
                do {
                    // `getExternalFilesDirs` sometimes include `null` when called right after getting read access
                    // (e.g. on API 30 emulator) so we retry until the file system is ready
                    files = Arrays.asList(context.getExternalFilesDirs(null));
                    validFiles = !files.contains(null);
                    if (!validFiles) {
                        try {
                            Thread.sleep(100);
                        } catch (InterruptedException e) {
                            Log.e(LOG_TAG, "insomnia", e);
                        }
                    }
                } while(!validFiles);
                for (File file : files) {
                    String applicationSpecificAbsolutePath = file.getAbsolutePath();
                    String emulatedRootPath = applicationSpecificAbsolutePath.substring(0, applicationSpecificAbsolutePath.indexOf("Android/data"));
                    rv.add(emulatedRootPath);
                }
            } else {
                // Primary physical SD-CARD (not emulated)
                final String rawExternalStorage = System.getenv("EXTERNAL_STORAGE");

                // Device has physical external storage; use plain paths.
                if (TextUtils.isEmpty(rawExternalStorage)) {
                    // EXTERNAL_STORAGE undefined; falling back to default.
                    rv.addAll(Arrays.asList(getPhysicalPaths()));
                } else {
                    rv.add(rawExternalStorage);
                }
            }
        } else {
            // Device has emulated storage; external storage paths should have userId burned into them.
            final String rawUserId;
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR1) {
                rawUserId = "";
            } else {
                final String path = Environment.getExternalStorageDirectory().getAbsolutePath();
                final String[] folders = path.split(File.separator);
                final String lastFolder = folders[folders.length - 1];
                boolean isDigit = TextUtils.isDigitsOnly(lastFolder);
                rawUserId = isDigit ? lastFolder : "";
            }
            // /storage/emulated/0[1,2,...]
            if (TextUtils.isEmpty(rawUserId)) {
                rv.add(rawEmulatedStorageTarget);
            } else {
                rv.add(rawEmulatedStorageTarget + File.separator + rawUserId);
            }
        }

        // All Secondary SD-CARDs (all exclude primary) separated by ":"
        final String rawSecondaryStoragesStr = System.getenv("SECONDARY_STORAGE");

        // Add all secondary storages
        if (!TextUtils.isEmpty(rawSecondaryStoragesStr)) {
            // All Secondary SD-CARDs split into array
            final String[] rawSecondaryStorages = rawSecondaryStoragesStr.split(File.pathSeparator);
            Collections.addAll(rv, rawSecondaryStorages);
        }

        String[] paths = rv.toArray(new String[0]);
        for (int i = 0; i < paths.length; i++) {
            String path = paths[i];
            if (!path.endsWith(File.separator)) {
                paths[i] = path + File.separator;
            }
        }
        return paths;
    }

    /**
     * @return physicalPaths based on phone model
     */
    @SuppressLint("SdCardPath")
    private static String[] getPhysicalPaths() {
        return new String[]{
                "/storage/sdcard0",
                "/storage/sdcard1",                 //Motorola Xoom
                "/storage/extsdcard",               //Samsung SGS3
                "/storage/sdcard0/external_sdcard", //User request
                "/mnt/extsdcard",
                "/mnt/sdcard/external_sd",          //Samsung galaxy family
                "/mnt/external_sd",
                "/mnt/media_rw/sdcard1",            //4.4.2 on CyanogenMod S3
                "/removable/microsd",               //Asus transformer prime
                "/mnt/emmc",
                "/storage/external_SD",             //LG
                "/storage/ext_sd",                  //HTC One Max
                "/storage/removable/sdcard1",       //Sony Xperia Z1
                "/data/sdext",
                "/data/sdext2",
                "/data/sdext3",
                "/data/sdext4",
                "/sdcard1",                         //Sony Xperia Z
                "/sdcard2",                         //HTC One M8s
                "/storage/microsd"                  //ASUS ZenFone 2
        };
    }

    /**
     * Volume tree URIs
     */

    // serialized map from storage volume paths to their document tree URIs, from the Documents Provider
    // e.g. "/storage/12A9-8B42" -> "content://com.android.externalstorage.documents/tree/12A9-8B42%3A"
    private static final String PREF_VOLUME_TREE_URIS = "volume_tree_uris";

    public static void setVolumeTreeUri(Activity activity, String volumePath, String treeUri) {
        Map<String, String> map = getVolumeTreeUris(activity);
        map.put(volumePath, treeUri);

        SharedPreferences.Editor editor = activity.getPreferences(Context.MODE_PRIVATE).edit();
        String json = new JSONObject(map).toString();
        editor.putString(PREF_VOLUME_TREE_URIS, json);
        editor.apply();
    }

    private static Map<String, String> getVolumeTreeUris(Activity activity) {
        Map<String, String> map = new HashMap<>();

        SharedPreferences preferences = activity.getPreferences(Context.MODE_PRIVATE);
        String json = preferences.getString(PREF_VOLUME_TREE_URIS, new JSONObject().toString());
        if (json != null) {
            try {
                JSONObject jsonObject = new JSONObject(json);
                Iterator<String> iterator = jsonObject.keys();
                while (iterator.hasNext()) {
                    String k = iterator.next();
                    String v = (String) jsonObject.get(k);
                    map.put(k, v);
                }
            } catch (JSONException e) {
                Log.w(LOG_TAG, "failed to read volume tree URIs from preferences", e);
            }
        }
        return map;
    }

    public static Optional<String> getVolumeTreeUriForPath(Activity activity, String anyPath) {
        return StorageUtils.getVolumePath(activity, anyPath).map(volumePath -> getVolumeTreeUris(activity).get(volumePath));
    }

    /**
     * Document files
     */

    @Nullable
    public static DocumentFileCompat getDocumentFile(@NonNull Activity activity, @NonNull String anyPath, @NonNull Uri mediaUri) {
        if (requireAccessPermission(anyPath)) {
            // need a document URI (not a media content URI) to open a `DocumentFile` output stream
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // cleanest API to get it
                Uri docUri = MediaStore.getDocumentUri(activity, mediaUri);
                if (docUri != null) {
                    return DocumentFileCompat.fromSingleUri(activity, docUri);
                }
            }
            // fallback for older APIs
            Uri volumeTreeUri = PermissionManager.getVolumeTreeUri(activity, anyPath);
            Optional<DocumentFileCompat> docFile = getDocumentFileFromVolumeTree(activity, volumeTreeUri, anyPath);
            return docFile.orElse(null);
        }
        // good old `File`
        return DocumentFileCompat.fromFile(new File(anyPath));
    }

    // returns the directory `DocumentFile` (from tree URI when scoped storage is required, `File` otherwise)
    // returns null if directory does not exist and could not be created
    public static DocumentFileCompat createDirectoryIfAbsent(@NonNull Activity activity, @NonNull String directoryPath) {
        if (requireAccessPermission(directoryPath)) {
            Uri rootTreeUri = PermissionManager.getVolumeTreeUri(activity, directoryPath);
            DocumentFileCompat parentFile = DocumentFileCompat.fromTreeUri(activity, rootTreeUri);
            if (parentFile == null) return null;

            if (!directoryPath.endsWith(File.separator)) {
                directoryPath += File.separator;
            }
            Iterator<String> pathIterator = getPathStepIterator(activity, directoryPath);
            while (pathIterator != null && pathIterator.hasNext()) {
                String dirName = pathIterator.next();
                DocumentFileCompat dirFile = findDocumentFileIgnoreCase(parentFile, dirName);
                if (dirFile == null || !dirFile.exists()) {
                    try {
                        dirFile = parentFile.createDirectory(dirName);
                        if (dirFile == null) {
                            Log.e(LOG_TAG, "failed to create directory with name=" + dirName + " from parent=" + parentFile);
                            return null;
                        }
                    } catch (FileNotFoundException e) {
                        Log.e(LOG_TAG, "failed to create directory with name=" + dirName + " from parent=" + parentFile, e);
                        return null;
                    }
                }
                parentFile = dirFile;
            }
            return parentFile;
        } else {
            File directory = new File(directoryPath);
            if (!directory.exists()) {
                if (!directory.mkdirs()) {
                    Log.e(LOG_TAG, "failed to create directories at path=" + directoryPath);
                    return null;
                }
            }
            return DocumentFileCompat.fromFile(directory);
        }
    }

    public static String copyFileToTemp(@NonNull DocumentFileCompat documentFile, @NonNull String path) {
        String extension = MimeTypeMap.getFileExtensionFromUrl(Uri.fromFile(new File(path)).toString());
        try {
            File temp = File.createTempFile("aves", '.' + extension);
            documentFile.copyTo(DocumentFileCompat.fromFile(temp));
            temp.deleteOnExit();
            return temp.getPath();
        } catch (IOException e) {
            Log.w(LOG_TAG, "failed to copy file from path=" + path);
        }
        return null;
    }

    private static Optional<DocumentFileCompat> getDocumentFileFromVolumeTree(Context context, Uri rootTreeUri, String path) {
        if (rootTreeUri == null || path == null) {
            return Optional.empty();
        }

        DocumentFileCompat documentFile = DocumentFileCompat.fromTreeUri(context, rootTreeUri);
        if (documentFile == null) {
            return Optional.empty();
        }

        // follow the entry path down the document tree
        Iterator<String> pathIterator = getPathStepIterator(context, path);
        while (pathIterator != null && pathIterator.hasNext()) {
            documentFile = findDocumentFileIgnoreCase(documentFile, pathIterator.next());
            if (documentFile == null) {
                return Optional.empty();
            }
        }
        return Optional.of(documentFile);
    }

    // variation on `DocumentFileCompat.findFile()` to allow case insensitive search
    private static DocumentFileCompat findDocumentFileIgnoreCase(DocumentFileCompat documentFile, String displayName) {
        for (DocumentFileCompat doc : documentFile.listFiles()) {
            if (displayName.equalsIgnoreCase(doc.getName())) {
                return doc;
            }
        }
        return null;
    }

    /**
     * Misc
     */

    public static boolean requireAccessPermission(@NonNull String anyPath) {
        // on Android R, we should always require access permission, even on primary volume
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.Q) {
            return true;
        }
        boolean onPrimaryVolume = anyPath.startsWith(getPrimaryVolumePath());
        return !onPrimaryVolume;
    }

    private static boolean isMediaStoreContentUri(Uri uri) {
        // a URI's authority is [userinfo@]host[:port]
        // but we only want the host when comparing to Media Store's "authority"
        return uri != null && ContentResolver.SCHEME_CONTENT.equalsIgnoreCase(uri.getScheme()) && MediaStore.AUTHORITY.equalsIgnoreCase(uri.getHost());
    }

    public static InputStream openInputStream(Context context, Uri uri) throws FileNotFoundException {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // we get a permission denial if we require original from a provider other than the media store
            if (isMediaStoreContentUri(uri)) {
                uri = MediaStore.setRequireOriginal(uri);
            }
        }
        return context.getContentResolver().openInputStream(uri);
    }

    public static MediaMetadataRetriever openMetadataRetriever(Context context, Uri uri) {
        MediaMetadataRetriever retriever = new MediaMetadataRetriever();
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // we get a permission denial if we require original from a provider other than the media store
                if (isMediaStoreContentUri(uri)) {
                    uri = MediaStore.setRequireOriginal(uri);
                }
            }
            retriever.setDataSource(context, uri);
        } catch (Exception e) {
            Log.w(LOG_TAG, "failed to open MediaMetadataRetriever for uri=" + uri, e);
        }
        return retriever;
    }
}
