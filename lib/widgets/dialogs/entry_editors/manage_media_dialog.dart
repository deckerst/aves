import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:material_ui/material_ui.dart';

class ManageMediaDialog extends StatefulWidget {
  static const routeName = '/dialog/manage_media';

  const new({super.key});

  @override
  State<ManageMediaDialog> createState() => _ManageMediaDialogState();
}

class _ManageMediaDialogState extends State<ManageMediaDialog> with WidgetsBindingObserver {
  late Future<bool> _loader;
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _initLoader();
    WidgetsBinding.instance.addObserver(this);
    _validate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isValidNotifier.dispose();
    super.dispose();
  }

  void _initLoader() => _loader = deviceService.isMediaManagementGranted();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == .resumed) {
      _initLoader();
      setState(() {});
      _validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      horizontalContentPadding: 4,
      content: FutureBuilder<bool>(
        future: _loader,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState != ConnectionState.done;
          final current = snapshot.data ?? false;

          final onChanged = loading ? null : (v) => deviceService.requestMediaManagementPermission();
          return SwitchListTile(
            value: current,
            onChanged: onChanged,
            title: Text(context.l10n.settingsAllowMediaManagement),
          );
        },
      ),
      actions: [
        const CancelButton(),
        ValueListenableBuilder<bool>(
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return TextButton(
              onPressed: isValid ? () => _submit(context) : null,
              child: Text(context.l10n.applyButtonLabel),
            );
          },
        ),
      ],
    );
  }

  Future<void> _validate() async {
    _isValidNotifier.value = await _loader;
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.maybeOf(context)?.pop<bool>(true);
    }
  }
}
