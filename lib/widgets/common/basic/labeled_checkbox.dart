import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LabeledCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;

  const LabeledCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.text,
  }) : super(key: key);

  @override
  State<LabeledCheckbox> createState() => _LabeledCheckboxState();
}

class _LabeledCheckboxState extends State<LabeledCheckbox> {
  late TapGestureRecognizer _tapRecognizer;

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()..onTap = () => widget.onChanged(!widget.value);
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Checkbox(
              value: widget.value,
              onChanged: widget.onChanged,
            ),
          ),
          TextSpan(
            text: widget.text,
            recognizer: _tapRecognizer,
          ),
        ],
      ),
    );
  }
}
