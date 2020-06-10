import 'package:aves/main.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/model/terms.dart';
import 'package:aves/widgets/common/aves_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage();

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _hasAcceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).accentColor;
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AvesLogo(size: 64),
              const SizedBox(height: 16),
              const Text(
                'Welcome to Aves',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Concourse',
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white10,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      child: MarkdownBody(
                        data: termsAndConditions,
                        onTapLink: (url) async {
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        },
                      ), // const Text('Terms terms terms'),
                    ),
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Checkbox(
                        value: _hasAcceptedTerms,
                        onChanged: (v) => setState(() => _hasAcceptedTerms = v),
                        activeColor: accentColor,
                      ),
                    ),
                    const TextSpan(
                      text: 'I accept the Terms of Service',
                    ),
                  ],
                ),
              ),
              RaisedButton(
                color: accentColor,
                child: const Text('Continue'),
                onPressed: _hasAcceptedTerms
                    ? () {
                        settings.hasAcceptedTerms = true;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                          (route) => false,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
