import 'package:aves/services/android_debug_service.dart';
import 'package:aves/services/services.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class DebugFirebaseSection extends StatelessWidget {
  const DebugFirebaseSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvesExpansionTile(
      title: 'Reporting',
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            onPressed: AndroidDebugService.crash,
            child: Text('Crash'),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            onPressed: AndroidDebugService.exception,
            child: Text('Throw exception'),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            onPressed: AndroidDebugService.safeException,
            child: Text('Throw exception (safe)'),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            onPressed: AndroidDebugService.exceptionInCoroutine,
            child: Text('Throw exception in coroutine'),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            onPressed: AndroidDebugService.safeExceptionInCoroutine,
            child: Text('Throw exception in coroutine (safe)'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: InfoRowGroup(
            info: {
              'Firebase data collection enabled': '${Firebase.app().isAutomaticDataCollectionEnabled}',
              'Crashlytics collection enabled': '${reportService.isCollectionEnabled}',
            },
          ),
        )
      ],
    );
  }
}
