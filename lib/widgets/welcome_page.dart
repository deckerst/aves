import 'package:aves/app_flavor.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/about/policy_page.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:aves/widgets/common/basic/markdown_container.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _hasAcceptedTerms = false;
  late Future<String> _termsLoader;

  static const termsPath = 'assets/terms.md';
  static const termsDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    _termsLoader = rootBundle.loadString(termsPath);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initWelcomeSettings());
  }

  void _initWelcomeSettings() {
    // this should be done outside of `initState`/`build`
    settings.setContextualDefaults(context.read<AppFlavor>());
    // explicitly set consent values to current defaults
    // so they are not subject to future default changes
    settings.isInstalledAppAccessAllowed = SettingsDefaults.isInstalledAppAccessAllowed;
    settings.isErrorReportingAllowed = SettingsDefaults.isErrorReportingAllowed;
  }

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      body: SafeArea(
        child: Center(
          child: FutureBuilder<String>(
            future: _termsLoader,
            builder: (context, snapshot) {
              if (snapshot.hasError || snapshot.connectionState != ConnectionState.done) return const SizedBox();
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
                  children: settings.useTvLayout
                      ? [
                          ..._buildHeader(context, isPortrait: isPortrait),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: LinkChip(
                              leading: const Icon(
                                AIcons.privacy,
                                size: 22,
                              ),
                              text: context.l10n.aboutLinkPolicy,
                              textStyle: Theme.of(context).textTheme.titleLarge,
                              onTap: _goToPolicyPage,
                            ),
                          ),
                          ..._buildControls(context),
                        ]
                      : [
                          ..._buildHeader(context, isPortrait: isPortrait),
                          if (isPortrait) ...[
                            Flexible(
                              child: MarkdownContainer(
                                data: terms,
                                textDirection: termsDirection,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._buildControls(context),
                          ] else
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: MarkdownContainer(
                                        data: terms,
                                        textDirection: termsDirection,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: _buildControls(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHeader(BuildContext context, {required bool isPortrait}) {
    final message = Text(
      context.l10n.welcomeMessage,
      style: Theme.of(context).textTheme.headlineSmall,
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
      constraints: const BoxConstraints(maxWidth: MarkdownContainer.mobileMaxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            key: const Key('apps-checkbox'),
            value: settings.isInstalledAppAccessAllowed,
            onChanged: (v) => setState(() => settings.isInstalledAppAccessAllowed = v),
            title: Text(l10n.settingsAllowInstalledAppAccess),
            subtitle: Text([l10n.welcomeOptional, l10n.settingsAllowInstalledAppAccessSubtitle].join(Constants.separator)),
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
            key: const Key('terms-checkbox'),
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

  void _goToPolicyPage() {
    Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: PolicyPage.routeName),
        builder: (context) => const PolicyPage(),
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
