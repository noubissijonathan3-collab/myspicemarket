import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../l10n/app_localizations.dart';
import '../providers/ai_provider.dart';
import '../widgets/recipe_card.dart';

class RecipeGeneratorScreen extends StatefulWidget {
  const RecipeGeneratorScreen({super.key});

  @override
  State<RecipeGeneratorScreen> createState() => _RecipeGeneratorScreenState();
}

class _RecipeGeneratorScreenState extends State<RecipeGeneratorScreen> {
  final _ingredientsController = TextEditingController();

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  void _generate() {
    final text = _ingredientsController.text.trim();
    if (text.isEmpty) return;
    context.read<AiProvider>().sendMessage(
      'Suggest a recipe using these ingredients: $text',
      context: 'cooking',
    );
    _ingredientsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.t('recipeGenerator')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AiProvider>(
        builder: (_, provider, _) {
          return Column(
            children: [
              if (provider.messages.isNotEmpty)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: provider.messages.map((m) {
                      if (m.role == 'assistant') {
                        return RecipeCard(recipe: m.content);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(m.content, style: const TextStyle(fontSize: 14)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book, size: 60, color: AppColors.primary.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(l10n.t('whatIngredients'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(l10n.t('enterIngredients'), style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ),
              if (provider.isLoading)
                const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
              Container(
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
                            controller: _ingredientsController,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.send,
                            decoration: InputDecoration(
                              hintText: l10n.t('recipeHint'),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onSubmitted: (_) => _generate(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.auto_awesome, color: AppColors.primary),
                        onPressed: _generate,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
