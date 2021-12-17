import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

import 'aves_dialog.dart';

class VideoSpeedDialog extends StatefulWidget {
  final double current, min, max;

  const VideoSpeedDialog({
    Key? key,
    required this.current,
    required this.min,
    required this.max,
  }) : super(key: key);

  @override
  _VideoSpeedDialogState createState() => _VideoSpeedDialogState();
}

class _VideoSpeedDialogState extends State<VideoSpeedDialog> {
  late double _speed;

  static const interval = .25;

  @override
  void initState() {
    super.initState();
    _speed = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      horizontalContentPadding: 4,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              children: [
                Text(context.l10n.videoSpeedDialogLabel),
                const SizedBox(width: 16),
                Text('x$_speed'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _speed,
            onChanged: (v) => setState(() => _speed = v),
            min: widget.min,
            max: widget.max,
            divisions: ((widget.max - widget.min) / interval).round(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => _submit(context),
          child: Text(context.l10n.applyButtonLabel),
        ),
      ],
    );
  }

  void _submit(BuildContext context) => Navigator.pop(context, _speed);
}
