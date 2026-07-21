class ThemeModel {
  final String mode;
  final String fontSize;
  final String layout;
  final bool highContrast;
  final String animationIntensity;
  final bool bannerAutoplay;

  ThemeModel({
    this.mode = 'system',
    this.fontSize = 'medium',
    this.layout = 'comfortable',
    this.highContrast = false,
    this.animationIntensity = 'medium',
    this.bannerAutoplay = true,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      mode: json['mode'] ?? 'system',
      fontSize: json['fontSize'] ?? 'medium',
      layout: json['layout'] ?? 'comfortable',
      highContrast: json['highContrast'] ?? false,
      animationIntensity: json['animationIntensity'] ?? 'medium',
      bannerAutoplay: json['bannerAutoplay'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'mode': mode,
    'fontSize': fontSize,
    'layout': layout,
    'highContrast': highContrast,
    'animationIntensity': animationIntensity,
    'bannerAutoplay': bannerAutoplay,
  };

  ThemeModel copyWith({
    String? mode,
    String? fontSize,
    String? layout,
    bool? highContrast,
    String? animationIntensity,
    bool? bannerAutoplay,
  }) {
    return ThemeModel(
      mode: mode ?? this.mode,
      fontSize: fontSize ?? this.fontSize,
      layout: layout ?? this.layout,
      highContrast: highContrast ?? this.highContrast,
      animationIntensity: animationIntensity ?? this.animationIntensity,
      bannerAutoplay: bannerAutoplay ?? this.bannerAutoplay,
    );
  }
}
