import 'dart:developer' show Flow, Timeline;

import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/intents.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Flow;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// as of Flutter v3.7.7, `LicensePage` is not designed for Android TV
// and gets rejected from Google Play review:
// ```
// Your app’s text is cut off at the edge of the screen.
// Apps should not display any text or functionality that is partially cut off by the edges of the screen.
// For example, your app (version code 94) in the "Show All Licenses" section text is cut off from the bottom of the screen.
// ```
class TvLicensePage extends StatefulWidget {
  const TvLicensePage({super.key});

  @override
  State<TvLicensePage> createState() => _TvLicensePageState();
}

class _TvLicensePageState extends State<TvLicensePage> {
  final FocusNode _railFocusNode = FocusNode();
  final ScrollController _detailsScrollController = ScrollController();
  final ValueNotifier<int> _railIndexNotifier = ValueNotifier(0);

  static const double railWidth = 256;

  final Future<_LicenseData> licenses = LicenseRegistry.licenses
      .fold<_LicenseData>(
        _LicenseData(),
        (prev, license) => prev..addLicense(license),
      )
      .then((licenseData) => licenseData..sortPackages());

  @override
  void dispose() {
    _railIndexNotifier.dispose();
    _railFocusNode.dispose();
    _detailsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(MaterialLocalizations.of(context).licensesPageTitle),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _railIndexNotifier,
        builder: (context, selectedIndex, child) {
          return FutureBuilder<_LicenseData>(
            future: licenses,
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final packages = data.packages;
              final rail = Focus(
                focusNode: _railFocusNode,
                skipTraversal: true,
                canRequestFocus: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints.loose(const Size.fromWidth(railWidth)),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      final packageName = packages[index];
                      final bindings = data.packageLicenseBindings[packageName]!;
                      final isSelected = index == selectedIndex;
                      final theme = Theme.of(context);
                      return Ink(
                        color: isSelected ? theme.highlightColor : Themes.firstLayerColor(context),
                        child: ListTile(
                          title: Text(packageName),
                          subtitle: Text(MaterialLocalizations.of(context).licensesPackageDetailText(bindings.length)),
                          selected: isSelected,
                          onTap: () => _railIndexNotifier.value = index,
                        ),
                      );
                    },
                    itemCount: packages.length,
                  ),
                ),
              );

              final packageName = packages[selectedIndex];
              final bindings = data.packageLicenseBindings[packageName]!;

