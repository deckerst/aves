package deckers.thibault.aves.utils;

import java.io.File;
import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.util.regex.Pattern;

public class Utils {
    private static final int logTagMaxLength = 23;
    private static final Pattern logTagPackagePattern = Pattern.compile("(\\w)(\\w*)\\.");

    public static String createLogTag(Class<?> clazz) {
        // shorten class name to "a.b.CccDdd"
        String logTag = logTagPackagePattern.matcher(clazz.getName()).replaceAll("$1.");
        if (logTag.length() > logTagMaxLength) {
            // shorten class name to "a.b.CD"
            String simpleName = clazz.getSimpleName();
            String shortSimpleName = simpleName.replaceAll("[a-z]", "");
            logTag = logTag.replace(simpleName, shortSimpleName);
            if (logTag.length() > logTagMaxLength) {
                // shorten class name to "CD"
                logTag = shortSimpleName;
            }
        }
        return logTag;
    }

    public static void copyFile(final File source, final FileDescriptor descriptor) throws IOException {
        try (FileInputStream inStream = new FileInputStream(source); FileOutputStream outStream = new FileOutputStream(descriptor)) {
            final FileChannel inChannel = inStream.getChannel();
            final FileChannel outChannel = outStream.getChannel();
            final long size = inChannel.size();
            long position = 0;
            while (position < size) {
                position += inChannel.transferTo(position, 1024L * 1024L, outChannel);
            }
        }
    }

    public static void copyFile(final File source, final File destination) throws IOException {
        try (FileInputStream inStream = new FileInputStream(source); FileOutputStream outStream = new FileOutputStream(destination)) {
            final FileChannel inChannel = inStream.getChannel();
            final FileChannel outChannel = outStream.getChannel();
            final long size = inChannel.size();
            long position = 0;
            while (position < size) {
                position += inChannel.transferTo(position, 1024L * 1024L, outChannel);
            }
        }
    }
}