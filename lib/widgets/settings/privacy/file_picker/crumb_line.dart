import 'package:aves/services/common/services.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

class CrumbLine extends StatefulWidget {
  final VolumeRelativeDirectory directory;
  final void Function(String path) onTap;

  const CrumbLine({
    super.key,
    required this.directory,
    required this.onTap,
  });

  @override
  State<CrumbLine> createState() => _CrumbLineState();
}

class _CrumbLineState extends State<CrumbLine> {
  final ScrollController _scrollController = ScrollController();

  VolumeRelativeDirectory get directory => widget.directory;

  @override
  void didUpdateWidget(covariant CrumbLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.directory.relativeDir.length < widget.directory.relativeDir.length) {
      // scroll to show last crumb
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final extent = _scrollController.position.maxScrollExtent;
        _scrollController.animateTo(
          extent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuad,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> parts = [
      directory.getVolumeDescription(context),
      ...pContext.split(directory.relativeDir),
    ];
    final crumbStyle = Theme.of(context).textTheme.bodyMedium;
    final crumbColor = crumbStyle!.color!.withOpacity(.4);
    return DefaultTextStyle(
      style: crumbStyle.copyWith(
        color: crumbColor,
        fontWeight: FontWeight.w500,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          Widget _buildText(String text) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(text),
              );

          if (index >= parts.length) return const SizedBox();
          final text = parts[index];
          if (index == parts.length - 1) {
            return Center(
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: _buildText(text),
              ),
            );
          }
          return GestureDetector(
            onTap: () {
              final path = pContext.joinAll([
                directory.volumePath,
                ...parts.skip(1).take(index),
              ]);
              widget.onTap(path);
            },
            child: Container(
              // use a `Container` with a dummy color to make it expand
              // so that we can also detect taps around the title `Text`
              color: Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildText(text),
                  Icon(
                    AIcons.next,
                    color: crumbColor,
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: parts.length,
      ),
    );
  }
}
