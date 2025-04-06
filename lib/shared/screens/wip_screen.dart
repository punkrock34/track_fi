import 'package:flutter/material.dart';
import 'package:trackfi/app/theme/theme_extensions.dart';

class WorkInProgressScreen extends StatelessWidget {
  final String label;
  final String subtitle;

  const WorkInProgressScreen({
    super.key,
    this.label = 'Work In Progress',
    this.subtitle = 'This feature is still cooking.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.backgroundGradientStart, theme.backgroundGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(
                size: Size(size.width * 0.4, size.width * 0.4),
                painter: _TrianglePainter(color: Colors.white.withAlpha((0.05 * 255).round())),
              ),
              const SizedBox(height: 40),
              Icon(
                Icons.construction,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha((0.7 * 255).round()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
