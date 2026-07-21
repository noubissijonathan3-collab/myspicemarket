class AccessibilitySettingsModel {
  final bool voiceCommands;
  final bool speechResponses;
  final String speechRecognitionLanguage;
  final double fontScaling;
  final bool screenReader;
  final bool hapticFeedback;
  final String buttonSize;
  final bool colorAccessibility;
  final bool simplifiedNavigation;

  AccessibilitySettingsModel({
    this.voiceCommands = false,
    this.speechResponses = false,
    this.speechRecognitionLanguage = 'en-US',
    this.fontScaling = 1.0,
    this.screenReader = false,
    this.hapticFeedback = true,
    this.buttonSize = 'normal',
    this.colorAccessibility = false,
    this.simplifiedNavigation = false,
  });

  factory AccessibilitySettingsModel.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettingsModel(
      voiceCommands: json['voiceCommands'] ?? false,
      speechResponses: json['speechResponses'] ?? false,
      speechRecognitionLanguage: json['speechRecognitionLanguage'] ?? 'en-US',
      fontScaling: (json['fontScaling'] ?? 1.0).toDouble(),
      screenReader: json['screenReader'] ?? false,
      hapticFeedback: json['hapticFeedback'] ?? true,
      buttonSize: json['buttonSize'] ?? 'normal',
      colorAccessibility: json['colorAccessibility'] ?? false,
      simplifiedNavigation: json['simplifiedNavigation'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'voiceCommands': voiceCommands,
    'speechResponses': speechResponses,
    'speechRecognitionLanguage': speechRecognitionLanguage,
    'fontScaling': fontScaling,
    'screenReader': screenReader,
    'hapticFeedback': hapticFeedback,
    'buttonSize': buttonSize,
    'colorAccessibility': colorAccessibility,
    'simplifiedNavigation': simplifiedNavigation,
  };

  AccessibilitySettingsModel copyWith({
    bool? voiceCommands,
    bool? speechResponses,
    String? speechRecognitionLanguage,
    double? fontScaling,
    bool? screenReader,
    bool? hapticFeedback,
    String? buttonSize,
    bool? colorAccessibility,
    bool? simplifiedNavigation,
  }) {
    return AccessibilitySettingsModel(
      voiceCommands: voiceCommands ?? this.voiceCommands,
      speechResponses: speechResponses ?? this.speechResponses,
      speechRecognitionLanguage: speechRecognitionLanguage ?? this.speechRecognitionLanguage,
      fontScaling: fontScaling ?? this.fontScaling,
      screenReader: screenReader ?? this.screenReader,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      buttonSize: buttonSize ?? this.buttonSize,
      colorAccessibility: colorAccessibility ?? this.colorAccessibility,
      simplifiedNavigation: simplifiedNavigation ?? this.simplifiedNavigation,
    );
  }
}
