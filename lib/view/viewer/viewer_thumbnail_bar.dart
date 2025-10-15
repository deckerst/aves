import 'package:flutter/material.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:provider/provider.dart';

class ViewerThumbnailBar extends StatefulWidget {
  final List<AvesEntry> entries;
  final AvesEntry? currentEntry;
  final ValueChanged<AvesEntry>? onSelectEntry;
  final double height;
  final bool showVideos;

  const ViewerThumbnailBar({
    Key? key,
    required this.entries,
    this.currentEntry,
    this.onSelectEntry,
    this.height = 80.0,
    this.showVideos = true,
  }) : super(key: key);

  @override
  _ViewerThumbnailBarState createState() => _ViewerThumbnailBarState();
}

class _ViewerThumbnailBarState extends State<ViewerThumbnailBar> 
    with SingleTickerProviderStateMixin {
  
  ScrollController? _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // Auto-scroll to current entry on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentEntry();
    });
  }

  @override
  void didUpdateWidget(ViewerThumbnailBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentEntry != widget.currentEntry) {
      _scrollToCurrentEntry();
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToCurrentEntry() {
    if (widget.currentEntry == null || _scrollController == null) return;
    
    final currentIndex = _getFilteredEntries().indexOf(widget.currentEntry!);
    if (currentIndex >= 0) {
      final double targetOffset = currentIndex * 72.0; // 64px width + 8px margin
      _scrollController!.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  List<AvesEntry> _getFilteredEntries() {
    return widget.entries.where((entry) {
      if (!widget.showVideos && entry.isVideo) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    
    if (!settings.showThumbnailStripAlways) {
      return const SizedBox.shrink();
    }

    final filteredEntries = _getFilteredEntries();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        child: filteredEntries.isEmpty
          ? const Center(
              child: Text(
                'No media to display',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: filteredEntries.length,
              itemBuilder: (context, index) {
                final entry = filteredEntries[index];
                final isActive = entry == widget.currentEntry;
                
                return _ThumbnailCard(
                  entry: entry,
                  isActive: isActive,
                  onTap: () => widget.onSelectEntry?.call(entry),
                );
              },
            ),
      ),
    );
  }
}

class _ThumbnailCard extends StatelessWidget {
  final AvesEntry entry;
  final bool isActive;
  final VoidCallback? onTap;

  const _ThumbnailCard({
    Key? key,
    required this.entry,
    required this.isActive,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isActive 
                ? Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  )
                : null,
              boxShadow: isActive 
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  // Thumbnail image
                  Positioned.fill(
                    child: ThumbnailImage(
                      entry: entry,
                      extent: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // Video indicator
                  if (entry.isVideo)
                    const Positioned(
                      bottom: 4,
                      right: 4,
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  
                  // Active overlay
                  if (isActive)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
