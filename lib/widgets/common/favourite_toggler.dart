import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/sweeper.dart';
import 'package:flutter/material.dart';

class FavouriteToggler extends StatefulWidget {
  final Set<AvesEntry> entries;
  final bool isMenuItem;
  final VoidCallback? onPressed;

  const FavouriteToggler({
    Key? key,
    required this.entries,
    this.isMenuItem = false,
    this.onPressed,
  }) : super(key: key);

  @override
  State<FavouriteToggler> createState() => _FavouriteTogglerState();
}

class _FavouriteTogglerState extends State<FavouriteToggler> {
  final ValueNotifier<bool> isFavouriteNotifier = ValueNotifier(false);

  Set<AvesEntry> get entries => widget.entries;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isFavouriteNotifier,
      builder: (context, isFavourite, child) {
        if (widget.isMenuItem) {
          return isFavourite
              ? MenuRow(
                  text: context.l10n.entryActionRemoveFavourite,
                  icon: const Icon(AIcons.favouriteActive),
                )
              : MenuRow(
                  text: context.l10n.entryActionAddFavourite,
                  icon: const Icon(AIcons.favourite),
                );
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(isFavourite ? AIcons.favouriteActive : AIcons.favourite),
              onPressed: widget.onPressed,
              tooltip: isFavourite ? context.l10n.entryActionRemoveFavourite : context.l10n.entryActionAddFavourite,
            ),
            Sweeper(
              key: ValueKey(entries.length == 1 ? entries.first : entries.length),
              builder: (context) => const Icon(AIcons.favourite, color: AColors.favourite),
              toggledNotifier: isFavouriteNotifier,
            ),
          ],
        );
      },
    );
  }

  void _onChanged() {
    isFavouriteNotifier.value = entries.isNotEmpty && entries.every((entry) => entry.isFavourite);
  }
}
