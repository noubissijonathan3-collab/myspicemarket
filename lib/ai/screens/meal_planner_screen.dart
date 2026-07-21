import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../l10n/app_localizations.dart';
import '../providers/shopping_provider.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final _familySizeController = TextEditingController(text: '2');
  final _budgetController = TextEditingController();
  final _preferencesController = TextEditingController();
  bool _generating = false;

  @override
  void dispose() {
    _familySizeController.dispose();
    _budgetController.dispose();
    _preferencesController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final familySize = int.tryParse(_familySizeController.text) ?? 2;
    final budget = double.tryParse(_budgetController.text) ?? 0;
    final preferences = _preferencesController.text.isNotEmpty
        ? _preferencesController.text.split(',').map((e) => e.trim()).toList()
        : <String>[];

    setState(() => _generating = true);

    await context.read<ShoppingProvider>().generateWeeklyPlan(
      familySize: familySize,
      budget: budget,
      preferences: preferences,
    );

    setState(() => _generating = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plan = context.watch<ShoppingProvider>().weeklyPlan;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.t('mealPlanner')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: plan == null ? _buildForm() : _buildPlan(plan),
    );
  }

  Widget _buildForm() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.t('planYourMeals'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.t('planYourMealsDesc'), style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          TextField(
            controller: _familySizeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.t('familySize'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.t('weeklyBudgetFCFA'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _preferencesController,
            decoration: InputDecoration(
              labelText: l10n.t('dietaryPreferences'),
              hintText: l10n.t('dietaryPreferencesHint'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generating ? null : _generate,
              icon: _generating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
              label: Text(_generating ? l10n.t('generating') : l10n.t('generateMealPlan')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlan(dynamic plan) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.t('weeklyPlan'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface))),
              TextButton(onPressed: () => context.read<ShoppingProvider>().clear(), child: Text(l10n.t('newPlan'))),
            ],
          ),
          const SizedBox(height: 8),
          if (plan.budget > 0)
            Text('${l10n.t('budget')}: ${plan.budget.toStringAsFixed(0)} FCFA', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          ...plan.days.map((day) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day.day, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  ...day.meals.map((m) => Text('• ${m.name} (${m.servings} servings)', style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          )),
          const SizedBox(height: 16),
          Text(l10n.t('shoppingList'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          const SizedBox(height: 8),
          ...plan.shoppingList.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: [
              const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('${item.name} (${item.quantity} ${item.unit})', style: const TextStyle(fontSize: 13)),
            ]),
          )),
        ],
      ),
    );
  }
}
