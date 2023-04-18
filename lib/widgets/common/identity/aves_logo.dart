import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/fx/colors.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvesLogo extends StatelessWidget {
  final double size;

  const AvesLogo({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child = CustomPaint(
      size: Size(size / 1.4, size / 1.4),
      painter: AvesLogoPainter(),
    );
    if (context.select<Settings, bool>((v) => v.themeColorMode == AvesThemeColorMode.monochrome)) {
      final tint = Color.lerp(theme.colorScheme.secondary, Colors.white, .5)!;
      child = ColorFiltered(
        colorFilter: ColorFilter.mode(tint, BlendMode.modulate),
        child: ColorFiltered(
          colorFilter: MatrixColorFilters.greyscale,
          child: child,
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: theme.dividerColor,
      radius: size / 2,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: size / 2 - AvesBorder.curvedBorderWidth,
        child: Padding(
          padding: EdgeInsets.only(top: size / 15),
          child: child,
        ),
      ),
    );
  }
}

class AvesLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dim = size.width / 100;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = dim * 2.346
      ..strokeJoin = StrokeJoin.round;

    final path0 = Path();
    path0.moveTo(dim * 3.925, dim * 16.034);
    path0.relativeLineTo(dim * 56.9, dim * 56.9);
    path0.relativeArcToPoint(Offset(dim * 3.423, dim * 0), radius: Radius.circular(dim * 2.42), rotation: 0.001, clockwise: false);
    path0.lineTo(dim * 74.852, dim * 62.33);
    path0.relativeArcToPoint(Offset(dim * 0, dim * -9.601), radius: Radius.circular(dim * 6.79), rotation: 90.001, clockwise: false);
    path0.lineTo(dim * 34.067, dim * 11.942);
    path0.relativeArcToPoint(Offset(dim * -5.844, dim * -2.42), radius: Radius.circular(dim * 8.264), rotation: 22.5, clockwise: false);
    path0.relativeLineTo(dim * -21.6, dim * 0);
    path0.relativeArcToPoint(Offset(dim * -2.697, dim * 6.512), radius: Radius.circular(dim * 3.815), rotation: 112.5, clockwise: false);
    path0.close();

    Path path1 = Path();
    path1.moveTo(dim * 36.36, dim * 65.907);
    path1.lineTo(dim * 36.36, dim * 94.65);
    path1.relativeArcToPoint(Offset(dim * 4.364, dim * 1.808), radius: Radius.circular(dim * 2.557), rotation: 22.5, clockwise: false);
    path1.relativeLineTo(dim * 13.093, dim * -13.094);
    path1.relativeArcToPoint(Offset(dim * 0, dim * -8.728), radius: Radius.circular(dim * 6.172), rotation: 90, clockwise: false);
    path1.lineTo(dim * 42.532, dim * 63.35);
    path1.relativeArcToPoint(Offset(dim * -6.172, dim * 2.557), radius: Radius.circular(dim * 3.616), rotation: 157.5, clockwise: false);
    path1.close();

    Path path2 = Path();
    path2.moveTo(dim * 79.653, dim * 40.078);
    path2.lineTo(dim * 79.653, dim * 11.335);
    path2.relativeArcToPoint(Offset(dim * -4.364, dim * -1.808), radius: Radius.circular(dim * 2.557), rotation: 22.5, clockwise: false);
    path2.lineTo(dim * 62.195, dim * 22.62);
    path2.relativeArcToPoint(Offset(dim * 0, dim * 8.729), radius: Radius.circular(dim * 6.172), rotation: 90, clockwise: false);
    path2.relativeLineTo(dim * 11.286, dim * 11.285);
    path2.relativeArcToPoint(Offset(dim * 6.172, dim * -2.556), radius: Radius.circular(dim * 3.616), rotation: 157.5, clockwise: false);
    path2.close();

    Path path3 = Path();
    path3.moveTo(dim * 96.613, dim * 16.867);
    path3.relativeLineTo(dim * -7.528, dim * -7.528);
    path3.relativeArcToPoint(Offset(dim * -3.273, dim * 1.355), radius: Radius.circular(dim * 1.917), rotation: 157.5, clockwise: false);
    path3.relativeLineTo(dim * 0, dim * 6.173);
    path3.relativeArcToPoint(Offset(dim * 4.629, dim * 4.629), radius: Radius.circular(dim * 4.63), rotation: 45, clockwise: false);
    path3.relativeLineTo(dim * 4.255, dim * 0);
    path3.relativeArcToPoint(Offset(dim * 1.917, dim * -4.63), radius: Radius.circular(dim * 2.712), rotation: 112.5, clockwise: false);
    path3.close();

    canvas.drawPath(
      path0,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xff3f51b5),
    );
    canvas.drawPath(
      path1,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xff4caf50),
    );
    canvas.drawPath(
      path2,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xffffc107),
    );
    canvas.drawPath(
        path3,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xffff5722));

    // stroke should be painted over fill
    canvas.drawPath(path0, strokePaint);
    canvas.drawPath(path1, strokePaint);
    canvas.drawPath(path2, strokePaint);
    canvas.drawPath(path3, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
