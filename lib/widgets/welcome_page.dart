import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/labeled_checkbox.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<String>(
              future: _termsLoader,
              builder: (context, snapshot) {
                if (snapshot.hasError || snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
                final terms = snapshot.data!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _toStaggeredList(
                    duration: Durations.staggeredAnimation,
                    delay: Durations.staggeredAnimationDelay,
                    childAnimationBuilder: (child) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: child,
                      ),
                    ),
                    children: [
                      ..._buildTop(context),
                      Flexible(child: _buildTerms(terms)),
                      const SizedBox(height: 16),
                      ..._buildBottomControls(context),
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

  List<Widget> _buildTop(BuildContext context) {
    final message = Text(
      context.l10n.welcomeMessage,
      style: Theme.of(context).textTheme.headline5,
    );
    return [
      ...(context.select<MediaQueryData, Orientation>((mq) => mq.orientation) == Orientation.portrait
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
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildBottomControls(BuildContext context) {
    final checkboxes = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledCheckbox(
          value: settings.isCrashlyticsEnabled,
          onChanged: (v) {
            if (v != null) setState(() => settings.isCrashlyticsEnabled = v);
          },
          text: context.l10n.welcomeCrashReportToggle,
        ),
        LabeledCheckbox(
          key: const Key('agree-checkbox'),
          value: _hasAcceptedTerms,
          onChanged: (v) {
            if (v != null) setState(() => _hasAcceptedTerms = v);
          },
          text: context.l10n.welcomeTermsToggle,
        ),
      ],
    );

    final button = ElevatedButton(
      key: const Key('continue-button'),
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
      child: Text(context.l10n.continueButtonLabel),
    );

    return context.select<MediaQueryData, Orientation>((mq) => mq.orientation) == Orientation.portrait
        ? [
            checkboxes,
            button,
          ]
        : [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                checkboxes,
                const Spacer(),
                button,
              ],
            ),
          ];
  }

  Widget _buildTerms(String terms) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        color: Colors.white10,
      ),
      constraints: const BoxConstraints(maxWidth: 460),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: const ScrollbarThemeData(
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
