import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class CrumbLine extends StatefulWidget {
  final VolumeRelativeDirectory directory;
  final void Function(String path) onTap;

  const CrumbLine({
    Key? key,
    required this.directory,
    required this.onTap,
  }) : super(key: key);

  @override
  _CrumbLineState createState() => _CrumbLineState();
}

class _CrumbLineState extends State<CrumbLine> {
  final ScrollController _controller = ScrollController();

  VolumeRelativeDirectory get directory => widget.directory;

  @override
  void didUpdateWidget(covariant CrumbLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.directory.relativeDir.length > oldWidget.directory.relativeDir.length) {
      // scroll to show last crumb
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        final extent = _controller.position.maxScrollExtent;
        _controller.animateTo(
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
      ...p.split(directory.relativeDir),
    ];
    final crumbStyle = Theme.of(context).textTheme.bodyText2;
    final crumbColor = crumbStyle!.color!.withOpacity(.4);
    return DefaultTextStyle(
      style: crumbStyle.copyWith(
        color: crumbColor,
        fontWeight: FontWeight.w500,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        physics: const BouncingScrollPhysics(),
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
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: _buildText(text),
              ),
            );
          }
          return GestureDetector(
            onTap: () {
              final path = p.joinAll([
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
