import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/apps.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/basic/query_bar.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class DebugAndroidAppSection extends StatefulWidget {
  const DebugAndroidAppSection({super.key});

  @override
  State<DebugAndroidAppSection> createState() => _DebugAndroidAppSectionState();
}

class _DebugAndroidAppSectionState extends State<DebugAndroidAppSection> with AutomaticKeepAliveClientMixin {
  late Future<Set<Package>> _loader;
  final ValueNotifier<String> _queryNotifier = ValueNotifier('');

  static const iconSize = 20.0;

  @override
  void initState() {
    super.initState();
    _loader = appService.getPackages();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AvesExpansionTile(
      title: 'Android Apps',
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: FutureBuilder<Set<Package>>(
            future: _loader,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
              final packages = snapshot.data!.toList()..sort((a, b) => compareAsciiUpperCase(a.packageName, b.packageName));
              final enabledTheme = IconTheme.of(context);
              final disabledTheme = enabledTheme.merge(const IconThemeData(opacity: .2));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QueryBar(queryNotifier: _queryNotifier),
                  ...packages.map((package) {
                    return ValueListenableBuilder<String>(
                      valueListenable: _queryNotifier,
                      builder: (context, query, child) {
                        if ({package.packageName, ...package.potentialDirs}.none((v) => v.toLowerCase().contains(query.toLowerCase()))) {
                          return const SizedBox();
                        }
                        return Text.rich(
                          TextSpan(
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Image(
                                  image: AppIconImage(
                                    packageName: package.packageName,
                                    size: iconSize,
                                  ),
                                  width: iconSize,
                                  height: iconSize,
                                ),
                              ),
                              TextSpan(
                                text: ' ${package.packageName}\n',
                                style: InfoRowGroup.keyStyle(context),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: IconTheme(
                                  data: package.categoryLauncher ? enabledTheme : disabledTheme,
                                  child: const Icon(
                                    Icons.launch_outlined,
                                    size: iconSize,
                                  ),
                                ),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: IconTheme(
                                  data: package.isSystem ? enabledTheme : disabledTheme,
                                  child: const Icon(
                                    Icons.android,
                                    size: iconSize,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: ' ${package.potentialDirs.join(', ')}\n',
                                style: InfoRowGroup.valueStyle,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  })
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
