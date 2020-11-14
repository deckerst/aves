import 'package:aves/services/service_policy.dart';
import 'package:flutter/material.dart';

class DebugTaskQueueOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DefaultTextStyle(
        style: TextStyle(),
        child: Align(
          alignment: AlignmentDirectional.bottomStart,
          child: SafeArea(
            child: Container(
              color: Colors.indigo[900].withAlpha(0xCC),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              padding: EdgeInsets.all(8),
              child: StreamBuilder<QueueState>(
                  stream: servicePolicy.queueStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return SizedBox.shrink();
                    final queuedEntries = (snapshot.hasData ? snapshot.data.queueByPriority.entries.toList() : []);
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
