import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/vaults/details.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/password_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/pattern_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/pin_dialog.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

mixin VaultAwareMixin on FeedbackMixin {
  Future<bool> _tryUnlock(String dirPath, BuildContext context) async {
    if (!vaults.isVault(dirPath) || !vaults.isLocked(dirPath)) return true;

    final details = vaults.detailsForPath(dirPath);
    if (details == null) return false;

    bool? confirmed;
    switch (details.lockType) {
      case VaultLockType.system:
        try {
          confirmed = await LocalAuthentication().authenticate(
            localizedReason: context.l10n.authenticateToUnlockVault,
          );
        } on PlatformException catch (e, stack) {
          if (!{'auth_in_progress', 'NotAvailable'}.contains(e.code)) {
            // `auth_in_progress`: `Authentication in progress`
            // `NotAvailable`: `Required security features not enabled`
            await reportService.recordError(e, stack);
          }
        }
        break;
      case VaultLockType.pattern:
        final pattern = await showDialog<String>(
          context: context,
          builder: (context) => const PatternDialog(needConfirmation: false),
          routeSettings: const RouteSettings(name: PatternDialog.routeName),
        );
        if (pattern != null) {
          confirmed = pattern == await securityService.readValue(details.passKey);
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

    vaults.unlock(dirPath);
    return true;
  }

  Future<bool> unlockAlbum(BuildContext context, String dirPath) async {
    final success = await _tryUnlock(dirPath, context);
    if (!success) {
      showFeedback(context, context.l10n.genericFailureFeedback);
    }
    return success;
  }

  Future<bool> unlockFilter(BuildContext context, CollectionFilter filter) {
    return filter is AlbumFilter ? unlockAlbum(context, filter.album) : Future.value(true);
  }

  Future<bool> unlockFilters(BuildContext context, Set<AlbumFilter> filters) async {
    var unlocked = true;
    await Future.forEach(filters, (filter) async {
      if (unlocked) {
        unlocked = await unlockFilter(context, filter);
      }
    });
    return unlocked;
  }

  void lockFilters(Set<AlbumFilter> filters) => vaults.lock(filters.map((v) => v.album).toSet());

  Future<bool> setVaultPass(BuildContext context, VaultDetails details) async {
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
      case VaultLockType.pattern:
        final pattern = await showDialog<String>(
          context: context,
          builder: (context) => const PatternDialog(needConfirmation: true),
          routeSettings: const RouteSettings(name: PatternDialog.routeName),
        );
        if (pattern != null) {
          return await securityService.writeValue(details.passKey, pattern);
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
}
