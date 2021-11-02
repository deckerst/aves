import 'package:aves/app_flavor.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:aves/widgets/common/identity/buttons.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _hasAcceptedTerms = false;
  late Future<String> _termsLoader;

  static const double maxWidth = 460;

  @override
  void initState() {
    super.initState();
    settings.setContextualDefaults();
    _termsLoader = rootBundle.loadString('assets/terms.md');
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: FutureBuilder<String>(
              future: _termsLoader,
              builder: (context, snapshot) {
                if (snapshot.hasError || snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
                final terms = snapshot.data!;
                final durations = context.watch<DurationsData>();
                final isPortrait = context.select<MediaQueryData, Orientation>((mq) => mq.orientation) == Orientation.portrait;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _toStaggeredList(
                    duration: durations.staggeredAnimation,
                    delay: durations.staggeredAnimationDelay * timeDilation,
                    childAnimationBuilder: (child) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: child,
                      ),
                    ),
                    children: [
                      ..._buildHeader(context, isPortrait: isPortrait),
                      if (isPortrait) ...[
                        Flexible(child: _buildTerms(terms)),
                        const SizedBox(height: 16),
                        ..._buildControls(context),
                      ] else
                        Flexible(
                          child: Row(
                            children: [
                              Flexible(
                                  child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildTerms(terms),
                              )),
                              Flexible(
                                child: ListView(
                                  // shrinkWrap: true,
                                  children: _buildControls(context),
                                ),
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHeader(BuildContext context, {required bool isPortrait}) {
    final message = Text(
      context.l10n.welcomeMessage,
      style: Theme.of(context).textTheme.headline5,
    );
    final padding = isPortrait ? 16.0 : 8.0;
    return [
      SizedBox(height: padding),
      ...(isPortrait
          ? [
              const AvesLogo(size: 64),
              const SizedBox(height: 16),
              message,
            ]
          : [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AvesLogo(size: 48),
                  const SizedBox(width: 16),
                  message,
                ],
              )
            ]),
      SizedBox(height: padding),
    ];
  }

  List<Widget> _buildControls(BuildContext context) {
    final l10n = context.l10n;
    final canEnableErrorReporting = context.select<AppFlavor, bool>((v) => v.canEnableErrorReporting);
    const contentPadding = EdgeInsets.symmetric(horizontal: 8);
    final switches = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            value: settings.isInstalledAppAccessAllowed,
            onChanged: (v) => setState(() => settings.isInstalledAppAccessAllowed = v),
            title: Text(l10n.settingsAllowInstalledAppAccess),
            subtitle: Text([l10n.welcomeOptional, l10n.settingsAllowInstalledAppAccessSubtitle].join(' • ')),
            contentPadding: contentPadding,
          ),
          if (canEnableErrorReporting)
            SwitchListTile(
              value: settings.isErrorReportingAllowed,
              onChanged: (v) => setState(() => settings.isErrorReportingAllowed = v),
              title: Text(l10n.settingsAllowErrorReporting),
              subtitle: Text(l10n.welcomeOptional),
              contentPadding: contentPadding,
            ),
          SwitchListTile(
            // key is expected by test driver
            key: const Key('agree-checkbox'),
            value: _hasAcceptedTerms,
            onChanged: (v) => setState(() => _hasAcceptedTerms = v),
            title: Text(l10n.welcomeTermsToggle),
            contentPadding: contentPadding,
          ),
        ],
      ),
    );

    final button = AvesOutlinedButton(
      // key is expected by test driver
      key: const Key('continue-button'),
      label: context.l10n.continueButtonLabel,
      onPressed: _hasAcceptedTerms
          ? () {
              settings.hasAcceptedTerms = true;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: HomePage.routeName),
                  builder: (context) => const HomePage(),
                ),
              );
            }
          : null,
    );

    return [
      switches,
      Center(child: button),
      const SizedBox(height: 8),
    ];
  }

  Widget _buildTerms(String terms) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        color: Colors.white10,
      ),
      constraints: const BoxConstraints(maxWidth: maxWidth),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: const ScrollbarThemeData(
              isAlwaysShown: true,
              radius: Radius.circular(16),
              crossAxisMargin: 6,
              mainAxisMargin: 16,
              interactive: true,
            ),
          ),
          child: Scrollbar(
            child: Markdown(
              data: terms,
              selectable: true,
              onTapLink: (text, href, title) async {
                if (href != null && await canLaunch(href)) {
                  await launch(href);
                }
              },
              shrinkWrap: true,
            ),
          ),
        ),
      ),
    );
  }

  // as of flutter_staggered_animations v0.1.2, `AnimationConfiguration.toStaggeredList` does not handle `Flexible` widgets
  // so we use this workaround instead
  static List<Widget> _toStaggeredList({
    required Duration duration,
    required Duration delay,
    required Widget Function(Widget) childAnimationBuilder,
    required List<Widget> children,
  }) =>
      children
          .asMap()
          .map((index, widget) {
            var child = widget is Flexible ? widget.child : widget;
            child = AnimationConfiguration.staggeredList(
              position: index,
              duration: duration,
              delay: delay,
              child: childAnimationBuilder(child),
            );
            child = widget is Flexible ? Flexible(child: child) : child;
            return MapEntry(
              index,
              child,
            );
          })
          .values
          .toList();
}
