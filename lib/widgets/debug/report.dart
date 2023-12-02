import 'package:aves/services/android_debug_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';

class DebugErrorReportingSection extends StatefulWidget {
  const DebugErrorReportingSection({super.key});

  @override
  State<DebugErrorReportingSection> createState() => _DebugErrorReportingSectionState();
}

class _DebugErrorReportingSectionState extends State<DebugErrorReportingSection> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

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
            info: reportService.state,
          ),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
