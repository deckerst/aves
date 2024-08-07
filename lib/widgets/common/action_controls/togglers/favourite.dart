import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/favourites.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/sweeper.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavouriteToggler extends StatefulWidget {
  final Set<AvesEntry> entries;
  final bool isMenuItem;
  final FocusNode? focusNode;
  final VoidCallback? onPressed;

  const FavouriteToggler({
    super.key,
    required this.entries,
    this.isMenuItem = false,
    this.focusNode,
    this.onPressed,
  });

  @override
  State<FavouriteToggler> createState() => _FavouriteTogglerState();
}

class _FavouriteTogglerState extends State<FavouriteToggler> {
  final ValueNotifier<bool> _isFavouriteNotifier = ValueNotifier(false);

  Set<AvesEntry> get entries => widget.entries;

  static const isFavouriteIcon = AIcons.favouriteActive;
  static const isNotFavouriteIcon = AIcons.favourite;
  static const favouriteSweeperIcon = AIcons.favourite;

  @override
  void initState() {
    super.initState();
    favourites.addListener(_onChanged);
    _onChanged();
  }

  @override
  void didUpdateWidget(covariant FavouriteToggler oldWidget) {
    super.didUpdateWidget(oldWidget);
    _onChanged();
  }

  @override
  void dispose() {
    favourites.removeListener(_onChanged);
    _isFavouriteNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isFavouriteNotifier,
      builder: (context, isFavourite, child) {
        if (widget.isMenuItem) {
          return isFavourite
              ? MenuRow(
                  text: context.l10n.entryActionRemoveFavourite,
                  icon: const Icon(isFavouriteIcon),
                )
              : MenuRow(
                  text: context.l10n.entryActionAddFavourite,
                  icon: const Icon(isNotFavouriteIcon),
                );
        }
        final animate = context.select<Settings, bool>((v) => v.animate);
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(isFavourite ? isFavouriteIcon : isNotFavouriteIcon),
              onPressed: widget.onPressed,
              focusNode: widget.focusNode,
              tooltip: isFavourite ? context.l10n.entryActionRemoveFavourite : context.l10n.entryActionAddFavourite,
            ),
            if (animate)
              Sweeper(
                key: ValueKey(entries.length == 1 ? entries.first : entries.length),
                builder: (context) => Icon(
                  favouriteSweeperIcon,
                  color: context.select<AvesColorsData, Color>((v) => v.favourite),
                ),
                toggledNotifier: _isFavouriteNotifier,
              ),
          ],
        );
      },
    );
  }

  void _onChanged() {
    _isFavouriteNotifier.value = entries.isNotEmpty && entries.every((entry) => entry.isFavourite);
  }
}

class FavouriteTogglerCaption extends StatefulWidget {
  final Set<AvesEntry> entries;
  final bool enabled;

  const FavouriteTogglerCaption({
    super.key,
    required this.entries,
    required this.enabled,
  });

  @override
  State<FavouriteTogglerCaption> createState() => _FavouriteTogglerCaptionState();
}

class _FavouriteTogglerCaptionState extends State<FavouriteTogglerCaption> {
  final ValueNotifier<bool> _isFavouriteNotifier = ValueNotifier(false);

  Set<AvesEntry> get entries => widget.entries;

  @override
  void initState() {
    super.initState();
    favourites.addListener(_onChanged);
    _onChanged();
  }

  @override
  void didUpdateWidget(covariant FavouriteTogglerCaption oldWidget) {
    super.didUpdateWidget(oldWidget);
    _onChanged();
  }

  @override
  void dispose() {
    favourites.removeListener(_onChanged);
    _isFavouriteNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isFavouriteNotifier,
      builder: (context, isFavourite, child) {
        return CaptionedButtonText(
          text: isFavourite ? context.l10n.entryActionRemoveFavourite : context.l10n.entryActionAddFavourite,
          enabled: widget.enabled,
        );
      },
    );
  }

  void _onChanged() {
    _isFavouriteNotifier.value = entries.isNotEmpty && entries.every((entry) => entry.isFavourite);
  }
}
