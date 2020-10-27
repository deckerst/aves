import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SectionRow extends StatelessWidget {
  final IconData icon;

  const SectionRow(this.icon);

  @override
  Widget build(BuildContext context) {
    const dim = 32.0;
    Widget buildDivider() => SizedBox(
          width: dim,
          child: Divider(
            thickness: AvesFilterChip.outlineWidth,
            color: Colors.white70,
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildDivider(),
        Padding(
          padding: EdgeInsets.all(16),
          child: Icon(
            icon,
            size: dim,
          ),
        ),
        buildDivider(),
      ],
    );
  }
}

class InfoRowGroup extends StatefulWidget {
  final Map<String, String> keyValues;
  final int maxValueLength;

  const InfoRowGroup(
    this.keyValues, {
    this.maxValueLength = 0,
  });

  @override
  _InfoRowGroupState createState() => _InfoRowGroupState();
}

class _InfoRowGroupState extends State<InfoRowGroup> {
  final List<String> _expandedKeys = [];

  Map<String, String> get keyValues => widget.keyValues;

  int get maxValueLength => widget.maxValueLength;

  @override
  Widget build(BuildContext context) {
    if (keyValues.isEmpty) return SizedBox.shrink();
    final lastKey = keyValues.keys.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText.rich(
          TextSpan(
            children: keyValues.entries.expand(
              (kv) {
                final key = kv.key;
                var value = kv.value;
                final showPreviewOnly = maxValueLength > 0 && value.length > maxValueLength && !_expandedKeys.contains(key);
                if (showPreviewOnly) {
                  value = '${value.substring(0, maxValueLength)}…';
                }
                return [
                  TextSpan(text: '$key     ', style: TextStyle(color: Colors.white70, height: 1.7)),
                  TextSpan(text: '$value${key == lastKey ? '' : '\n'}', recognizer: showPreviewOnly ? _buildTapRecognizer(key) : null),
                ];
              },
            ).toList(),
          ),
          style: TextStyle(fontFamily: 'Concourse'),
        ),
      ],
    );
  }

  GestureRecognizer _buildTapRecognizer(String key) {
    return TapGestureRecognizer()..onTap = () => setState(() => _expandedKeys.add(key));
  }
}
