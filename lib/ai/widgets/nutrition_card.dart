import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../models/nutrition_analysis.dart';

class NutritionCard extends StatelessWidget {
  final NutritionAnalysis analysis;

  const NutritionCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    if (analysis.suggestion.isNotEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.health_and_safety, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('Nutrition Advice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 12),
              Text(analysis.suggestion, style: const TextStyle(fontSize: 14, height: 1.5)),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.restaurant, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(analysis.meal, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 16),
            if (analysis.calories > 0) ...[
              _nutrientRow('Calories', '${analysis.calories} kcal', Icons.local_fire_department, Colors.orange),
              const Divider(height: 20),
            ],
            if (analysis.protein.isNotEmpty) ...[
              _nutrientRow('Protein', analysis.protein, Icons.fitness_center, Colors.red),
              const Divider(height: 20),
            ],
            if (analysis.carbs.isNotEmpty) ...[
              _nutrientRow('Carbohydrates', analysis.carbs, Icons.grain, Colors.amber),
              const Divider(height: 20),
            ],
            if (analysis.fat.isNotEmpty) ...[
              _nutrientRow('Fat', analysis.fat, Icons.opacity, Colors.blue),
              const Divider(height: 20),
            ],
            if (analysis.fiber.isNotEmpty) ...[
              _nutrientRow('Fiber', analysis.fiber, Icons.eco, Colors.green),
              const SizedBox(height: 12),
            ],
            if (analysis.summary.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(analysis.summary, style: TextStyle(fontSize: 13, color: AppColors.onSurface, height: 1.4)),
              ),
            ],
            if (analysis.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(analysis.note, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _nutrientRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
