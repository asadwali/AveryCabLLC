import 'package:flutter/material.dart';

class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _SkeletonCircle(size: 44, color: baseColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(
                        width: 140,
                        height: 14,
                        color: baseColor,
                      ),
                      const SizedBox(height: 8),
                      _SkeletonBox(
                        width: 200,
                        height: 12,
                        color: baseColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _SkeletonBox(
                  width: 70,
                  height: 28,
                  radius: 20,
                  color: baseColor,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Divider(color: highlightColor),

            const SizedBox(height: 16),

            // Info rows
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _SkeletonCircle(
                      size: 18,
                      color: baseColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SkeletonBox(
                        width: double.infinity,
                        height: 12,
                        color: baseColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _SkeletonBox(
                  width: 80,
                  height: 36,
                  radius: 10,
                  color: baseColor,
                ),
                const SizedBox(width: 8),
                _SkeletonBox(
                  width: 80,
                  height: 36,
                  radius: 10,
                  color: baseColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SkeletonCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
