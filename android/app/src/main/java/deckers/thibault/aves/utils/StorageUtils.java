package deckers.thibault.aves.utils;

import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.Context;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.ParcelFileDescriptor;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.MimeTypeMap;

import androidx.documentfile.provider.DocumentFile;

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
    public static String[] getStorageVolumes(Context context) {
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

    private static Optional<DocumentFile> getSdCardDocumentFile(Context context, Uri sdCardTreeUri, String[] storageVolumes, String path) {
        if (sdCardTreeUri == null || storageVolumes == null || path == null) {
            return Optional.empty();
        }

        PathComponents pathComponents = new PathComponents(path, storageVolumes);
        ArrayList<String> pathSegments = Lists.newArrayList(Splitter.on(File.separatorChar)
                .trimResults().omitEmptyStrings().split(pathComponents.getFolder()));
        pathSegments.add(pathComponents.getFilename());
        Iterator<String> pathIterator = pathSegments.iterator();

        // follow the entry path down the document tree
        boolean found = true;
        DocumentFile documentFile = DocumentFile.fromTreeUri(context, sdCardTreeUri);
        while (pathIterator.hasNext() && found) {
            String segment = pathIterator.next();
            found = false;
            if (documentFile != null) {
                DocumentFile[] children = documentFile.listFiles();
                for (int i = children.length - 1; i >= 0 && !found; i--) {
                    DocumentFile child = children[i];
                    if (segment.equals(child.getName())) {
                        found = true;
                        documentFile = child;
                    }
                }
            }
        }

        return found && documentFile != null ? Optional.of(documentFile) : Optional.empty();
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

    public static boolean writeToDocumentFile(Context context, String from, Uri documentUri) {
        try {
            ParcelFileDescriptor pfd = context.getContentResolver().openFileDescriptor(documentUri, "rw");
            if (pfd == null) {
                Log.w(LOG_TAG, "failed to get file descriptor for documentUri=" + documentUri);
                return false;
            }
            Utils.copyFile(new File(from), pfd.getFileDescriptor());
            return true;
        } catch (IOException e) {
            Log.w(LOG_TAG, "failed to write to DocumentFile at documentUri=" + documentUri);
        }
        return false;
    }

    /**
     * Delete the specified file on SD card
     * Note that it does not update related content providers such as the Media Store.
     */
    public static boolean deleteFromSdCard(Context context, Uri sdCardTreeUri, String[] storageVolumes, String path) {
        Optional<DocumentFile> documentFile = getSdCardDocumentFile(context, sdCardTreeUri, storageVolumes, path);
        boolean success = documentFile.isPresent() && documentFile.get().delete();
        Log.d(LOG_TAG, "deleteFromSdCard success=" + success + " for sdCardTreeUri=" + sdCardTreeUri + ", path=" + path);
        return success;
    }

    /**
     * Rename the specified file on SD card
     * Note that it does not update related content providers such as the Media Store.
     */
    public static boolean renameOnSdCard(Context context, Uri sdCardTreeUri, String[] storageVolumes, String path, String newFilename) {
        Log.d(LOG_TAG, "renameOnSdCard with path=" + path + ", newFilename=" + newFilename);
        Optional<DocumentFile> documentFile = getSdCardDocumentFile(context, sdCardTreeUri, storageVolumes, path);
        return documentFile.isPresent() && documentFile.get().renameTo(newFilename);
    }
}
