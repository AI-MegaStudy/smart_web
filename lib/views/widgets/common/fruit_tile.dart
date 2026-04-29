import 'package:flutter/material.dart';

enum FruitIllustration {
  apple,
  appleDuo,
  pear,
  pearCluster,
}

class FruitTile extends StatelessWidget {
  const FruitTile({
    super.key,
    required this.illustration,
  });

  final FruitIllustration illustration;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF2F7EC),
            Color(0xFFE9EFE0),
          ],
        ),
      ),
      child: CustomPaint(
        painter: FruitIllustrationPainter(illustration),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class FruitHeroCard extends StatelessWidget {
  const FruitHeroCard({
    super.key,
    required this.illustration,
  });

  final FruitIllustration illustration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF2F7EC),
            Color(0xFFE5ECDB),
          ],
        ),
      ),
      child: CustomPaint(
        painter: FruitIllustrationPainter(illustration, hero: true),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class FruitIllustrationPainter extends CustomPainter {
  FruitIllustrationPainter(this.type, {this.hero = false});

  final FruitIllustration type;
  final bool hero;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundDots = Paint()..color = const Color(0xFFDCE8D1);
    for (final offset in [
      Offset(size.width * 0.12, size.height * 0.14),
      Offset(size.width * 0.21, size.height * 0.36),
      Offset(size.width * 0.42, size.height * 0.21),
      Offset(size.width * 0.77, size.height * 0.35),
      Offset(size.width * 0.84, size.height * 0.18),
      Offset(size.width * 0.62, size.height * 0.52),
    ]) {
      canvas.drawCircle(offset, hero ? 4 : 3, backgroundDots);
    }

    switch (type) {
      case FruitIllustration.apple:
        _drawApple(canvas, size, const Offset(0, 0), hero ? 1.3 : 1);
      case FruitIllustration.appleDuo:
        _drawApple(canvas, size, Offset(-size.width * 0.1, 0), hero ? 1.1 : 0.82);
        _drawApple(
          canvas,
          size,
          Offset(size.width * 0.16, size.height * 0.02),
          hero ? 1.08 : 0.82,
          bodyColor: const Color(0xFFE07546),
        );
      case FruitIllustration.pear:
        _drawPear(canvas, size, const Offset(0, 0), hero ? 1.2 : 1);
      case FruitIllustration.pearCluster:
        _drawPear(canvas, size, Offset(-size.width * 0.14, size.height * 0.02), hero ? 1.05 : 0.84);
        _drawPear(canvas, size, Offset(size.width * 0.1, size.height * 0.08), hero ? 0.95 : 0.75);
    }
  }

  void _drawApple(
    Canvas canvas,
    Size size,
    Offset delta,
    double scale, {
    Color bodyColor = const Color(0xFFE1513D),
  }) {
    final applePaint = Paint()..color = bodyColor;
    final appleRectLeft = Rect.fromCenter(
      center: Offset(size.width * 0.43 + delta.dx, size.height * 0.58 + delta.dy),
      width: size.width * 0.27 * scale,
      height: size.height * 0.34 * scale,
    );
    final appleRectRight = Rect.fromCenter(
      center: Offset(size.width * 0.58 + delta.dx, size.height * 0.58 + delta.dy),
      width: size.width * 0.27 * scale,
      height: size.height * 0.34 * scale,
    );
    canvas.drawOval(appleRectLeft, applePaint);
    canvas.drawOval(appleRectRight, applePaint);

    final stemPaint = Paint()
      ..color = const Color(0xFF6F4C32)
      ..strokeWidth = 10 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.53 + delta.dx, size.height * 0.34 + delta.dy),
      Offset(size.width * 0.54 + delta.dx, size.height * 0.2 + delta.dy),
      stemPaint,
    );

    final leafPaint = Paint()..color = const Color(0xFF61B05A);
    final leafRect = Rect.fromCenter(
      center: Offset(size.width * 0.61 + delta.dx, size.height * 0.2 + delta.dy),
      width: size.width * 0.12 * scale,
      height: size.height * 0.08 * scale,
    );
    canvas.drawOval(leafRect, leafPaint);

    final shine = Paint()..color = const Color(0xFFFFA28D);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.46 + delta.dx, size.height * 0.5 + delta.dy),
        width: size.width * 0.07 * scale,
        height: size.height * 0.05 * scale,
      ),
      shine,
    );
  }

  void _drawPear(Canvas canvas, Size size, Offset delta, double scale) {
    final pearPaint = Paint()..color = const Color(0xFFE2CF62);
    final bottom = Rect.fromCenter(
      center: Offset(size.width * 0.5 + delta.dx, size.height * 0.63 + delta.dy),
      width: size.width * 0.34 * scale,
      height: size.height * 0.28 * scale,
    );
    final top = Rect.fromCenter(
      center: Offset(size.width * 0.5 + delta.dx, size.height * 0.46 + delta.dy),
      width: size.width * 0.2 * scale,
      height: size.height * 0.22 * scale,
    );
    canvas.drawOval(bottom, pearPaint);
    canvas.drawOval(top, pearPaint);

    final stemPaint = Paint()
      ..color = const Color(0xFF8A6535)
      ..strokeWidth = 9 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.52 + delta.dx, size.height * 0.34 + delta.dy),
      Offset(size.width * 0.52 + delta.dx, size.height * 0.24 + delta.dy),
      stemPaint,
    );

    final leafPaint = Paint()..color = const Color(0xFF61B05A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.59 + delta.dx, size.height * 0.26 + delta.dy),
        width: size.width * 0.1 * scale,
        height: size.height * 0.07 * scale,
      ),
      leafPaint,
    );
  }

  @override
  bool shouldRepaint(covariant FruitIllustrationPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.hero != hero;
  }
}

String formatPrice(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final indexFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}

String formatKg(double kg) {
  if (kg == kg.roundToDouble()) {
    return kg.toStringAsFixed(0);
  }
  return kg.toStringAsFixed(1);
}
