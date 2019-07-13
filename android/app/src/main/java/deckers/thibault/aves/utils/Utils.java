package deckers.thibault.aves.utils;

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
}