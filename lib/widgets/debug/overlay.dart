import 'package:aves/services/common/service_policy.dart';
import 'package:flutter/material.dart';

class DebugTaskQueueOverlay extends StatelessWidget {
  const DebugTaskQueueOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DefaultTextStyle(
        style: const TextStyle(),
        child: Align(
          alignment: AlignmentDirectional.bottomStart,
          child: SafeArea(
            child: Container(
              color: Colors.indigo.shade900.withAlpha(0xCC),
              padding: const EdgeInsets.all(8),
              child: StreamBuilder<QueueState>(
                  stream: servicePolicy.queueStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const SizedBox.shrink();
                    final queuedEntries = <MapEntry<dynamic, int>>[];
                    if (snapshot.hasData) {
                      final state = snapshot.data!;
                      queuedEntries.add(MapEntry('run', state.runningCount));
                      queuedEntries.add(MapEntry('paused', state.pausedCount));
                      queuedEntries.addAll(state.queueByPriority.entries.map((kv) => MapEntry(kv.key.toString(), kv.value)));
                    }
                    queuedEntries.sort((a, b) => a.key.compareTo(b.key));
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(queuedEntries.map((kv) => '${kv.key}: ${kv.value}').join(', ')),
                      ],
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
