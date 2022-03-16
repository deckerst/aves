import 'package:aves/app_mode.dart';
import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OwnerProp extends StatefulWidget {
  final AvesEntry entry;

  const OwnerProp({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  State<OwnerProp> createState() => _OwnerPropState();
}

class _OwnerPropState extends State<OwnerProp> {
  Future<String?> _ownerPackageLoader = SynchronousFuture(null);
  Future<void> _appNameLoader = SynchronousFuture(null);

  AvesEntry get entry => widget.entry;

  static const ownerPackageNamePropKey = 'owner_package_name';
  static const iconSize = 20.0;

  @override
  void initState() {
    super.initState();
    final isMediaContent = entry.uri.startsWith('content://media/external/');
    if (isMediaContent) {
      _ownerPackageLoader = metadataFetchService.hasContentResolverProp(ownerPackageNamePropKey).then((exists) {
        return exists ? metadataFetchService.getContentResolverProp(entry, ownerPackageNamePropKey) : SynchronousFuture(null);
      });
      final isViewerMode = context.read<ValueNotifier<AppMode>>().value == AppMode.view;
      if (isViewerMode && settings.isInstalledAppAccessAllowed) {
        _appNameLoader = androidFileUtils.initAppNames();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _ownerPackageLoader,
      builder: (context, snapshot) {
        final ownerPackage = snapshot.data;
        if (ownerPackage == null) return const SizedBox();

        return FutureBuilder<void>(
          future: _appNameLoader,
          builder: (context, snapshot) {
            final appName = androidFileUtils.getCurrentAppName(ownerPackage) ?? ownerPackage;
            return SelectableText.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: context.l10n.viewerInfoLabelOwner,
                    style: InfoRowGroup.keyStyle(context),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Image(
                        image: AppIconImage(
                          packageName: ownerPackage,
                          size: iconSize,
                        ),
                        width: iconSize,
                        height: iconSize,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: appName,
                    style: InfoRowGroup.valueStyle,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
