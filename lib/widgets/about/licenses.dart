import 'package:aves/utils/brand_colors.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/aves_expansion_tile.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/link_chip.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class Licenses extends StatefulWidget {
  @override
  _LicensesState createState() => _LicensesState();
}

class _LicensesState extends State<Licenses> {
  final ValueNotifier<String> _expandedNotifier = ValueNotifier(null);
  LicenseSort _sort = LicenseSort.name;
  List<Dependency> _platform, _flutter;

  @override
  void initState() {
    super.initState();
    _platform = List.from(Constants.androidDependencies);
    _flutter = List.from(Constants.flutterPackages);
    _sortPackages();
  }

  void _sortPackages() {
    int compare(Dependency a, Dependency b) {
      switch (_sort) {
        case LicenseSort.license:
          final c = compareAsciiUpperCase(a.license, b.license);
          return c != 0 ? c : compareAsciiUpperCase(a.name, b.name);
        case LicenseSort.name:
        default:
          return compareAsciiUpperCase(a.name, b.name);
      }
    }

    _platform.sort(compare);
    _flutter.sort(compare);
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            _buildHeader(),
            SizedBox(height: 16),
            AvesExpansionTile(
              title: 'Android Libraries',
              color: BrandColors.android,
              expandedNotifier: _expandedNotifier,
              children: _platform.map((package) => LicenseRow(package)).toList(),
            ),
            AvesExpansionTile(
              title: 'Flutter Packages',
              color: BrandColors.flutter,
              expandedNotifier: _expandedNotifier,
              children: _flutter.map((package) => LicenseRow(package)).toList(),
            ),
            Center(
              child: TextButton(
                onPressed: () => showLicensePage(context: context),
                child: Text('All Licenses'.toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 8),
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
                icon: Icon(AIcons.sort),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Padding(
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
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinkChip(
            text: package.name,
            url: package.sourceUrl,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 16),
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
