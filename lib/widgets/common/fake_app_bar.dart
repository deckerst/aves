import 'package:flutter/widgets.dart';

class FakeAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SizedBox.shrink());
  }

  @override
  Size get preferredSize => Size.zero;
}
