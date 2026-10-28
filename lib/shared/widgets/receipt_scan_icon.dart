import 'package:flutter/material.dart';

/// A scanning frame with a single horizontal scan line.
class ReceiptScanIcon extends StatelessWidget {
  const ReceiptScanIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _ScanFramePainter(
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );
}

class _ScanFramePainter extends CustomPainter {
  const _ScanFramePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final frame = Path()
      ..moveTo(3, 8)
      ..lineTo(3, 5)
      ..quadraticBezierTo(3, 3, 5, 3)
      ..lineTo(8, 3)
      ..moveTo(16, 3)
      ..lineTo(19, 3)
      ..quadraticBezierTo(21, 3, 21, 5)
      ..lineTo(21, 8)
      ..moveTo(21, 16)
      ..lineTo(21, 19)
      ..quadraticBezierTo(21, 21, 19, 21)
      ..lineTo(16, 21)
      ..moveTo(8, 21)
      ..lineTo(5, 21)
      ..quadraticBezierTo(3, 21, 3, 19)
      ..lineTo(3, 16)
      ..moveTo(7, 12)
      ..lineTo(17, 12);
    canvas.drawPath(frame, paint);
  }

  @override
  bool shouldRepaint(_ScanFramePainter oldDelegate) =>
      oldDelegate.color != color;
}
