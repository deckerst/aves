import 'package:flutter/material.dart';

class AboutNewsBadge extends StatelessWidget {
  const AboutNewsBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.circle,
      size: 12,
      color: Colors.red,
    );
  }
}
