import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Hashtag group model
class HashtagGroup {
  final String id;
  final String name;
  final List<String> tags;

  HashtagGroup({required this.id, required this.name, required this.tags});

  HashtagGroup copyWith({String? id, String? name, List<String>? tags}) {
    return HashtagGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'tags': tags};

  factory HashtagGroup.fromJson(Map<String, dynamic> json) {
    return HashtagGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      tags: List<String>.from(json['tags'] as List),
    );
  }
}

/// Brand colors model
class BrandColors {
  final Color primary;
  final Color secondary;
  final Color accent;

  const BrandColors({
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  BrandColors copyWith({Color? primary, Color? secondary, Color? accent}) {
    return BrandColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
    );
  }

  Map<String, dynamic> toJson() => {
    'primary': primary.toHex(),
    'secondary': secondary.toHex(),
    'accent': accent.toHex(),
  };

  factory BrandColors.fromJson(Map<String, dynamic> json) {
    return BrandColors(
      primary: HexColor.fromHex(json['primary'] as String),
      secondary: HexColor.fromHex(json['secondary'] as String),
      accent: HexColor.fromHex(json['accent'] as String),
    );
  }

  static BrandColors get defaultColors => const BrandColors(
    primary: Color(0xFF1E3A5F),
    secondary: Color(0xFF14B8A6),
    accent: Color(0xFF8B5CF6),
  );
}

/// Brand Kit main model
class BrandKit {
  final String businessName;

  /// Logo path for mobile/desktop (file path)
  final String? logoPath;

  /// Logo bytes for web (stores as base64 in storage)
  final Uint8List? logoBytes;
  final BrandColors colors;
  final String headingFont;
  final String bodyFont;
  final String voiceTone;
  final double formalityValue;
  final List<HashtagGroup> hashtagGroups;
  final DateTime? updatedAt;

  const BrandKit({
    required this.businessName,
    this.logoPath,
    this.logoBytes,
    required this.colors,
    required this.headingFont,
    required this.bodyFont,
    required this.voiceTone,
    required this.formalityValue,
    required this.hashtagGroups,
    this.updatedAt,
  });

  /// Check if logo is available (either path or bytes)
  bool get hasLogo =>
      (logoPath != null && logoPath!.isNotEmpty) ||
      (logoBytes != null && logoBytes!.isNotEmpty);

  BrandKit copyWith({
    String? businessName,
    String? logoPath,
    Uint8List? logoBytes,
    bool clearLogo = false,
    BrandColors? colors,
    String? headingFont,
    String? bodyFont,
    String? voiceTone,
    double? formalityValue,
    List<HashtagGroup>? hashtagGroups,
    DateTime? updatedAt,
  }) {
    return BrandKit(
      businessName: businessName ?? this.businessName,
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
      logoBytes: clearLogo ? null : (logoBytes ?? this.logoBytes),
      colors: colors ?? this.colors,
      headingFont: headingFont ?? this.headingFont,
      bodyFont: bodyFont ?? this.bodyFont,
      voiceTone: voiceTone ?? this.voiceTone,
      formalityValue: formalityValue ?? this.formalityValue,
      hashtagGroups: hashtagGroups ?? this.hashtagGroups,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'businessName': businessName,
    'logoPath': logoPath,
    'logoBytesBase64': logoBytes != null ? base64Encode(logoBytes!) : null,
    'colors': colors.toJson(),
    'headingFont': headingFont,
    'bodyFont': bodyFont,
    'voiceTone': voiceTone,
    'formalityValue': formalityValue,
    'hashtagGroups': hashtagGroups.map((e) => e.toJson()).toList(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory BrandKit.fromJson(Map<String, dynamic> json) {
    Uint8List? logoBytes;
    final base64String = json['logoBytesBase64'] as String?;
    if (base64String != null && base64String.isNotEmpty) {
      try {
        logoBytes = base64Decode(base64String);
      } catch (_) {
        logoBytes = null;
      }
    }

    return BrandKit(
      businessName: json['businessName'] as String,
      logoPath: json['logoPath'] as String?,
      logoBytes: logoBytes,
      colors: BrandColors.fromJson(json['colors'] as Map<String, dynamic>),
      headingFont: json['headingFont'] as String,
      bodyFont: json['bodyFont'] as String,
      voiceTone: json['voiceTone'] as String,
      formalityValue: (json['formalityValue'] as num).toDouble(),
      hashtagGroups: (json['hashtagGroups'] as List)
          .map((e) => HashtagGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory BrandKit.fromJsonString(String jsonString) {
    return BrandKit.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  static BrandKit get empty => BrandKit(
    businessName: '',
    colors: BrandColors.defaultColors,
    headingFont: 'Inter',
    bodyFont: 'Inter',
    voiceTone: 'Professional',
    formalityValue: 0.5,
    hashtagGroups: [],
  );

  bool get isValid => businessName.isNotEmpty && voiceTone.isNotEmpty;
}

/// Extension for Color to/from hex
extension HexColor on Color {
  String toHex() {
    return '#${toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  static Color fromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

/// Voice tones available
class VoiceTones {
  static const List<String> all = [
    'Professional',
    'Friendly',
    'Bold',
    'Minimal',
    'Funny',
    'Luxury',
  ];
}

/// Font options
class FontOptions {
  static const List<String> headingFonts = [
    'Inter',
    'Poppins',
    'Montserrat',
    'Playfair Display',
    'Raleway',
  ];

  static const List<String> bodyFonts = [
    'Inter',
    'Roboto',
    'Open Sans',
    'Lato',
    'Nunito',
  ];
}
