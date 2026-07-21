import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../providers/translation_provider.dart';

class LanguageSelector extends StatelessWidget {
  final bool compact;

  const LanguageSelector({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslationProvider>();
    final current = provider.languages.firstWhere(
      (l) => l.code == provider.currentLanguage,
      orElse: () => provider.languages.isNotEmpty ? provider.languages.first : (throw Exception('No languages')),
    );

    if (compact) {
      return GestureDetector(
        onTap: () => _showPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(current.nativeName, style: TextStyle(fontSize: 12, color: AppColors.onSurface)),
              Icon(Icons.arrow_drop_down, size: 16, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      );
    }

    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Language'),
      subtitle: Text(current.nativeName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showPicker(context),
    );
  }

  void _showPicker(BuildContext context) {
    final provider = context.read<TranslationProvider>();
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select Language'),
        children: [
          RadioGroup<String>(
            groupValue: provider.currentLanguage,
            onChanged: (v) {
              provider.setLanguage(v!);
              Navigator.pop(context);
            },
            child: Column(
              children: provider.languages.map((lang) => RadioListTile<String>(
                title: Text('${lang.nativeName} (${lang.name})'),
                value: lang.code,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
