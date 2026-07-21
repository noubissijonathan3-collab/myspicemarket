import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../l10n/app_localizations.dart';
import '../providers/voice_provider.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _processText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    context.read<VoiceProvider>().processCommand(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.t('voiceAssistant')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<VoiceProvider>(
        builder: (_, provider, _) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: provider.lastCommand != null
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                provider.lastCommand!.intent == 'unknown' ? Icons.help_outline : Icons.check_circle,
                                size: 48,
                                color: provider.lastCommand!.intent == 'unknown' ? Colors.orange : AppColors.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                provider.lastCommand!.response,
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              if (provider.lastCommand!.product.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Chip(label: Text(provider.lastCommand!.product)),
                              ],
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () => provider.clear(),
                                icon: const Icon(Icons.refresh),
                                label: Text(l10n.t('tryAgain')),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mic, size: 80, color: AppColors.primary.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text(l10n.t('typeCommand'), style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(l10n.t('commandExamples'), style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          ],
                        ),
                ),
              ),
              if (provider.isProcessing)
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
                      IconButton(
                        icon: Icon(Icons.mic, color: AppColors.primary, size: 28),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _textController,
                            textInputAction: TextInputAction.send,
                            decoration: InputDecoration(
                              hintText: l10n.t('voiceHint'),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onSubmitted: (_) => _processText(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send_rounded, color: AppColors.primary),
                        onPressed: _processText,
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
