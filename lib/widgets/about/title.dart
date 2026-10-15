import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:material_ui/material_ui.dart';

class const AboutSectionTitle({
  super.key,
  required final String text,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      alignment: .centerStart,
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      child: Text(text, style: AStyles.sectionTitleStyle(context.knownLocale)),
    );

    if (settings.useTvLayout) {
      child = InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(123)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: .min,
            children: [
              child,
            ],
          ),
        ),
      );
    }
    return child;
  }
}
