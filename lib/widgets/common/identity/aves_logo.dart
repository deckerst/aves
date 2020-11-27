import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AvesLogo extends StatelessWidget {
  final double size;

  const AvesLogo({@required this.size});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: size / 2,
      child: Padding(
        padding: EdgeInsets.only(top: size / 15),
        child: SvgPicture.asset(
          'assets/aves_logo.svg',
          width: size / 1.4,
        ),
      ),
    );
  }
}
