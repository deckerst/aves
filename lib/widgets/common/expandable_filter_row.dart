import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';

class TitledExpandableFilterRow extends StatelessWidget {
  final String title;
  final List<CollectionFilter> filters;
  final ValueNotifier<String?> expandedNotifier;
  final bool showGenericIcon;
  final HeroType Function(CollectionFilter filter)? heroTypeBuilder;
  final AFilterCallback onTap;
  final OffsetFilterCallback? onLongPress;

  const TitledExpandableFilterRow({
    super.key,
    required this.title,
    required this.filters,
    required this.expandedNotifier,
    this.showGenericIcon = true,
    this.heroTypeBuilder,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox();

    final isExpanded = expandedNotifier.value == title;

    Widget header = Text(
      title,
      style: AStyles.knownTitleText,
    );
    void toggle() => expandedNotifier.value = isExpanded ? null : title;
    if (settings.useTvLayout) {
      header = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: InkWell(
          onTap: toggle,
          borderRadius: const BorderRadius.all(Radius.circular(123)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                header,
                const SizedBox(width: 16),
                Icon(isExpanded ? AIcons.collapse : AIcons.expand),
              ],
            ),
          ),
        ),
      );
    } else {
      header = Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            header,
            const Spacer(),
            IconButton(
              icon: Icon(isExpanded ? AIcons.collapse : AIcons.expand),
              onPressed: toggle,
              tooltip: isExpanded ? MaterialLocalizations.of(context).expandedIconTapHint : MaterialLocalizations.of(context).collapsedIconTapHint,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        ExpandableFilterRow(
          filters: filters,
          isExpanded: isExpanded,
          showGenericIcon: showGenericIcon,
          heroTypeBuilder: heroTypeBuilder,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ],
    );
  }
}

class ExpandableFilterRow extends StatelessWidget {
  final List<CollectionFilter> filters;
  final bool isExpanded;
  final bool showGenericIcon;
  final Widget? Function(CollectionFilter)? leadingBuilder;
  final HeroType Function(CollectionFilter filter)? heroTypeBuilder;
  final AFilterCallback onTap;
  final AFilterCallback? onRemove;
  final OffsetFilterCallback? onLongPress;

  static const double horizontalPadding = 8;
  static const double verticalPadding = 8;

  const ExpandableFilterRow({
    super.key,
    required this.filters,
    required this.isExpanded,
    this.showGenericIcon = true,
    this.leadingBuilder,
    this.heroTypeBuilder,
    required this.onTap,
    this.onRemove,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox();
    return AnimatedSwitcher(
      duration: ADurations.filterRowExpandAnimation,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        children: [
          ...previousChildren,
          if (currentChild != null) currentChild,
        ],
      ),
      child: isExpanded ? _buildExpanded() : _buildCollapsed(),
    );
  }

  Widget _buildExpanded() {
    return Container(
      key: const Key('wrap'),
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      // specify transparent as a workaround to prevent
      // chip border clipping when the floating app bar is fading
      color: Colors.transparent,
      child: Wrap(
        spacing: horizontalPadding,
        runSpacing: verticalPadding,
        children: filters.map(_buildChip).toList(),
      ),
    );
  }

  Widget _buildCollapsed() {
    final list = Container(
      key: const Key('list'),
      // specify transparent as a workaround to prevent
      // chip border clipping when the floating app bar is fading
      color: Colors.transparent,
      height: AvesFilterChip.minChipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemBuilder: (context, index) {
          return index < filters.length ? _buildChip(filters[index]) : const SizedBox();
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: filters.length,
      ),
    );
    return list;
  }

  Widget _buildChip(CollectionFilter filter) {
    return AvesFilterChip(
      // key `album-{path}` is expected by test driver
      key: Key(filter.key),
      filter: filter,
      allowGenericIcon: showGenericIcon,
      leadingOverride: leadingBuilder?.call(filter),
      heroType: heroTypeBuilder?.call(filter) ?? HeroType.onTap,
      onTap: onTap,
      onRemove: onRemove,
      onLongPress: onLongPress,
    );
  }
}
