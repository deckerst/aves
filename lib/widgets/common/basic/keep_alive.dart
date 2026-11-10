import 'package:material_ui/material_ui.dart';

// because `KeepAlive` does not do what it should
class const AKeepAlive({super.key, required final Widget child}) extends StatefulWidget {
  @override
  State<AKeepAlive> createState() => _AKeepAliveState();
}

class _AKeepAliveState extends State<AKeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
