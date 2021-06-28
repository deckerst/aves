import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class DebugFirebaseSection extends StatelessWidget {
  const DebugFirebaseSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvesExpansionTile(
      title: 'Firebase',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            onPressed: FirebaseCrashlytics.instance.crash,
            child: const Text('Crash'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: InfoRowGroup(
            info: {
              'Firebase data collection enabled': '${Firebase.app().isAutomaticDataCollectionEnabled}',
              'Crashlytics collection enabled': '${FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled}',
            },
          ),
        )
      ],
    );
  }
}
