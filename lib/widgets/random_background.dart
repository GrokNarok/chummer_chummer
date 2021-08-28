import 'dart:math';

import 'package:flutter/widgets.dart';

class RandomBackground extends CustomPainter {
  final Color backgroundColor;
  final Color patternColor;
  final int randomSeed;

  RandomBackground({
    required this.backgroundColor,
    required this.patternColor,
    this.randomSeed = 126,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final numPixels = (size.width * size.height).floor();
    if (numPixels == 0) return;

    final rng = Random(numPixels);

    // Background
    canvas.drawColor(backgroundColor, BlendMode.color);

    // Big dark blobs
    final numBlobs = (numPixels / 3000).floor();
    for (var i = 0; i < (numBlobs * 0.75).floor() + rng.nextInt((numBlobs * 0.25).floor()); i++) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = patternColor.withAlpha(128);

      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = patternColor;

      final width = min(rng.nextDouble(), rng.nextDouble()) * 175 + 25;
      final height = min(rng.nextDouble(), rng.nextDouble()) * 270 + 30;
      final left = rng.nextDouble() * (size.width + width) - width;
      final top = rng.nextDouble() * (size.height + height) - height;
      final rect = Rect.fromLTWH(left, top, width, height);
      canvas.drawRect(rect, strokePaint);
      canvas.drawRect(rect, fillPaint);
    }

    // Smaller light "holes"
    final numGaps = (numPixels / 500).floor();
    for (var i = 0; i < (numGaps * 0.75).floor() + rng.nextInt((numGaps * 0.25).floor()); i++) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = backgroundColor.withAlpha(128);

      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = backgroundColor;

      final width = min(rng.nextDouble(), rng.nextDouble()) * 45 + 5;
      final height = min(rng.nextDouble(), rng.nextDouble()) * 27 + 3;
      final left = rng.nextDouble() * (size.width + width) - width;
      final top = rng.nextDouble() * (size.height + height) - height;
      final rect = Rect.fromLTWH(left, top, width, height);
      canvas.drawRect(rect, strokePaint);
      canvas.drawRect(rect, fillPaint);
    }

    // Horizontal lines
    for (var i = 0.0; i < size.height; i += 8 + rng.nextInt(1)) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = patternColor.withAlpha(128);

      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = patternColor;

      final rect = Rect.fromLTWH(0, i, size.width, 2.0 + rng.nextInt(2));
      canvas.drawRect(rect, strokePaint);
      canvas.drawRect(rect, fillPaint);
    }
  }

  @override
  bool shouldRepaint(RandomBackground oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor || patternColor != oldDelegate.patternColor || randomSeed != oldDelegate.randomSeed;
}
