import 'package:aves/services/android_debug_service.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class DebugAndroidCodecSection extends StatefulWidget {
  const DebugAndroidCodecSection({Key? key}) : super(key: key);

  @override
  _DebugAndroidCodecSectionState createState() => _DebugAndroidCodecSectionState();
}

class _DebugAndroidCodecSectionState extends State<DebugAndroidCodecSection> with AutomaticKeepAliveClientMixin {
  late Future<List<Map>> _loader;

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
              Widget _toCodecColumn(List<Map<String, String>> codecs) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: codecs
                        .expand((v) => [
                              InfoRowGroup(info: Map.fromEntries(v.entries.where((kv) => kv.key != 'isEncoder'))),
                              const Divider(),
                            ])
                        .toList(),
                  );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
