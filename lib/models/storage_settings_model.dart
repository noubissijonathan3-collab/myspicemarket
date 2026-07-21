class StorageSettingsModel {
  final int cacheSize;
  final bool cacheImages;
  final bool wifiOnlyImages;
  final bool autoplayVideos;
  final bool cacheTranslations;
  final int downloadedBanners;
  final int offlineTranslations;

  StorageSettingsModel({
    this.cacheSize = 0,
    this.cacheImages = true,
    this.wifiOnlyImages = false,
    this.autoplayVideos = true,
    this.cacheTranslations = true,
    this.downloadedBanners = 0,
    this.offlineTranslations = 0,
  });

  String get formattedCacheSize {
    if (cacheSize < 1024) {
      return '$cacheSize B';
    } else if (cacheSize < 1024 * 1024) {
      return '${(cacheSize / 1024).toStringAsFixed(1)} KB';
    } else if (cacheSize < 1024 * 1024 * 1024) {
      return '${(cacheSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(cacheSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  factory StorageSettingsModel.fromJson(Map<String, dynamic> json) {
    return StorageSettingsModel(
      cacheSize: json['cacheSize'] ?? 0,
      cacheImages: json['cacheImages'] ?? true,
      wifiOnlyImages: json['wifiOnlyImages'] ?? false,
      autoplayVideos: json['autoplayVideos'] ?? true,
      cacheTranslations: json['cacheTranslations'] ?? true,
      downloadedBanners: json['downloadedBanners'] ?? 0,
      offlineTranslations: json['offlineTranslations'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'cacheSize': cacheSize,
    'cacheImages': cacheImages,
    'wifiOnlyImages': wifiOnlyImages,
    'autoplayVideos': autoplayVideos,
    'cacheTranslations': cacheTranslations,
    'downloadedBanners': downloadedBanners,
    'offlineTranslations': offlineTranslations,
  };

  StorageSettingsModel copyWith({
    int? cacheSize,
    bool? cacheImages,
    bool? wifiOnlyImages,
    bool? autoplayVideos,
    bool? cacheTranslations,
    int? downloadedBanners,
    int? offlineTranslations,
  }) {
    return StorageSettingsModel(
      cacheSize: cacheSize ?? this.cacheSize,
      cacheImages: cacheImages ?? this.cacheImages,
      wifiOnlyImages: wifiOnlyImages ?? this.wifiOnlyImages,
      autoplayVideos: autoplayVideos ?? this.autoplayVideos,
      cacheTranslations: cacheTranslations ?? this.cacheTranslations,
      downloadedBanners: downloadedBanners ?? this.downloadedBanners,
      offlineTranslations: offlineTranslations ?? this.offlineTranslations,
    );
  }
}
