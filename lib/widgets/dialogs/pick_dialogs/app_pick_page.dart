import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/app_inventory.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/basic/list_tiles/reselectable_radio.dart';
import 'package:aves/widgets/common/basic/query_bar.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AppPickPage extends StatefulWidget {
  static const routeName = '/app_pick';

  final String? initialValue;

  const AppPickPage({
    super.key,
    required this.initialValue,
  });

  @override
  State<AppPickPage> createState() => _AppPickPageState();
}

class _AppPickPageState extends State<AppPickPage> {
  late String? _selectedValue;
  late Future<Set<Package>> _loader;
  final ValueNotifier<String> _queryNotifier = ValueNotifier('');

  static const double iconSize = 32;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _loader = appService.getPackages();
  }

  @override
  void dispose() {
    _queryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useTvLayout = settings.useTvLayout;
    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !useTvLayout,
        title: Text(context.l10n.appPickDialogTitle),
      ),
      body: SafeArea(
        bottom: false,
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
                if (!useTvLayout) QueryBar(queryNotifier: _queryNotifier),
                ValueListenableBuilder<String>(
                  valueListenable: _queryNotifier,
                  builder: (context, query, child) {
                    final upQuery = query.toUpperCase().trim();
                    final visiblePackages = packages.where((package) {
                      return {
                        package.packageName,
                        package.currentLabel,
                        package.englishLabel,
                        ...package.potentialDirs,
                      }.any((v) => v != null && v.toUpperCase().contains(upQuery));
                    }).toList();
                    final showNoneOption = upQuery.isEmpty;
                    final itemCount = visiblePackages.length + (showNoneOption ? 1 : 0);
                    return Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          if (showNoneOption) {
                            if (index == 0) {
                              return ReselectableRadioListTile<String?>(
                                value: '',
                                groupValue: _selectedValue,
                                onChanged: (v) => Navigator.maybeOf(context)?.pop(v),
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
                            onChanged: (v) => Navigator.maybeOf(context)?.pop(v),
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
    );
  }

  String _displayName(Package package) => package.currentLabel ?? package.packageName;
}
