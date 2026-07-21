class IngredientSubstitute {
  final String name;
  final String reason;

  IngredientSubstitute({required this.name, this.reason = ''});

  factory IngredientSubstitute.fromJson(Map<String, dynamic> json) => IngredientSubstitute(
    name: json['name'] ?? '',
    reason: json['reason'] ?? '',
  );
}
