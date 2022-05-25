import 'package:aves/services/android_debug_service.dart';
import 'package:aves/widgets/common/basic/query_bar.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class DebugAndroidCodecSection extends StatefulWidget {
  const DebugAndroidCodecSection({super.key});

  @override
  State<DebugAndroidCodecSection> createState() => _DebugAndroidCodecSectionState();
}

class _DebugAndroidCodecSectionState extends State<DebugAndroidCodecSection> with AutomaticKeepAliveClientMixin {
  late Future<List<Map>> _loader;
  final ValueNotifier<String> _queryNotifier = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    _loader = AndroidDebugService.getCodecs();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AvesExpansionTile(
      title: 'Android Codecs',
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: FutureBuilder<List<Map>>(
            future: _loader,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
              final codecs = snapshot.data!.map((codec) {
                return codec.map((k, v) => MapEntry(k.toString(), v.toString()));
              }).toList()
                ..sort((a, b) => compareAsciiUpperCase(a['supportedTypes'] ?? '', b['supportedTypes'] ?? ''));
              final byEncoder = groupBy<Map<String, String>, bool>(codecs, (v) => v['isEncoder'] == 'true');
              final decoders = byEncoder[false] ?? [];
              final encoders = byEncoder[true] ?? [];
              Widget _toCodecColumn(List<Map<String, String>> codecs) => ValueListenableBuilder<String>(
                    valueListenable: _queryNotifier,
                    builder: (context, query, child) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: codecs.expand((v) {
                        final types = v['supportedTypes'];
                        return (query.isEmpty || types == null || types.contains(query))
                            ? [
                                InfoRowGroup(info: Map.fromEntries(v.entries.where((kv) => kv.key != 'isEncoder'))),
                                const Divider(),
                              ]
                            : <Widget>[];
                      }).toList(),
                    ),
                  );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QueryBar(queryNotifier: _queryNotifier),
                  const HighlightTitle(title: 'Decoders'),
                  _toCodecColumn(decoders),
                  const HighlightTitle(title: 'Encoders'),
                  _toCodecColumn(encoders),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
