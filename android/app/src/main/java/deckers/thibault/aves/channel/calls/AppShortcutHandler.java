package deckers.thibault.aves.channel.calls;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.pm.ShortcutInfoCompat;
import androidx.core.content.pm.ShortcutManagerCompat;
import androidx.core.graphics.drawable.IconCompat;

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
                List<String> filters = call.argument("filters");
                pin(label, filters);
                result.success(null);
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    private void pin(String label, @Nullable List<String> filters) {
        if (!ShortcutManagerCompat.isRequestPinShortcutSupported(context) || filters == null) {
            return;
        }

        ShortcutInfoCompat shortcut = new ShortcutInfoCompat.Builder(context, "collection-" + TextUtils.join("-", filters))
                .setShortLabel(label)
                .setIcon(IconCompat.createWithResource(context, R.mipmap.ic_shortcut_collection))
                .setIntent(new Intent(Intent.ACTION_MAIN, null, context, MainActivity.class)
                        .putExtra("page", "/collection")
                        .putExtra("filters", filters.toArray(new String[0])))
                .build();

        ShortcutManagerCompat.requestPinShortcut(context, shortcut, null);
    }
}
