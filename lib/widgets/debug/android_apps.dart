import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class DebugAndroidAppSection extends StatefulWidget {
  @override
  _DebugAndroidAppSectionState createState() => _DebugAndroidAppSectionState();
}

class _DebugAndroidAppSectionState extends State<DebugAndroidAppSection> with AutomaticKeepAliveClientMixin {
  Future<Map> _loader;

  static const iconSize = 20.0;

  @override
  void initState() {
    super.initState();
    _loader = AndroidAppService.getAppNames();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AvesExpansionTile(
      title: 'Android Apps',
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: FutureBuilder<Map>(
            future: _loader,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
              final entries = snapshot.data.entries.toList()..sort((kv1, kv2) => compareAsciiUpperCase(kv1.value, kv2.value));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entries.map((kv) {
                  final appName = kv.key.toString();
                  final packageName = kv.value.toString();
                  return Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Image(
                            image: AppIconImage(
                              packageName: packageName,
                              size: iconSize,
                            ),
                            width: iconSize,
                            height: iconSize,
                          ),
                        ),
                        TextSpan(
                          text: ' $packageName',
                          style: InfoRowGroup.keyStyle,
                        ),
                        TextSpan(
                          text: ' $appName',
                          style: InfoRowGroup.baseStyle,
                        ),
                      ],
                    ),
                  );
                }).toList(),
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
