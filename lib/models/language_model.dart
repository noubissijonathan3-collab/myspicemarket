class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final bool autoDetect;
  final bool translateDynamic;
  final bool translateChat;

  LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    this.autoDetect = true,
    this.translateDynamic = true,
    this.translateChat = false,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      nativeName: json['nativeName'] ?? '',
      autoDetect: json['autoDetect'] ?? true,
      translateDynamic: json['translateDynamic'] ?? true,
      translateChat: json['translateChat'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'nativeName': nativeName,
    'autoDetect': autoDetect,
    'translateDynamic': translateDynamic,
    'translateChat': translateChat,
  };

  LanguageModel copyWith({
    String? code,
    String? name,
    String? nativeName,
    bool? autoDetect,
    bool? translateDynamic,
    bool? translateChat,
  }) {
    return LanguageModel(
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      autoDetect: autoDetect ?? this.autoDetect,
      translateDynamic: translateDynamic ?? this.translateDynamic,
      translateChat: translateChat ?? this.translateChat,
    );
  }
}
