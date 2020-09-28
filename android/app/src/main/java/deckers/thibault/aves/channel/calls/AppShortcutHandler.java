package deckers.thibault.aves.channel.calls;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.pm.ShortcutInfoCompat;
import androidx.core.content.pm.ShortcutManagerCompat;
import androidx.core.graphics.drawable.IconCompat;

import com.bumptech.glide.load.engine.bitmap_recycle.LruBitmapPool;
import com.bumptech.glide.load.resource.bitmap.TransformationUtils;

import java.util.List;

import deckers.thibault.aves.MainActivity;
import deckers.thibault.aves.R;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AppShortcutHandler implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "deckers.thibault/aves/shortcut";

    private Context context;

    public AppShortcutHandler(Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "canPin": {
                result.success(ShortcutManagerCompat.isRequestPinShortcutSupported(context));
                break;
            }
            case "pin": {
                String label = call.argument("label");
                byte[] iconBytes = call.argument("iconBytes");
                List<String> filters = call.argument("filters");
                new Thread(() -> pin(label, iconBytes, filters)).start();
                result.success(null);
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    private void pin(String label, byte[] iconBytes, @Nullable List<String> filters) {
        if (!ShortcutManagerCompat.isRequestPinShortcutSupported(context) || filters == null) {
            return;
        }

        IconCompat icon;
        if (iconBytes != null && iconBytes.length > 0) {
            Bitmap bitmap = BitmapFactory.decodeByteArray(iconBytes, 0, iconBytes.length);
            bitmap = TransformationUtils.centerCrop(new LruBitmapPool(2 << 24), bitmap, 256, 256);
            icon = IconCompat.createWithBitmap(bitmap);
        } else {
            icon = IconCompat.createWithResource(context, R.mipmap.ic_shortcut_collection);
        }

        Intent intent = new Intent(Intent.ACTION_MAIN, null, context, MainActivity.class)
                .putExtra("page", "/collection")
                .putExtra("filters", filters.toArray(new String[0]));

        ShortcutInfoCompat shortcut = new ShortcutInfoCompat.Builder(context, "collection-" + TextUtils.join("-", filters))
                .setShortLabel(label)
                .setIcon(icon)
                .setIntent(intent)
                .build();

        ShortcutManagerCompat.requestPinShortcut(context, shortcut, null);
    }
}