              return SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),
                    rail,
                    Expanded(
                      child: FocusableActionDetector(
                        shortcuts: const {
                          SingleActivator(LogicalKeyboardKey.arrowUp): ScrollIntent(direction: AxisDirection.up, type: ScrollIncrementType.page),
                          SingleActivator(LogicalKeyboardKey.arrowDown): ScrollIntent(direction: AxisDirection.down, type: ScrollIncrementType.page),
                        },
                        actions: {
                          ScrollIntent: ScrollControllerAction(scrollController: _detailsScrollController),
                        },
                        child: KeyedSubtree(
                          key: Key(packageName),
                          child: _PackageLicensePage(
                            packageName: packageName,
                            licenseEntries: bindings.map((i) => data.licenses[i]).toList(growable: false),
                            scrollController: _detailsScrollController,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// adapted from Flutter `_LicenseData` in `/material/about.dart`
class _LicenseData {
  final List<LicenseEntry> licenses = <LicenseEntry>[];
  final Map<String, List<int>> packageLicenseBindings = <String, List<int>>{};
  final List<String> packages = <String>[];

  // Special treatment for the first package since it should be the package
  // for delivered application.
  String? firstPackage;

  void addLicense(LicenseEntry entry) {
    // Before the license can be added, we must first record the packages to
    // which it belongs.
    for (final String package in entry.packages) {
      _addPackage(package);
      // Bind this license to the package using the next index value. This
      // creates a contract that this license must be inserted at this same
      // index value.
      packageLicenseBindings[package]!.add(licenses.length);
    }
    licenses.add(entry); // Completion of the contract above.
  }

  /// Add a package and initialize package license binding. This is a no-op if
  /// the package has been seen before.
  void _addPackage(String package) {
    if (!packageLicenseBindings.containsKey(package)) {
      packageLicenseBindings[package] = <int>[];
      firstPackage ??= package;
      packages.add(package);
    }
  }

  /// Sort the packages using some comparison method, or by the default manner,
  /// which is to put the application package first, followed by every other
  /// package in case-insensitive alphabetical order.
  void sortPackages([int Function(String a, String b)? compare]) {
    packages.sort(compare ??
        (a, b) {
          // Based on how LicenseRegistry currently behaves, the first package
          // returned is the end user application license. This should be
          // presented first in the list. So here we make sure that first package
          // remains at the front regardless of alphabetical sorting.
          if (a == firstPackage) {
            return -1;
          }
          if (b == firstPackage) {
            return 1;
          }
          return a.toLowerCase().compareTo(b.toLowerCase());
        });
  }
}

// adapted from Flutter `_PackageLicensePage` in `/material/about.dart`
class _PackageLicensePage extends StatefulWidget {
  const _PackageLicensePage({
    required this.packageName,
    required this.licenseEntries,
    required this.scrollController,
  });

  final String packageName;
  final List<LicenseEntry> licenseEntries;
  final ScrollController? scrollController;

  @override
  _PackageLicensePageState createState() => _PackageLicensePageState();
}

class _PackageLicensePageState extends State<_PackageLicensePage> {
  @override
  void initState() {
    super.initState();
    _initLicenses();
  }

  final List<Widget> _licenses = <Widget>[];
  bool _loaded = false;

  Future<void> _initLicenses() async {
    int debugFlowId = -1;
    assert(() {
      final Flow flow = Flow.begin();
      Timeline.timeSync('_initLicenses()', () {}, flow: flow);
      debugFlowId = flow.id;
      return true;
    }());
    for (final LicenseEntry license in widget.licenseEntries) {
      if (!mounted) return;
      assert(() {
        Timeline.timeSync('_initLicenses()', () {}, flow: Flow.step(debugFlowId));
        return true;
      }());
      final List<LicenseParagraph> paragraphs = await SchedulerBinding.instance.scheduleTask<List<LicenseParagraph>>(
        license.paragraphs.toList,
        Priority.animation,
        debugLabel: 'License',
      );
      if (!mounted) return;
      setState(() {
        _licenses.add(const Padding(
          padding: EdgeInsets.all(18.0),
          child: Divider(),
        ));
        for (final LicenseParagraph paragraph in paragraphs) {
          if (paragraph.indent == LicenseParagraph.centeredIndent) {
            _licenses.add(Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                paragraph.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ));
          } else {
            assert(paragraph.indent >= 0);
            _licenses.add(Padding(
              padding: EdgeInsetsDirectional.only(top: 8.0, start: 16.0 * paragraph.indent),
              child: Text(paragraph.text),
            ));
          }
        }
      });
    }
    setState(() {
      _loaded = true;
    });
    assert(() {
      Timeline.timeSync('Build scheduled', () {}, flow: Flow.end(debugFlowId));
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final String title = widget.packageName;
    final String subtitle = localizations.licensesPackageDetailText(widget.licenseEntries.length);
    final double pad = _getGutterSize(context);
    final EdgeInsets padding = EdgeInsets.only(left: pad, right: pad, bottom: pad);
    final List<Widget> listWidgets = <Widget>[
      ..._licenses,
      if (!_loaded)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
    ];

    final Widget page;
    if (widget.scrollController == null) {
      page = Scaffold(
        appBar: AppBar(
          title: _PackageLicensePageTitle(
            title: title,
            subtitle: subtitle,
            theme: theme.useMaterial3 ? theme.textTheme : theme.primaryTextTheme,
            titleTextStyle: theme.appBarTheme.titleTextStyle,
            foregroundColor: theme.appBarTheme.foregroundColor,
          ),
        ),
        body: Center(
          child: Material(
            color: Themes.firstLayerColor(context),
            elevation: 4.0,
            child: Container(
              constraints: BoxConstraints.loose(const Size.fromWidth(600.0)),
              child: Localizations.override(
                locale: const Locale('en', 'US'),
                context: context,
                child: ScrollConfiguration(
                  // A Scrollbar is built-in below.
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: Scrollbar(
                    child: ListView(
                      primary: true,
                      padding: padding,
                      children: listWidgets,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      page = CustomScrollView(
        controller: widget.scrollController,
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            backgroundColor: Themes.firstLayerColor(context),
            title: _PackageLicensePageTitle(
              title: title,
              subtitle: subtitle,
              theme: theme.textTheme,
              titleTextStyle: theme.textTheme.titleLarge,
            ),
          ),
          SliverPadding(
            padding: padding,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Localizations.override(
                  locale: const Locale('en', 'US'),
                  context: context,
                  child: listWidgets[index],
                ),
                childCount: listWidgets.length,
              ),
            ),
          ),
        ],
      );
    }
    return DefaultTextStyle(
      style: theme.textTheme.bodySmall!,
      child: page,
    );
  }
}

class _PackageLicensePageTitle extends StatelessWidget {
  const _PackageLicensePageTitle({
    required this.title,
    required this.subtitle,
    required this.theme,
    this.titleTextStyle,
    this.foregroundColor,
  });

  final String title;
  final String subtitle;
  final TextTheme theme;
  final TextStyle? titleTextStyle;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final TextStyle? effectiveTitleTextStyle = titleTextStyle ?? theme.titleLarge;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: effectiveTitleTextStyle?.copyWith(color: foregroundColor)),
        Text(subtitle, style: theme.titleSmall?.copyWith(color: foregroundColor)),
      ],
    );
  }
}

const int _materialGutterThreshold = 720;
const double _wideGutterSize = 24.0;
const double _narrowGutterSize = 12.0;

double _getGutterSize(BuildContext context) => MediaQuery.sizeOf(context).width >= _materialGutterThreshold ? _wideGutterSize : _narrowGutterSize;
