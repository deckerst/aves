package deckers.thibault.aves.utils;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Optional;
import java.util.Set;

public class StorageUtils {
    private static final String LOG_TAG = Utils.createLogTag(StorageUtils.class);

    private static boolean isMediaStoreContentUri(Uri uri) {
        // a URI's authority is [userinfo@]host[:port]
        // but we only want the host when comparing to Media Store's "authority"
        return uri != null && ContentResolver.SCHEME_CONTENT.equalsIgnoreCase(uri.getScheme()) && MediaStore.AUTHORITY.equalsIgnoreCase(uri.getHost());
    }

    public static InputStream openInputStream(Context context, Uri uri, String path) throws FileNotFoundException {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // we get a permission denial if we require original from a provider other than the media store
            if (isMediaStoreContentUri(uri)) {
                uri = MediaStore.setRequireOriginal(uri);
            }
            return context.getContentResolver().openInputStream(uri);
        }

        // on Android <Q, we directly work with file paths if possible,
        // as `FileInputStream` is faster than input stream from `ContentResolver`
        return path != null ? new FileInputStream(path) : context.getContentResolver().openInputStream(uri);
    }

    public static MediaMetadataRetriever openMetadataRetriever(Context context, Uri uri, String path) {
        MediaMetadataRetriever retriever = new MediaMetadataRetriever();

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // we get a permission denial if we require original from a provider other than the media store
                if (isMediaStoreContentUri(uri)) {
                    uri = MediaStore.setRequireOriginal(uri);
                }
                retriever.setDataSource(context, uri);
                return retriever;
            }

            // on Android <Q, we directly work with file paths if possible
            if (path != null) {
                retriever.setDataSource(path);
            } else {
                retriever.setDataSource(context, uri);
            }
        } catch (IllegalArgumentException e) {
            Log.w(LOG_TAG, "failed to open MediaMetadataRetriever for uri=" + uri + ", path=" + path);
        }
        return retriever;
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
    public static String[] getStorageVolumeRoots(Context context) {
        // Final set of paths
        final Set<String> rv = new HashSet<>();

        // Primary emulated SD-CARD
        final String rawEmulatedStorageTarget = System.getenv("EMULATED_STORAGE_TARGET");

        if (TextUtils.isEmpty(rawEmulatedStorageTarget)) {
            // fix of empty raw emulated storage on marshmallow
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                File[] files = context.getExternalFilesDirs(null);
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
            if (path.endsWith(File.separator)) {
                paths[i] = path.substring(0, path.length() - 1);
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

    private static Optional<DocumentFileCompat> getSdCardDocumentFile(Context context, Uri rootTreeUri, String[] storageVolumeRoots, String path) {
        if (rootTreeUri == null || storageVolumeRoots == null || path == null) {
            return Optional.empty();
        }

        DocumentFileCompat documentFile = DocumentFileCompat.fromTreeUri(context, rootTreeUri);
        if (documentFile == null) {
            return Optional.empty();
        }

        // follow the entry path down the document tree
        Iterator<String> pathIterator = getPathStepIterator(storageVolumeRoots, path);
        while (pathIterator.hasNext()) {
            documentFile = documentFile.findFile(pathIterator.next());
            if (documentFile == null) {
                return Optional.empty();
            }
        }
        return Optional.of(documentFile);
    }

    private static Iterator<String> getPathStepIterator(String[] storageVolumeRoots, String path) {
        PathSegments pathSegments = new PathSegments(path, storageVolumeRoots);
        ArrayList<String> pathSteps = Lists.newArrayList(Splitter.on(File.separatorChar)
                .trimResults().omitEmptyStrings().split(pathSegments.getRelativePath()));
        String filename = pathSegments.getFilename();
        if (filename != null && filename.length() > 0) {
            pathSteps.add(filename);
        }
        return pathSteps.iterator();
    }


    @Nullable
    public static DocumentFileCompat getDocumentFile(@NonNull Activity activity, @NonNull String path, @NonNull Uri mediaUri) {
        if (Env.requireAccessPermission(path)) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Uri docUri = MediaStore.getDocumentUri(activity, mediaUri);
                return DocumentFileCompat.fromSingleUri(activity, docUri);
            } else {
                Uri sdCardTreeUri = PermissionManager.getSdCardTreeUri(activity);
                String[] storageVolumeRoots = Env.getStorageVolumeRoots(activity);
                Optional<DocumentFileCompat> docFile = StorageUtils.getSdCardDocumentFile(activity, sdCardTreeUri, storageVolumeRoots, path);
                return docFile.orElse(null);
            }
        } else {
            return DocumentFileCompat.fromFile(new File(path));
        }
    }

    public static boolean createDirectoryIfAbsent(@NonNull Activity activity, @NonNull String directoryPath) {
        if (Env.requireAccessPermission(directoryPath)) {
            Uri rootTreeUri = PermissionManager.getSdCardTreeUri(activity);
            DocumentFileCompat parentFile = DocumentFileCompat.fromTreeUri(activity, rootTreeUri);
            if (parentFile == null) return false;

            String[] storageVolumeRoots = Env.getStorageVolumeRoots(activity);
            if (!directoryPath.endsWith(File.separator)) {
                directoryPath += File.separator;
            }
            Iterator<String> pathIterator = getPathStepIterator(storageVolumeRoots, directoryPath);
            while (pathIterator.hasNext()) {
                String dirName = pathIterator.next();
                DocumentFileCompat dirFile = parentFile.findFile(dirName);
                if (dirFile == null || !dirFile.exists()) {
                    try {
                        dirFile = parentFile.createDirectory(dirName);
                        if (dirFile != null) {
                            parentFile = dirFile;
                        }
                    } catch (FileNotFoundException e) {
                        Log.e(LOG_TAG, "failed to create directory with name=" + dirName + " from parent=" + parentFile, e);
                        return false;
                    }
                }
            }
            return true;
        } else {
            File directory = new File(directoryPath);
            if (directory.exists()) return true;
            return directory.mkdirs();
        }
    }

    public static String copyFileToTemp(String path) {
        try {
            String extension = MimeTypeMap.getFileExtensionFromUrl(Uri.fromFile(new File(path)).toString());
            File temp = File.createTempFile("aves", '.' + extension);
            Utils.copyFile(new File(path), temp);
            temp.deleteOnExit();
            return temp.getPath();
        } catch (IOException e) {
            Log.w(LOG_TAG, "failed to copy file at path=" + path);
        }
        return null;
    }
}
