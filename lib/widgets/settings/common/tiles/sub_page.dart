import 'package:aves/widgets/common/basic/list_tiles/common.dart';
import 'package:material_ui/material_ui.dart';

class const SettingsSubPageTile({
  super.key,
  required final TitleBuilder title,
  final WidgetBuilder? subtitle,
  required final String routeName,
  required final WidgetBuilder builder,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title(context) ?? '?'),
      subtitle: subtitle?.call(context),
      onTap: () {
        Navigator.maybeOf(context)?.push(
          MaterialPageRoute(
            settings: RouteSettings(name: routeName),
            builder: builder,
          ),
        );
      },
    );
  }
}
