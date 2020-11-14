import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/aves_logo.dart';
import 'package:aves/widgets/common/labeled_checkbox.dart';
import 'package:aves/widgets/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage();

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _hasAcceptedTerms = false;
  Future<String> _termsLoader;

  @override
  void initState() {
    super.initState();
    _termsLoader = rootBundle.loadString('assets/terms.md');
    if (!kReleaseMode) {
      settings.isCrashlyticsEnabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(16.0),
          child: FutureBuilder<String>(
              future: _termsLoader,
              builder: (context, snapshot) {
                if (snapshot.hasError || snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
                final terms = snapshot.data;
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
                      SizedBox(height: 16),
                      ..._buildBottomControls(context),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  List<Widget> _buildTop(BuildContext context) {
    const message = Text(
      'Welcome to Aves',
      style: TextStyle(
        fontSize: 22,
        fontFamily: 'Concourse',
      ),
    );
    return [
      ...(MediaQuery.of(context).orientation == Orientation.portrait
          ? [
              AvesLogo(size: 64),
              SizedBox(height: 16),
              message,
            ]
          : [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvesLogo(size: 48),
                  SizedBox(width: 16),
                  message,
                ],
              )
            ]),
      SizedBox(height: 16),
    ];
  }

  List<Widget> _buildBottomControls(BuildContext context) {
    final checkboxes = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledCheckbox(
          value: settings.isCrashlyticsEnabled,
          onChanged: (v) => setState(() => settings.isCrashlyticsEnabled = v),
          text: 'Allow anonymous analytics and crash reporting',
        ),
        LabeledCheckbox(
          key: Key('agree-checkbox'),
          value: _hasAcceptedTerms,
          onChanged: (v) => setState(() => _hasAcceptedTerms = v),
          text: 'I agree to the terms and conditions',
        ),
      ],
    );

    final button = ElevatedButton(
      key: Key('continue-button'),
      child: Text('Continue'),
      onPressed: _hasAcceptedTerms
          ? () {
              settings.hasAcceptedTerms = true;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: HomePage.routeName),
                  builder: (context) => HomePage(),
                ),
              );
            }
          : null,
    );

    return MediaQuery.of(context).orientation == Orientation.portrait
        ? [
            checkboxes,
            button,
          ]
        : [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                checkboxes,
                Spacer(),
                button,
              ],
            ),
          ];
  }

  Widget _buildTerms(String terms) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white10,
      ),
      constraints: BoxConstraints(maxWidth: 460),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Markdown(
          data: terms,
          selectable: true,
          onTapLink: (text, href, title) async {
            if (await canLaunch(href)) {
              await launch(href);
            }
          },
          shrinkWrap: true,
        ),
      ),
    );
  }

  // as of flutter_staggered_animations v0.1.2, `AnimationConfiguration.toStaggeredList` does not handle `Flexible` widgets
  // so we use this workaround instead
  static List<Widget> _toStaggeredList({
    Duration duration,
    Duration delay,
    @required Widget Function(Widget) childAnimationBuilder,
    @required List<Widget> children,
  }) =>
      children
          .asMap()
          .map((index, widget) {
            var child = widget is Flexible ? widget.child : widget;
            child = AnimationConfiguration.staggeredList(
              position: index,
              duration: duration,
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
