class VoiceCommand {
  final String intent;
  final String product;
  final String query;
  final List<String> ingredients;
  final String response;

  VoiceCommand({
    this.intent = '',
    this.product = '',
    this.query = '',
    this.ingredients = const [],
    this.response = '',
  });

  factory VoiceCommand.fromJson(Map<String, dynamic> json) => VoiceCommand(
    intent: json['intent'] ?? '',
    product: json['product'] ?? '',
    query: json['query'] ?? '',
    ingredients: List<String>.from(json['ingredients'] ?? []),
    response: json['response'] ?? '',
  );
}
