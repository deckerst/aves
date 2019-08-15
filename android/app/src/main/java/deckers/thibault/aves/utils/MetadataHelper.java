package deckers.thibault.aves.utils;

import android.media.ExifInterface;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MetadataHelper {

    // interpret EXIF code to angle (0, 90, 180 or 270 degrees)
    public static int getOrientationDegreesForExifCode(int exifOrientation) {
        switch (exifOrientation) {
            case ExifInterface.ORIENTATION_ROTATE_180: // bottom, right side
                return 180;
            case ExifInterface.ORIENTATION_ROTATE_90: // right side, top
                return 90;
            case ExifInterface.ORIENTATION_ROTATE_270: // left side, bottom
                return 270;
        }
        // all other orientations (regular, flipped...) default to an angle of 0 degree
        return 0;
    }

    // yyyyMMddTHHmmss(.sss)?(Z|+/-hhmm)?
    public static long parseVideoMetadataDate(String dateString) {
        // optional sub-second
        String subSecond = null;
        Matcher subSecondMatcher = Pattern.compile("(\\d{6})(\\.\\d+)").matcher(dateString);
        if (subSecondMatcher.find()) {
            subSecond = subSecondMatcher.group(2).substring(1);
            dateString = subSecondMatcher.replaceAll("$1");
        }

        // optional time zone
        TimeZone timeZone = null;
        Matcher timeZoneMatcher = Pattern.compile("(Z|[+-]\\d{4})$").matcher(dateString);
        if (timeZoneMatcher.find()) {
            timeZone = TimeZone.getTimeZone("GMT" + timeZoneMatcher.group().replaceAll("Z", ""));
            dateString = timeZoneMatcher.replaceAll("");
        }

        Date date = null;
        try {
            DateFormat parser = new SimpleDateFormat("yyyyMMdd'T'HHmmss", Locale.US);
            parser.setTimeZone((timeZone != null) ? timeZone : TimeZone.getTimeZone("GMT"));
            date = parser.parse(dateString);
        } catch (ParseException ex) {
            // ignore
        }

        if (date == null) {
            return 0;
        }

        long dateMillis = date.getTime();
        if (subSecond != null) {
            try {
                int millis = (int) (Double.parseDouble("." + subSecond) * 1000);
                if (millis >= 0 && millis < 1000) {
                    dateMillis += millis;
                }
            } catch (NumberFormatException e) {
                // ignore
            }
        }
        return dateMillis;
    }
}
