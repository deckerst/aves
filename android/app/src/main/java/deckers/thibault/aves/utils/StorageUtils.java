package deckers.thibault.aves.utils;

import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.Context;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.storage.StorageManager;
import android.os.storage.StorageVolume;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.MimeTypeMap;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.commonsware.cwac.document.DocumentFileCompat;
import com.google.common.base.Splitter;
import com.google.common.collect.Lists;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class StorageUtils {
    private static final String LOG_TAG = Utils.createLogTag(StorageUtils.class);

    /**
     * Volume paths
     */

    // volume paths, with trailing "/"
    private static String[] mStorageVolumePaths;

    // primary volume path, with trailing "/"
    private static String mPrimaryVolumePath;

    public static String getPrimaryVolumePath() {
        if (mPrimaryVolumePath == null) {
            mPrimaryVolumePath = findPrimaryVolumePath();
        }
        return mPrimaryVolumePath;
    }

    public static String[] getVolumePaths(@NonNull Context context) {
        if (mStorageVolumePaths == null) {
            mStorageVolumePaths = findVolumePaths(context);
        }
        return mStorageVolumePaths;
    }

    public static Optional<String> getVolumePath(@NonNull Context context, @NonNull String anyPath) {
        return Arrays.stream(getVolumePaths(context)).filter(anyPath::startsWith).findFirst();
    }

    @Nullable
    private static Iterator<String> getPathStepIterator(@NonNull Context context, @NonNull String anyPath, @Nullable String root) {
        if (root == null) {
            root = getVolumePath(context, anyPath).orElse(null);
            if (root == null) return null;
        }

        String relativePath = null, filename = null;
        int lastSeparatorIndex = anyPath.lastIndexOf(File.separator) + 1;
        int rootLength = root.length();
        if (lastSeparatorIndex > rootLength) {
            filename = anyPath.substring(lastSeparatorIndex);
            relativePath = anyPath.substring(rootLength, lastSeparatorIndex);
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
                } while (!validFiles);
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

    private static Optional<String> getVolumeUuidForTreeUri(@NonNull Context context, @NonNull String anyPath) {
        StorageManager sm = context.getSystemService(StorageManager.class);
        if (sm != null) {
            StorageVolume volume = sm.getStorageVolume(new File(anyPath));
            if (volume != null) {
                if (volume.isPrimary()) {
                    return Optional.of("primary");
                }
                String uuid = volume.getUuid();
                if (uuid != null) {
                    return Optional.of(uuid.toUpperCase());
                }
            }
        }
        Log.e(LOG_TAG, "failed to find volume UUID for anyPath=" + anyPath);
        return Optional.empty();
    }

    private static Optional<String> getVolumePathFromTreeUriUuid(@NonNull Context context, @NonNull String uuid) {
        if (uuid.equals("primary")) {
            return Optional.of(getPrimaryVolumePath());
        }
        StorageManager sm = context.getSystemService(StorageManager.class);
        if (sm != null) {
            for (String volumePath : StorageUtils.getVolumePaths(context)) {
                try {
                    StorageVolume volume = sm.getStorageVolume(new File(volumePath));
                    if (volume != null && uuid.equalsIgnoreCase(volume.getUuid())) {
                        return Optional.of(volumePath);
                    }
                } catch (IllegalArgumentException e) {
                    // ignore
                }
            }
        }
        Log.e(LOG_TAG, "failed to find volume path for UUID=" + uuid);
        return Optional.empty();
    }

    // e.g.
    // /storage/emulated/0/         -> content://com.android.externalstorage.documents/tree/primary%3A
    // /storage/10F9-3F13/Pictures/ -> content://com.android.externalstorage.documents/tree/10F9-3F13%3APictures
    static Optional<Uri> convertDirPathToTreeUri(@NonNull Context context, @NonNull String dirPath) {
        Optional<String> uuid = getVolumeUuidForTreeUri(context, dirPath);
        if (uuid.isPresent()) {
            String relativeDir = new PathSegments(context, dirPath).relativeDir;
            if (relativeDir == null) {
                relativeDir = "";
            } else if (relativeDir.endsWith(File.separator)) {
                relativeDir = relativeDir.substring(0, relativeDir.length() - 1);
            }
            Uri treeUri = DocumentsContract.buildTreeDocumentUri("com.android.externalstorage.documents", uuid.get() + ":" + relativeDir);
            return Optional.of(treeUri);
        }
        Log.e(LOG_TAG, "failed to convert dirPath=" + dirPath + " to tree URI");
        return Optional.empty();
    }

    // e.g.
    // content://com.android.externalstorage.documents/tree/primary%3A              -> /storage/emulated/0/
    // content://com.android.externalstorage.documents/tree/10F9-3F13%3APictures    -> /storage/10F9-3F13/Pictures/
    static Optional<String> convertTreeUriToDirPath(@NonNull Context context, @NonNull Uri treeUri) {
        String encoded = treeUri.toString().substring("content://com.android.externalstorage.documents/tree/".length());
        Matcher matcher = Pattern.compile("(.*?):(.*)").matcher(Uri.decode(encoded));
        if (matcher.find()) {
            String uuid = matcher.group(1);
            String relativePath = matcher.group(2);
            if (uuid != null && relativePath != null) {
                Optional<String> volumePath = getVolumePathFromTreeUriUuid(context, uuid);
                if (volumePath.isPresent()) {
                    String dirPath = volumePath.get() + relativePath;
                    if (!dirPath.endsWith(File.separator)) {
                        dirPath += File.separator;
                    }
                    return Optional.of(dirPath);
                }
            }
        }
        Log.e(LOG_TAG, "failed to convert treeUri=" + treeUri + " to path");
        return Optional.empty();
    }

    /**
     * Document files
     */

    @Nullable
    public static DocumentFileCompat getDocumentFile(@NonNull Context context, @NonNull String anyPath, @NonNull Uri mediaUri) {
        if (requireAccessPermission(anyPath)) {
            // need a document URI (not a media content URI) to open a `DocumentFile` output stream
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // cleanest API to get it
                Uri docUri = MediaStore.getDocumentUri(context, mediaUri);
                if (docUri != null) {
                    return DocumentFileCompat.fromSingleUri(context, docUri);
                }
            }
            // fallback for older APIs
            return getVolumePath(context, anyPath)
                    .flatMap(volumePath -> convertDirPathToTreeUri(context, volumePath)
                            .flatMap(treeUri -> getDocumentFileFromVolumeTree(context, treeUri, anyPath)))
                    .orElse(null);

        }
        // good old `File`
        return DocumentFileCompat.fromFile(new File(anyPath));
    }

    // returns the directory `DocumentFile` (from tree URI when scoped storage is required, `File` otherwise)
    // returns null if directory does not exist and could not be created
    public static DocumentFileCompat createDirectoryIfAbsent(@NonNull Context context, @NonNull String dirPath) {
        if (!dirPath.endsWith(File.separator)) {
            dirPath += File.separator;
        }
        if (requireAccessPermission(dirPath)) {
            String grantedDir = PermissionManager.getGrantedDirForPath(context, dirPath);
            if (grantedDir == null) return null;

            Uri rootTreeUri = convertDirPathToTreeUri(context, grantedDir).orElse(null);
            if (rootTreeUri == null) return null;

            DocumentFileCompat parentFile = DocumentFileCompat.fromTreeUri(context, rootTreeUri);
            if (parentFile == null) return null;

            Iterator<String> pathIterator = getPathStepIterator(context, dirPath, grantedDir);
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
            File directory = new File(dirPath);
            if (!directory.exists()) {
                if (!directory.mkdirs()) {
                    Log.e(LOG_TAG, "failed to create directories at path=" + dirPath);
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
            Log.e(LOG_TAG, "failed to copy file from path=" + path);
        }
        return null;
    }

    private static Optional<DocumentFileCompat> getDocumentFileFromVolumeTree(Context context, @NonNull Uri rootTreeUri, @NonNull String anyPath) {
        DocumentFileCompat documentFile = DocumentFileCompat.fromTreeUri(context, rootTreeUri);
        if (documentFile == null) {
            return Optional.empty();
        }

        // follow the entry path down the document tree
        Iterator<String> pathIterator = getPathStepIterator(context, anyPath, null);
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

    public static InputStream openInputStream(@NonNull Context context, @NonNull Uri uri) throws FileNotFoundException {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // we get a permission denial if we require original from a provider other than the media store
            if (isMediaStoreContentUri(uri)) {
                uri = MediaStore.setRequireOriginal(uri);
            }
        }
        return context.getContentResolver().openInputStream(uri);
    }

    public static MediaMetadataRetriever openMetadataRetriever(@NonNull Context context, @NonNull Uri uri) {
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
            // unsupported format
            return null;
        }
        return retriever;
    }

    public static class PathSegments {
        String fullPath; // should match "volumePath + relativeDir + filename"
        String volumePath; // with trailing "/"
        String relativeDir; // with trailing "/"
        String filename; // null for directories

        PathSegments(@NonNull Context context, @NonNull String fullPath) {
            this.fullPath = fullPath;
            volumePath = StorageUtils.getVolumePath(context, fullPath).orElse(null);
            if (volumePath == null) return;

            int lastSeparatorIndex = fullPath.lastIndexOf(File.separator) + 1;
            int volumePathLength = volumePath.length();
            if (lastSeparatorIndex > volumePathLength) {
                filename = fullPath.substring(lastSeparatorIndex);
                relativeDir = fullPath.substring(volumePathLength, lastSeparatorIndex);
            }
        }
    }
}
