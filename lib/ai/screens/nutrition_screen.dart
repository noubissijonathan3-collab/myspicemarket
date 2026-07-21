import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../l10n/app_localizations.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/nutrition_card.dart';

class NutritionScreen extends StatefulWidget {
  final String? mealId;

  const NutritionScreen({super.key, this.mealId});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<NutritionProvider>().analyze(mealId: widget.mealId, query: text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.t('nutritionAdvisor')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<NutritionProvider>(
        builder: (_, provider, _) {
          return Column(
            children: [
              Expanded(child: _buildContent(provider)),
              _buildInputBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(NutritionProvider provider) {
    final l10n = AppLocalizations.of(context);
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.analysis != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: NutritionCard(analysis: provider.analysis!),
      );
    }

    if (widget.mealId != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(l10n.t('askNutrition')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<NutritionProvider>().analyze(mealId: widget.mealId),
              child: Text(l10n.t('askNutrition')),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.health_and_safety, size: 60, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(l10n.t('askNutrition'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          const SizedBox(height: 8),
          Text(l10n.t('nutritionHint'), style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: l10n.t('askNutritionHint'),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) => _analyze(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search, color: AppColors.primary),
              onPressed: _analyze,
            ),
          ],
        ),
      ),
    );
  }
}
