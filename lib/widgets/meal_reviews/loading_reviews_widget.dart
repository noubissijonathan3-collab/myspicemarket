import 'package:flutter/material.dart';

class LoadingReviewsWidget extends StatelessWidget {
  const LoadingReviewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, _) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBox(36, 36, 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(14, 120, 14),
                    const SizedBox(height: 6),
                    _shimmerBox(10, 80, 10),
                  ],
                ),
              ),
              _shimmerBox(12, 60, 12),
            ],
          ),
          const SizedBox(height: 12),
          _shimmerBox(12, double.infinity, 12),
          const SizedBox(height: 8),
          _shimmerBox(12, double.infinity, 12),
          const SizedBox(height: 8),
          _shimmerBox(12, 180, 12),
        ],
      ),
    );
  }

  Widget _shimmerBox(double height, double width, double borderRadius) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
