class ReadingSettings {
  final bool isDarkMode;
  final String fontSize;
  final String fontFamily;
  final bool novelNotifications;
  final bool autoScroll;

  ReadingSettings({
    required this.isDarkMode,
    required this.fontSize,
    required this.fontFamily,
    required this.novelNotifications,
    required this.autoScroll,
  });

  ReadingSettings copyWith({
    bool? isDarkMode,
    String? fontSize,
    String? fontFamily,
    bool? novelNotifications,
    bool? autoScroll,
  }) {
    return ReadingSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      novelNotifications: novelNotifications ?? this.novelNotifications,
      autoScroll: autoScroll ?? this.autoScroll,
    );
  }
}