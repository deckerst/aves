import 'package:aves/theme/icons.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkChip extends StatelessWidget {
  final Widget? leading;
  final String text;
  final String? url;
  final Color? color;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  static const borderRadius = BorderRadius.all(Radius.circular(8));

  const LinkChip({
    Key? key,
    this.leading,
    required this.text,
    this.url,
    this.color,
    this.textStyle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _url = url;
    return DefaultTextStyle.merge(
      style: (textStyle ?? const TextStyle()).copyWith(color: color),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap ??
            () async {
              if (_url != null && await canLaunch(_url)) {
                await launch(_url);
              }
            },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (context) => Icon(
                  AIcons.openOutside,
                  size: DefaultTextStyle.of(context).style.fontSize,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
