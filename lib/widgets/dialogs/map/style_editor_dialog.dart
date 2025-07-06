import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';

class MapStyleEditorDialog extends StatefulWidget {
  static const routeName = '/dialog/map_style_editor';

  final EntryMapStyle? initialValue;

  const MapStyleEditorDialog({
    super.key,
    this.initialValue,
  });

  @override
  State<MapStyleEditorDialog> createState() => _MapStyleEditorDialogState();
}

class _MapStyleEditorDialogState extends State<MapStyleEditorDialog> {
  late final Set<EntryMapStyle> _otherCustomStyles;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _subdomainsController = TextEditingController();
  final TextEditingController _userAgentController = TextEditingController();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    _otherCustomStyles = settings.customMapStyles.where((v) => v != initialValue).toSet();
    _nameController.text = initialValue?.name ?? '';
    _urlController.text = initialValue?.url ?? '';
    _subdomainsController.text = initialValue?.subdomains.join(',') ?? '';
    _userAgentController.text = initialValue?.userAgent ?? '';
    _validate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _subdomainsController.dispose();
    _userAgentController.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AvesDialog(
      scrollableContent: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.mapStyleEditorDialogName,
            ),
            autofocus: true,
            onChanged: (_) => _validate(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: l10n.mapStyleEditorDialogUrl,
            ),
            keyboardType: TextInputType.url,
            onChanged: (_) => _validate(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: TextField(
            controller: _subdomainsController,
            decoration: InputDecoration(
              labelText: l10n.mapStyleEditorDialogSubdomains,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: TextField(
            controller: _userAgentController,
            decoration: InputDecoration(
              labelText: l10n.mapStyleEditorDialogUserAgent,
            ),
          ),
        ),
      ],
      actions: [
        const CancelButton(),
        ValueListenableBuilder<bool>(
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return TextButton(
              onPressed: isValid ? () => _submit(context) : null,
              child: Text(widget.initialValue != null ? l10n.applyButtonLabel : l10n.createButtonLabel),
            );
          },
        )
      ],
    );
  }

  EntryMapStyle _buildStyle() {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    final subdomains = _subdomainsController.text.split(',').map((v) => v.trim()).toList();
    final userAgent = _userAgentController.text.trim();
    return EntryMapStyle(
      key: 'custom_$name',
      name: name,
      url: url,
      subdomains: subdomains,
      userAgent: userAgent.isNotEmpty ? userAgent : null,
    );
  }

  Future<void> _validate() async {
    final style = _buildStyle();

    final name = style.name ?? '';
    final url = style.url ?? '';
    if (name.isEmpty || url.isEmpty) {
      _isValidNotifier.value = false;
      return;
    }

    final key = style.key;
    final duplicate = _otherCustomStyles.any((v) => v.key == key || v.url == url);
    _isValidNotifier.value = !duplicate;
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.maybeOf(context)?.pop<EntryMapStyle>(_buildStyle());
    }
  }
}
