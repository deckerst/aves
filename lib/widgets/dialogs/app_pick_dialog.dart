import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/basic/query_bar.dart';
import 'package:aves/widgets/common/basic/reselectable_radio_list_tile.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AppPickDialog extends StatefulWidget {
  static const routeName = '/app_pick';

  final String? initialValue;

  const AppPickDialog({
    Key? key,
    required this.initialValue,
  }) : super(key: key);

  @override
  State<AppPickDialog> createState() => _AppPickDialogState();
}

class _AppPickDialogState extends State<AppPickDialog> {
  late String? _selectedValue;
  late Future<Set<Package>> _loader;
  final ValueNotifier<String> _queryNotifier = ValueNotifier('');

  static const double iconSize = 32;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _loader = androidAppService.getPackages();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.appPickDialogTitle),
        ),
        body: SafeArea(
          child: FutureBuilder<Set<Package>>(
            future: _loader,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final allPackages = snapshot.data;
              if (allPackages == null) return const SizedBox();
              final packages = allPackages.where((package) => package.categoryLauncher).toList()..sort((a, b) => compareAsciiUpperCase(_displayName(a), _displayName(b)));
              return Column(
                children: [
                  QueryBar(queryNotifier: _queryNotifier),
                  ValueListenableBuilder<String>(
                    valueListenable: _queryNotifier,
                    builder: (context, query, child) {
                      final visiblePackages = packages.where((package) {
                        return {
                          package.packageName,
                          package.currentLabel,
                          package.englishLabel,
                          ...package.potentialDirs,
                        }.any((v) => v != null && v.toLowerCase().contains(query.toLowerCase()));
                      }).toList();
                      final showNoneOption = query.isEmpty;
                      final itemCount = visiblePackages.length + (showNoneOption ? 1 : 0);
                      return Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            if (showNoneOption) {
                              if (index == 0) {
                                return ReselectableRadioListTile<String?>(
                                  value: '',
                                  groupValue: _selectedValue,
                                  onChanged: (v) => Navigator.pop(context, v),
                                  reselectable: true,
                                  title: Text(
                                    context.l10n.appPickDialogNone,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                  ),
                                );
                              }
                              index--;
                            }

                            final package = visiblePackages[index];
                            return ReselectableRadioListTile<String?>(
                              value: package.packageName,
                              groupValue: _selectedValue,
                              onChanged: (v) => Navigator.pop(context, v),
                              reselectable: true,
                              title: Text.rich(
                                TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.only(end: 16),
                                        child: Image(
                                          image: AppIconImage(
                                            packageName: package.packageName,
                                            size: iconSize,
                                          ),
                                          width: iconSize,
                                          height: iconSize,
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                      text: _displayName(package),
                                    ),
                                  ],
                                ),
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                              ),
                            );
                          },
                          itemCount: itemCount,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _displayName(Package package) => package.currentLabel ?? package.packageName;
}
