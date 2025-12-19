import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/entry_group.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:flutter/material.dart';

/// A tile widget that represents a photo group in the gallery grid.
/// Displays a cover photo, stack icon with count, and optional group name.
class GroupTile extends StatelessWidget {
  final EntryGroup group;
  final double extent;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final AvesEntry? coverEntryOverride;

  const GroupTile({
    super.key,
    required this.group,
    required this.extent,
    this.onTap,
    this.onLongPress,
    this.coverEntryOverride,
    this.isSelected = false,
  });

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final coverEntry = coverEntryOverride ?? group.coverEntry;
    if (coverEntry == null) {
      return _buildEmptyTile(context);
    }

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          // Background "sheets" to create a stack effect
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Transform.rotate(
                angle: 0.05,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .3), width: 1),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Transform.rotate(
                angle: -0.03,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .5), width: 1),
                  ),
                ),
              ),
            ),
          ),
          // Main tile
          Container(
            width: extent,
            height: extent,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withValues(alpha: .8),
                width: isSelected ? 4.0 : 2.5,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover photo
                  ThumbnailImage(
                    entry: coverEntry,
                    extent: extent,
                    devicePixelRatio: devicePixelRatio,
                  ),

                  // Subtle gradient overlay for better text/icon visibility
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Colors.black.withValues(alpha: .3),
                            Colors.transparent,
                            Colors.black.withValues(alpha: .3),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Group icon (top-right)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.layers_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Group name label (bottom)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildNameLabel(context),
                  ),

                  if (isSelected)
                    Positioned.fill(
                      child: Container(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: .4),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameLabel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.0),
          ],
        ),
      ),
      child: Text(
        group.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black54,
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyTile(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Transform.rotate(
              angle: 0.05,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: extent,
          height: extent,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: .5),
              width: 2.5,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.layers_outlined,
                  size: 32,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  group.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Example usage in the collection grid
///
/// Widget _buildGridItem(GridItem item) {
///   if (item is SingleEntryItem) {
///     return ThumbnailTile(entry: item.entry, extent: extent);
///   } else if (item is GroupItem) {
///     return GroupTile(
///       group: item.group,
///       extent: extent,
///       onTap: () => _openGroupViewer(item.group),
///       onLongPress: () => _showGroupContextMenu(item.group),
///     );
///   }
///   return const SizedBox.shrink();
/// }
