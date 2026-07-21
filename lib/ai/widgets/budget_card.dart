import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../models/shopping_plan.dart';

class BudgetCard extends StatelessWidget {
  final BudgetPlan plan;

  const BudgetCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Budget', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text('${plan.budget.toStringAsFixed(0)} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Cost', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text('${plan.totalCost.toStringAsFixed(0)} FCFA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Savings', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text('${plan.savings.toStringAsFixed(0)} FCFA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...plan.recommendations.map((rec) => Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            leading: Icon(Icons.restaurant, color: AppColors.primary),
            title: Text(rec.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(rec.reason, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            trailing: Text('${rec.price.toStringAsFixed(0)} FCFA', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        )),
      ],
    );
  }
}
