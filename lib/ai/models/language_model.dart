class Language {
  final String code;
  final String name;
  final String nativeName;

  Language({required this.code, required this.name, required this.nativeName});

  factory Language.fromJson(Map<String, dynamic> json) => Language(
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    nativeName: json['native'] ?? json['nativeName'] ?? '',
  );
}

class AppLanguage {
  final String code;
  final bool translateDynamicContent;
  final bool translateChat;

  AppLanguage({
    this.code = 'en',
    this.translateDynamicContent = false,
    this.translateChat = false,
  });

  String get displayName {
    const names = {
      'en': 'English', 'fr': 'Français', 'es': 'Español', 'de': 'Deutsch',
      'it': 'Italiano', 'pt': 'Português', 'ar': 'العربية', 'zh': '中文',
      'ja': '日本語', 'ko': '한국어', 'hi': 'हिन्दी', 'ru': 'Русский',
    };
    return names[code] ?? code;
  }
}
