import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../l10n/app_localizations.dart';
import '../providers/translation_provider.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TranslationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.t('languageSettings')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.t('appLanguage'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(l10n.t('appLanguageDesc'), style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        const SizedBox(height: 12),
                        // ignore: deprecated_member_use
                        RadioGroup<String>(
                          groupValue: provider.currentLanguage,
                          onChanged: (v) {
                            if (v != null) provider.setLanguage(v);
                          },
                          child: Column(
                            children: provider.languages.map((lang) => RadioListTile<String>(
                              title: Text('${lang.nativeName} (${lang.name})'),
                              value: lang.code,
                              dense: true,
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.t('contentTranslation'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(l10n.t('contentTranslationDesc'), style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        SwitchListTile(
                          title: Text(l10n.t('translateDynamicContent')),
                          subtitle: Text(l10n.t('translateDynamicContentSub'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          value: provider.translateDynamicContent,
                          onChanged: (v) => provider.setTranslateContent(v),
                          activeThumbColor: AppColors.primary,
                        ),
                        SwitchListTile(
                          title: Text(l10n.t('translateLiveChat')),
                          subtitle: Text(l10n.t('translateLiveChatSub'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          value: provider.translateChat,
                          onChanged: (v) => provider.setTranslateChat(v),
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.t('howTranslationWorks'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _tipRow(Icons.language, l10n.t('staticUI'), l10n.t('staticUIDesc')),
                        const SizedBox(height: 8),
                        _tipRow(Icons.auto_awesome, l10n.t('dynamicContent'), l10n.t('dynamicContentDesc')),
                        const SizedBox(height: 8),
                        _tipRow(Icons.chat, l10n.t('liveChat'), l10n.t('liveChatDesc')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _tipRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ])),
      ],
    );
  }
}
