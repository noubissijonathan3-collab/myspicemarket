import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../l10n/app_localizations.dart';
import '../providers/shopping_provider.dart';
import '../widgets/budget_card.dart';

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _plan() async {
    final budget = double.tryParse(_controller.text);
    if (budget == null || budget <= 0) return;
    await context.read<ShoppingProvider>().planBudget(budget);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ShoppingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.t('budgetPlanner')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.budgetPlan == null ? _buildForm() : _buildResult(provider),
    );
  }

  Widget _buildForm() {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ShoppingProvider>();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance_wallet, size: 50, color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(l10n.t('enterBudget'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.t('budgetDesc'), style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.t('budgetPlan'),
              prefixText: 'FCFA ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.isLoading ? null : _plan,
              icon: provider.isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
              label: Text(provider.isLoading ? l10n.t('planning') : l10n.t('planMeals')),
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

  Widget _buildResult(ShoppingProvider provider) {
    final l10n = AppLocalizations.of(context);
    final plan = provider.budgetPlan!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.t('budgetPlan'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface))),
              TextButton(onPressed: () => provider.clear(), child: Text(l10n.t('newPlan'))),
            ],
          ),
          const SizedBox(height: 8),
          BudgetCard(plan: plan),
        ],
      ),
    );
  }
}
