import 'package:aves/utils/constants.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/link_chip.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class Licenses extends StatefulWidget {
  @override
  _LicensesState createState() => _LicensesState();
}

class _LicensesState extends State<Licenses> {
  LicenseSort _sort = LicenseSort.name;
  List<Dependency> _packages;

  @override
  void initState() {
    super.initState();
    _packages = [...Constants.androidDependencies, ...Constants.flutterPackages];
    _sortPackages();
  }

  void _sortPackages() {
    _packages.sort((a, b) {
      switch (_sort) {
        case LicenseSort.license:
          final c = compareAsciiUpperCase(a.license, b.license);
          return c != 0 ? c : compareAsciiUpperCase(a.name, b.name);
        case LicenseSort.name:
        default:
          return compareAsciiUpperCase(a.name, b.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index-- == 0) {
              return _buildHeader();
            }
            final child = LicenseRow(_packages[index]);
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: Durations.staggeredAnimation,
              delay: Durations.staggeredAnimationDelay,
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: child,
                ),
              ),
            );
          },
          childCount: _packages.length + 1,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Open-Source Licenses',
                  style: Theme.of(context).textTheme.headline6.copyWith(fontFamily: 'Concourse Caps'),
                ),
              ),
              PopupMenuButton<LicenseSort>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: LicenseSort.name,
                    child: MenuRow(text: 'Sort by name', checked: _sort == LicenseSort.name),
                  ),
                  PopupMenuItem(
                    value: LicenseSort.license,
                    child: MenuRow(text: 'Sort by license', checked: _sort == LicenseSort.license),
                  ),
                ],
                onSelected: (newSort) {
                  _sort = newSort;
                  _sortPackages();
                  setState(() {});
                },
                tooltip: 'Sort',
                icon: const Icon(AIcons.sort),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('The following sets forth attribution notices for third party software that may be contained in this application.'),
        ),
      ],
    );
  }
}

class LicenseRow extends StatelessWidget {
  final Dependency package;

  const LicenseRow(this.package);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bodyTextStyle = textTheme.bodyText2;
    final subColor = bodyTextStyle.color.withOpacity(.6);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinkChip(
            text: package.name,
            url: package.sourceUrl,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: LinkChip(
              text: package.license,
              url: package.licenseUrl,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }
}

enum LicenseSort { license, name }
