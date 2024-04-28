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
      final tint = Color.lerp(theme.colorScheme.primary, Colors.white, .5)!;
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
        radius: size / 2 - AvesBorder.curvedBorderWidth(context),
        child: child,
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
      ..strokeWidth = dim * 3.050970
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path0 = Path();
    path0.moveTo(31.784 * dim, 63.612 * dim);
    path0.lineTo(48.252 * dim, 80.08 * dim);
    final radius = Radius.elliptical(2.911 * dim, 2.911 * dim);
    path0.arcToPoint(Offset(48.252 * dim, 84.196 * dim), radius: radius, rotation: 0, largeArc: false, clockwise: true);
    path0.lineTo(40.379000000000005 * dim, 92.069 * dim);
    path0.arcToPoint(Offset(19.072000000000006 * dim, 92.069 * dim), radius: Radius.elliptical(15.067 * dim, 15.067 * dim), rotation: 0, largeArc: false, clockwise: true);
    path0.lineTo(11.2 * dim, 84.197 * dim);
    path0.arcToPoint(Offset(11.2 * dim, 80.08 * dim), radius: radius, rotation: 0, largeArc: false, clockwise: true);
    path0.lineTo(27.668 * dim, 63.611999999999995 * dim);
    path0.arcToPoint(Offset(31.785 * dim, 63.611999999999995 * dim), radius: radius, rotation: 0, largeArc: false, clockwise: true);
    path0.close();

    final path1 = Path();
    path1.moveTo(56.368 * dim, 39.026 * dim);
    path1.lineTo(72.837 * dim, 55.494 * dim);
    final radius2 = Radius.elliptical(2.904 * dim, 2.904 * dim);
    path1.arcToPoint(Offset(72.837 * dim, 59.611 * dim), radius: radius2, rotation: 0, largeArc: false, clockwise: true);
    path1.lineTo(56.367000000000004 * dim, 76.079 * dim);
    path1.arcToPoint(Offset(52.252 * dim, 76.079 * dim), radius: radius2, rotation: 0, largeArc: false, clockwise: true);
    path1.lineTo(35.784 * dim, 59.611 * dim);
    path1.arcToPoint(Offset(35.784 * dim, 55.495 * dim), radius: radius2, rotation: 0, largeArc: false, clockwise: true);
    path1.lineTo(52.251999999999995 * dim, 39.027 * dim);
    path1.arcToPoint(Offset(56.367999999999995 * dim, 39.027 * dim), radius: radius2, rotation: 0, largeArc: false, clockwise: true);
    path1.close();

    final path2 = Path();
    path2.moveTo(60.37 * dim, 30.908 * dim);
    final radius4 = Radius.elliptical(2.91 * dim, 2.91 * dim);
    path2.arcToPoint(Offset(60.37 * dim, 35.025 * dim), radius: radius4, rotation: 0, largeArc: false, clockwise: false);
    path2.lineTo(76.838 * dim, 51.492 * dim);
    path2.arcToPoint(Offset(80.954 * dim, 51.492 * dim), radius: radius4, rotation: 0, largeArc: false, clockwise: false);
    path2.lineTo(97.422 * dim, 35.025 * dim);
    path2.arcToPoint(Offset(97.422 * dim, 30.907999999999998 * dim), radius: radius4, rotation: 0, largeArc: false, clockwise: false);
    path2.lineTo(89.24799999999999 * dim, 22.733999999999998 * dim);
    path2.arcToPoint(Offset(68.54399999999998 * dim, 22.733999999999998 * dim), radius: Radius.elliptical(14.64 * dim, 14.64 * dim), rotation: 0, largeArc: false, clockwise: false);
    path2.close();
    path2.moveTo(76.624 * dim, 30.695 * dim);
    final radius5 = Radius.elliptical(3.213 * dim, 3.213 * dim);
    path2.arcToPoint(Offset(81.167 * dim, 30.695 * dim), radius: radius5, rotation: 0, largeArc: false, clockwise: true);
    path2.arcToPoint(Offset(81.167 * dim, 35.237 * dim), radius: radius5, rotation: 0, largeArc: false, clockwise: true);
    path2.arcToPoint(Offset(76.624 * dim, 35.237 * dim), radius: radius5, rotation: 0, largeArc: false, clockwise: true);
    path2.arcToPoint(Offset(76.624 * dim, 30.694000000000003 * dim), radius: radius5, rotation: 0, largeArc: false, clockwise: true);
    path2.close();

    final path3 = Path();
    path3.moveTo(24.305 * dim, 6.96 * dim);
    path3.lineTo(48.35 * dim, 31.004 * dim);
    path3.arcToPoint(Offset(48.35 * dim, 35.121 * dim), radius: radius, rotation: 0, largeArc: false, clockwise: true);
    path3.lineTo(31.882 * dim, 51.588 * dim);
    path3.arcToPoint(Offset(27.765 * dim, 51.588 * dim), radius: radius, rotation: 0, largeArc: false, clockwise: true);
    path3.lineTo(17.084 * dim, 40.907 * dim);
    path3.arcToPoint(Offset(17.084 * dim, 8.75 * dim), radius: Radius.elliptical(22.738 * dim, 22.738 * dim), rotation: 0, largeArc: false, clockwise: true);
    path3.lineTo(18.874 * dim, 6.96 * dim);
    path3.arcToPoint(Offset(24.305 * dim, 6.96 * dim), radius: Radius.elliptical(3.84 * dim, 3.84 * dim), rotation: 0, largeArc: false, clockwise: true);
    path3.close();

    canvas.drawPath(
        path0,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xffef435a));

    canvas.drawPath(
        path1,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xffe0e0e0));

    canvas.drawPath(
        path2,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xffffc11f));

    canvas.drawPath(
        path3,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xff1cc8eb));

    // stroke should be painted over fill
    canvas.drawPath(path0, strokePaint);
    canvas.drawPath(path1, strokePaint);
    canvas.drawPath(path2, strokePaint);
    canvas.drawPath(path3, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
