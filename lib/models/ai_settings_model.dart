class AiSettingsModel {
  final bool cookingAssistant;
  final bool smartSearch;
  final bool recommendations;
  final bool ingredientSubstitutes;
  final bool budgetPlanner;
  final bool weeklyPlanner;
  final bool nutritionAdvisor;
  final bool voiceAssistant;
  final bool shoppingChatbot;
  final bool useOrderHistory;
  final bool useFavorites;
  final bool useBrowsing;
  final bool useSearchHistory;
  final String responseLanguage;
  final String responseLength;
  final bool voiceResponses;

  AiSettingsModel({
    this.cookingAssistant = true,
    this.smartSearch = true,
    this.recommendations = true,
    this.ingredientSubstitutes = true,
    this.budgetPlanner = true,
    this.weeklyPlanner = true,
    this.nutritionAdvisor = true,
    this.voiceAssistant = false,
    this.shoppingChatbot = true,
    this.useOrderHistory = true,
    this.useFavorites = true,
    this.useBrowsing = true,
    this.useSearchHistory = true,
    this.responseLanguage = 'english',
    this.responseLength = 'medium',
    this.voiceResponses = false,
  });

  factory AiSettingsModel.fromJson(Map<String, dynamic> json) {
    return AiSettingsModel(
      cookingAssistant: json['cookingAssistant'] ?? true,
      smartSearch: json['smartSearch'] ?? true,
      recommendations: json['recommendations'] ?? true,
      ingredientSubstitutes: json['ingredientSubstitutes'] ?? true,
      budgetPlanner: json['budgetPlanner'] ?? true,
      weeklyPlanner: json['weeklyPlanner'] ?? true,
      nutritionAdvisor: json['nutritionAdvisor'] ?? true,
      voiceAssistant: json['voiceAssistant'] ?? false,
      shoppingChatbot: json['shoppingChatbot'] ?? true,
      useOrderHistory: json['useOrderHistory'] ?? true,
      useFavorites: json['useFavorites'] ?? true,
      useBrowsing: json['useBrowsing'] ?? true,
      useSearchHistory: json['useSearchHistory'] ?? true,
      responseLanguage: json['responseLanguage'] ?? 'english',
      responseLength: json['responseLength'] ?? 'medium',
      voiceResponses: json['voiceResponses'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'cookingAssistant': cookingAssistant,
    'smartSearch': smartSearch,
    'recommendations': recommendations,
    'ingredientSubstitutes': ingredientSubstitutes,
    'budgetPlanner': budgetPlanner,
    'weeklyPlanner': weeklyPlanner,
    'nutritionAdvisor': nutritionAdvisor,
    'voiceAssistant': voiceAssistant,
    'shoppingChatbot': shoppingChatbot,
    'useOrderHistory': useOrderHistory,
    'useFavorites': useFavorites,
    'useBrowsing': useBrowsing,
    'useSearchHistory': useSearchHistory,
    'responseLanguage': responseLanguage,
    'responseLength': responseLength,
    'voiceResponses': voiceResponses,
  };

  AiSettingsModel copyWith({
    bool? cookingAssistant,
    bool? smartSearch,
    bool? recommendations,
    bool? ingredientSubstitutes,
    bool? budgetPlanner,
    bool? weeklyPlanner,
    bool? nutritionAdvisor,
    bool? voiceAssistant,
    bool? shoppingChatbot,
    bool? useOrderHistory,
    bool? useFavorites,
    bool? useBrowsing,
    bool? useSearchHistory,
    String? responseLanguage,
    String? responseLength,
    bool? voiceResponses,
  }) {
    return AiSettingsModel(
      cookingAssistant: cookingAssistant ?? this.cookingAssistant,
      smartSearch: smartSearch ?? this.smartSearch,
      recommendations: recommendations ?? this.recommendations,
      ingredientSubstitutes: ingredientSubstitutes ?? this.ingredientSubstitutes,
      budgetPlanner: budgetPlanner ?? this.budgetPlanner,
      weeklyPlanner: weeklyPlanner ?? this.weeklyPlanner,
      nutritionAdvisor: nutritionAdvisor ?? this.nutritionAdvisor,
      voiceAssistant: voiceAssistant ?? this.voiceAssistant,
      shoppingChatbot: shoppingChatbot ?? this.shoppingChatbot,
      useOrderHistory: useOrderHistory ?? this.useOrderHistory,
      useFavorites: useFavorites ?? this.useFavorites,
      useBrowsing: useBrowsing ?? this.useBrowsing,
      useSearchHistory: useSearchHistory ?? this.useSearchHistory,
      responseLanguage: responseLanguage ?? this.responseLanguage,
      responseLength: responseLength ?? this.responseLength,
      voiceResponses: voiceResponses ?? this.voiceResponses,
    );
  }
}
