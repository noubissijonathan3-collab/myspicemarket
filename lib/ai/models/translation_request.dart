class TranslationRequest {
  final String text;
  final String targetLanguage;
  final String sourceLanguage;
  final String contextType;

  TranslationRequest({
    required this.text,
    required this.targetLanguage,
    this.sourceLanguage = 'en',
    this.contextType = 'meal',
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'targetLanguage': targetLanguage,
    'sourceLanguage': sourceLanguage,
    'contextType': contextType,
  };
}

class TranslationResponse {
  final String translatedText;

  TranslationResponse({required this.translatedText});

  factory TranslationResponse.fromJson(Map<String, dynamic> json) => TranslationResponse(
    translatedText: json['translatedText'] ?? '',
  );
}
