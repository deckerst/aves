import 'dart:async';
import 'dart:io';

import 'package:aves/model/vaults/details.dart';
import 'package:aves/model/vaults/enums.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/password_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/pin_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:screen_state/screen_state.dart';

final Vaults vaults = Vaults._private();

class Vaults extends ChangeNotifier {
  final List<StreamSubscription> _subscriptions = [];
  Set<VaultDetails> _rows = {};
  final Set<String> _unlockedDirPaths = {};

  Vaults._private();

  Future<void> init() async {
    _rows = await metadataDb.loadAllVaults();
    _vaultDirPaths = null;
    final screenStateStream = Platform.isAndroid ? Screen().screenStateStream : null;
    if (screenStateStream != null) {
      _subscriptions.add(screenStateStream.where((event) => event == ScreenStateEvent.SCREEN_OFF).listen((event) => _onScreenOff()));
    }
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    super.dispose();
  }

  Set<VaultDetails> get all => Set.unmodifiable(_rows);

  VaultDetails? _detailsForPath(String dirPath) => _rows.firstWhereOrNull((v) => v.path == dirPath);

  Future<void> create(VaultDetails details) async {
    await metadataDb.addVaults({details});

    _rows.add(details);
    _vaultDirPaths = null;
    _unlockedDirPaths.add(details.path);
    _onLockStateChanged();
  }

  Future<void> remove(Set<String> dirPaths) async {
    final details = dirPaths.map(_detailsForPath).whereNotNull().toSet();
    if (details.isEmpty) return;

    await metadataDb.removeVaults(details);

    await Future.forEach(details, (v) => securityService.writeValue(v.passKey, null));

    _rows.removeAll(details);
    _vaultDirPaths = null;
    _unlockedDirPaths.removeAll(dirPaths);
    _onLockStateChanged();
  }

  Future<void> rename(String oldDirPath, String newDirPath) async {
    final oldDetails = _detailsForPath(oldDirPath);
    if (oldDetails == null) return;

    final newName = VaultDetails.nameFromPath(newDirPath);
    if (newName == null) return;

    final newDetails = oldDetails.copyWith(name: newName);
    await metadataDb.updateVault(oldDetails.name, newDetails);

    final pass = await securityService.readValue(oldDetails.passKey);
    if (pass != null) {
      await securityService.writeValue(newDetails.passKey, pass);
    }

    _rows
      ..remove(oldDetails)
      ..add(newDetails);
    _vaultDirPaths = null;
    _unlockedDirPaths
      ..remove(oldDirPath)
      ..add(newDirPath);
    _onLockStateChanged();
  }

  // update details, except name
  Future<void> update(VaultDetails newDetails) async {
    final oldDetails = _detailsForPath(newDetails.path);
    if (oldDetails == null) return;

    await metadataDb.updateVault(newDetails.name, newDetails);

    _rows
      ..remove(oldDetails)
      ..add(newDetails);
  }

  Future<void> clear() async {
    await metadataDb.clearVaults();
    _rows.clear();
    _vaultDirPaths = null;
  }

  Set<String>? _vaultDirPaths;

  Set<String> get vaultDirectories {
    _vaultDirPaths ??= _rows.map((v) => v.path).toSet();
    return _vaultDirPaths!;
  }

  VaultDetails? getVault(String? dirPath) => all.firstWhereOrNull((v) => v.path == dirPath);

  bool isVault(String dirPath) => vaultDirectories.contains(dirPath);

  bool isLocked(String dirPath) => isVault(dirPath) && !_unlockedDirPaths.contains(dirPath);

  bool isVaultEntryUri(String uriString) {
    final uri = Uri.parse(uriString);
    if (uri.scheme != 'file') return false;

    final path = uri.pathSegments.fold('', (prev, v) => '$prev${pContext.separator}$v');
    return vaultDirectories.any(path.startsWith);
  }

  void lock(Set<String> dirPaths) {
    final unlocked = dirPaths.where((v) => isVault(v) && !isLocked(v)).toSet();
    if (unlocked.isEmpty) return;

    _unlockedDirPaths.removeAll(unlocked);
    _onLockStateChanged();
  }

  Future<bool> tryUnlock(String dirPath, BuildContext context) async {
    if (!isVault(dirPath) || !isLocked(dirPath)) return true;

    final details = _detailsForPath(dirPath);
    if (details == null) return false;

    bool? confirmed;
    switch (details.lockType) {
      case VaultLockType.system:
        try {
          confirmed = await LocalAuthentication().authenticate(
            localizedReason: context.l10n.authenticateToUnlockVault,
          );
        } on PlatformException catch (e, stack) {
          await reportService.recordError(e, stack);
        }
        break;
      case VaultLockType.pin:
        final pin = await showDialog<String>(
          context: context,
          builder: (context) => const PinDialog(needConfirmation: false),
          routeSettings: const RouteSettings(name: PinDialog.routeName),
        );
        if (pin != null) {
          confirmed = pin == await securityService.readValue(details.passKey);
        }
        break;
      case VaultLockType.password:
        final password = await showDialog<String>(
          context: context,
          builder: (context) => const PasswordDialog(needConfirmation: false),
          routeSettings: const RouteSettings(name: PasswordDialog.routeName),
        );
        if (password != null) {
          confirmed = password == await securityService.readValue(details.passKey);
        }
        break;
    }

    if (confirmed == null || !confirmed) return false;

    _unlockedDirPaths.add(dirPath);
    _onLockStateChanged();
    return true;
  }

  Future<bool> setPass(BuildContext context, VaultDetails details) async {
    switch (details.lockType) {
      case VaultLockType.system:
        final l10n = context.l10n;
        try {
          return await LocalAuthentication().authenticate(
            localizedReason: l10n.authenticateToConfigureVault,
          );
        } on PlatformException catch (e, stack) {
          await showDialog(
            context: context,
            builder: (context) => AvesDialog(
              content: Text(e.message ?? l10n.genericFailureFeedback),
              actions: const [OkButton()],
            ),
            routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
          );
          if (e.code != auth_error.notAvailable) {
            await reportService.recordError(e, stack);
          }
        }
        break;
      case VaultLockType.pin:
        final pin = await showDialog<String>(
          context: context,
          builder: (context) => const PinDialog(needConfirmation: true),
          routeSettings: const RouteSettings(name: PinDialog.routeName),
        );
        if (pin != null) {
          return await securityService.writeValue(details.passKey, pin);
        }
        break;
      case VaultLockType.password:
        final password = await showDialog<String>(
          context: context,
          builder: (context) => const PasswordDialog(needConfirmation: true),
          routeSettings: const RouteSettings(name: PasswordDialog.routeName),
        );
        if (password != null) {
          return await securityService.writeValue(details.passKey, password);
        }
        break;
    }
    return false;
  }

  void _onScreenOff() => lock(all.where((v) => v.autoLockScreenOff).map((v) => v.path).toSet());

  void _onLockStateChanged() {
    windowService.secureScreen(_unlockedDirPaths.isNotEmpty);
    notifyListeners();
  }
}
