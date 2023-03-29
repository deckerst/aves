import 'package:aves/model/device.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/vaults/details.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/vault_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_caption.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/common.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/single_selection.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditVaultDialog extends StatefulWidget {
  static const routeName = '/dialog/edit_vault';

  final VaultDetails? initialDetails;

  const EditVaultDialog({
    super.key,
    this.initialDetails,
  });

  @override
  State<EditVaultDialog> createState() => _EditVaultDialogState();
}

class _EditVaultDialogState extends State<EditVaultDialog> with FeedbackMixin, VaultAwareMixin {
  final TextEditingController _nameController = TextEditingController();
  late bool _useBin;
  late bool _autoLockScreenOff;
  late VaultLockType _lockType;

  final ValueNotifier<bool> _existsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  final List<VaultLockType> _lockTypeOptions = [
    if (device.canAuthenticateUser) VaultLockType.system,
    if (device.canUseCrypto) ...[
      VaultLockType.pattern,
      VaultLockType.pin,
      VaultLockType.password,
    ],
  ];

  VaultDetails? get initialDetails => widget.initialDetails;

  String get newName => _nameController.text;

  @override
  void initState() {
    super.initState();
    final details = initialDetails ??
        VaultDetails(
          name: '',
          autoLockScreenOff: true,
          useBin: settings.enableBin,
          lockType: _lockTypeOptions.first,
        );
    _nameController.text = details.name;
    _useBin = details.useBin;
    _autoLockScreenOff = details.autoLockScreenOff;
    _lockType = details.lockType;
    _validate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _existsNotifier.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isNew = initialDetails == null;
    return AvesDialog(
      title: isNew ? l10n.newVaultDialogTitle : l10n.configureVaultDialogTitle,
      scrollableContent: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ValueListenableBuilder<bool>(
              valueListenable: _existsNotifier,
              builder: (context, exists, child) {
                return TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.newAlbumDialogNameLabel,
                    helperText: exists ? l10n.newAlbumDialogNameLabelAlreadyExistsHelper : '',
                  ),
                  onChanged: (_) => _validate(),
                  onSubmitted: (_) => _submit(context),
                );
              }),
        ),
        if (_lockTypeOptions.length > 1)
          ListTile(
            title: Text(l10n.vaultDialogLockTypeLabel),
            subtitle: AvesCaption(_lockType.getText(context)),
            onTap: () {
              _unfocus();
              showSelectionDialog<VaultLockType>(
                context: context,
                builder: (context) => AvesSingleSelectionDialog<VaultLockType>(
                  initialValue: _lockType,
                  options: Map.fromEntries(_lockTypeOptions.map((v) => MapEntry(v, v.getText(context)))),
                ),
                onSelection: (v) => setState(() => _lockType = v),
              );
            },
          ),
        SwitchListTile(
          value: _autoLockScreenOff,
          onChanged: (v) => setState(() => _autoLockScreenOff = v),
          title: Text(l10n.vaultDialogLockModeWhenScreenOff),
        ),
        if (settings.enableBin)
          SwitchListTile(
            value: _useBin,
            onChanged: (v) async {
              if (!v) {
                final album = initialDetails?.path;
                if (album != null) {
                  final filter = AlbumFilter(album, null);
                  final source = context.read<CollectionSource>();
                  if (source.trashedEntries.any(filter.test)) {
                    if (!await showConfirmationDialog(
                      context: context,
                      message: l10n.settingsDisablingBinWarningDialogMessage,
                      confirmationButtonLabel: l10n.applyButtonLabel,
                    )) return;
                  }
                }
              }
              setState(() => _useBin = v);
            },
            title: Text(l10n.settingsEnableBin),
          ),
      ],
      actions: [
        const CancelButton(),
        ValueListenableBuilder<bool>(
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return TextButton(
              onPressed: isValid ? () => _submit(context) : null,
              child: Text(isNew ? l10n.createAlbumButtonLabel : l10n.applyButtonLabel),
            );
          },
        ),
      ],
    );
  }

  // remove focus, if any, to prevent the keyboard from showing up
  // after the user is done with the dialog
  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  Future<void> _validate() async {
    final notEmpty = newName.isNotEmpty;
    final exists = notEmpty && vaults.all.map((v) => v.name).contains(newName) && newName != initialDetails?.name;
    _existsNotifier.value = exists;
    _isValidNotifier.value = notEmpty && !exists;
  }

  Future<void> _submit(BuildContext context) async {
    if (!_isValidNotifier.value) return;

    _unfocus();

    final details = VaultDetails(
      name: newName,
      autoLockScreenOff: _autoLockScreenOff,
      useBin: _useBin,
      lockType: _lockType,
    );
    if (!await setVaultPass(context, details)) return;

    Navigator.maybeOf(context)?.pop(details);
  }
}
