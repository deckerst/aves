import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class DebugFirebaseSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AvesExpansionTile(
      title: 'Firebase',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: FirebaseCrashlytics.instance.crash,
                child: const Text('Crash'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => FirebaseAnalytics().logEvent(
                  name: 'debug_test',
                  parameters: {'time': DateTime.now().toIso8601String()},
                ),
                child: const Text('Send event'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: InfoRowGroup({
            'Firebase data collection enabled': '${Firebase.app().isAutomaticDataCollectionEnabled}',
            'Crashlytics collection enabled': '${FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled}',
          }),
        )
      ],
    );
  }
}
