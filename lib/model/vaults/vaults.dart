import 'dart:async';
import 'dart:io';

import 'package:aves/model/vaults/details.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_screen_state/aves_screen_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

final Vaults vaults = Vaults._private();

class Vaults extends ChangeNotifier {
  final List<StreamSubscription> _subscriptions = [];
  Set<VaultDetails> _rows = {};
  final Set<String> _unlockedDirPaths = {};

  Vaults._private();

  Future<void> init() async {
    _rows = await metadataDb.loadAllVaults();
    _vaultDirPaths = null;
    final screenStateStream = Platform.isAndroid ? AvesScreenState().screenStateStream : null;
    if (screenStateStream != null) {
      _subscriptions.add(screenStateStream.where((event) => event == ScreenStateEvent.off).listen((event) => _onScreenOff()));
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

  VaultDetails? detailsForPath(String dirPath) => _rows.firstWhereOrNull((v) => v.path == dirPath);

  Future<void> create(VaultDetails details) async {
    await metadataDb.addVaults({details});

    _rows.add(details);
    _vaultDirPaths = null;
    _unlockedDirPaths.add(details.path);
    _onLockStateChanged();
  }

  Future<void> remove(Set<String> dirPaths) async {
    final details = dirPaths.map(detailsForPath).whereNotNull().toSet();
    if (details.isEmpty) return;

    await metadataDb.removeVaults(details);

    await Future.forEach(details, (v) => securityService.writeValue(v.passKey, null));

    _rows.removeAll(details);
    _vaultDirPaths = null;
    _unlockedDirPaths.removeAll(dirPaths);
    _onLockStateChanged();
  }

  Future<void> rename(String oldDirPath, String newDirPath) async {
    final oldDetails = detailsForPath(oldDirPath);
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
    final oldDetails = detailsForPath(newDetails.path);
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

  void unlock(String dirPath) {
    if (!vaults.isVault(dirPath) || !vaults.isLocked(dirPath)) return;

    _unlockedDirPaths.add(dirPath);
    _onLockStateChanged();
  }

  void _onScreenOff() => lock(all.where((v) => v.autoLockScreenOff).map((v) => v.path).toSet());

  void _onLockStateChanged() {
    windowService.secureScreen(_unlockedDirPaths.isNotEmpty);
    notifyListeners();
  }
}
