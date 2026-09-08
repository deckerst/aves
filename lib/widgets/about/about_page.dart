import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/about/about_mobile_page.dart';
import 'package:aves/widgets/about/about_tv_page.dart';
import 'package:material_ui/material_ui.dart';

class AboutPage extends StatelessWidget {
  static const routeName = '/about';

  const new({super.key});

  @override
  Widget build(BuildContext context) {
    if (settings.useTvLayout) {
      return const AboutTvPage();
    } else {
      return const AboutMobilePage();
    }
  }
}
