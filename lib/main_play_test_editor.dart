import 'package:aves/app_flavor.dart';
import 'package:aves/main_common.dart';
import 'package:aves/model/app/intent.dart';

// https://developer.android.com/studio/command-line/adb.html#IntentSpec
// adb shell am start -n deckers.thibault.aves.debug/deckers.thibault.aves.MainActivity -a android.intent.action.EDIT -d content://media/external/images/media/183128 -t image/*

@pragma('vm:entry-point')
void main() => mainCommon(
      AppFlavor.play,
      debugIntentData: {
        IntentDataKeys.action: IntentActions.edit,
        IntentDataKeys.mimeType: 'image/*',
        IntentDataKeys.uri: 'content://media/external/images/media/183128',
        // IntentDataKeys.uri: 'content://media/external/images/media/183534',
      },
    );
