import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 空状態に出すイラスト。棚に並んだ貯金箱。
///
/// 外部素材を使わず図形で描くことで、テーマのトークン色をそのまま使える。
/// 装飾なので、スクリーンリーダーからは除外する。
class VaultIllustration extends StatelessWidget {
  const VaultIllustration({super.key, this.size = 240});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size * 0.8,
        child: CustomPaint(painter: _VaultShelfPainter()),
      ),
    );
  }
}

class _VaultShelfPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final sun = Paint()..color = AppColors.primaryLight;
    final jarFill = Paint()..color = AppColors.surface;
    final jarStroke = Paint()
      ..color = AppColors.heroSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012;
    final coinPaint = Paint()..color = AppColors.primary;
    final shelfPaint = Paint()..color = AppColors.heroSurface;
    final leafPaint = Paint()..color = AppColors.secondary;

    // 背景の太陽
    canvas.drawCircle(Offset(w * 0.74, h * 0.2), w * 0.15, sun);

    final shelfY = h * 0.78;

    // 貯金箱3つ。高さと中身の量を変えて、貯まり具合の違いを見せる。
    _jar(
      canvas,
      center: Offset(w * 0.26, shelfY),
      width: w * 0.2,
      height: h * 0.34,
      fillRatio: 0.75,
      fill: jarFill,
      stroke: jarStroke,
      coin: coinPaint,
    );
    _jar(
      canvas,
      center: Offset(w * 0.5, shelfY),
      width: w * 0.23,
      height: h * 0.46,
      fillRatio: 0.45,
      fill: jarFill,
      stroke: jarStroke,
      coin: coinPaint,
    );
    _jar(
      canvas,
      center: Offset(w * 0.75, shelfY),
      width: w * 0.18,
      height: h * 0.28,
      fillRatio: 0.2,
      fill: jarFill,
      stroke: jarStroke,
      coin: coinPaint,
    );

    // 棚板
    final shelf = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.1, shelfY, w * 0.8, h * 0.035),
      Radius.circular(h * 0.02),
    );
    canvas.drawRRect(shelf, shelfPaint);

    // 棚の上の小さな葉（生活感）
    final leaf = Path()
      ..moveTo(w * 0.88, shelfY)
      ..quadraticBezierTo(w * 0.95, shelfY - h * 0.1, w * 0.9, shelfY - h * 0.16)
      ..quadraticBezierTo(w * 0.84, shelfY - h * 0.08, w * 0.88, shelfY);
    canvas.drawPath(leaf, leafPaint);
  }

  /// 瓶ひとつ。[fillRatio] のぶんだけコインが溜まっている。
  void _jar(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double height,
    required double fillRatio,
    required Paint fill,
    required Paint stroke,
    required Paint coin,
  }) {
    final left = center.dx - width / 2;
    final top = center.dy - height;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, width, height),
      Radius.circular(width * 0.22),
    );

    canvas.drawRRect(body, fill);

    // 中身（下から fillRatio ぶん）
    if (fillRatio > 0) {
      canvas.save();
      canvas.clipRRect(body);
      final fillHeight = height * fillRatio;
      canvas.drawRect(
        Rect.fromLTWH(left, top + height - fillHeight, width, fillHeight),
        coin,
      );
      canvas.restore();
    }

    canvas.drawRRect(body, stroke);

    // ふた
    final lid = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        left + width * 0.12,
        top - height * 0.09,
        width * 0.76,
        height * 0.1,
      ),
      Radius.circular(width * 0.08),
    );
    canvas.drawRRect(lid, Paint()..color = AppColors.heroSurface);

    // コイン投入口
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx - width * 0.16,
          top - height * 0.055,
          width * 0.32,
          height * 0.016,
        ),
        Radius.circular(width * 0.02),
      ),
      Paint()..color = AppColors.primaryLight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
