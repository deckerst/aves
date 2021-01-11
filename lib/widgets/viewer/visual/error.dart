import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final VoidCallback onTap;

  const ErrorView({@required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      // use a `Container` with a dummy color to make it expand
      // so that we can also detect taps around the title `Text`
      child: Container(
        color: Colors.transparent,
        child: EmptyContent(
          icon: AIcons.error,
          text: 'Oops!',
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
