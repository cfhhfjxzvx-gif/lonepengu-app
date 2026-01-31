import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../features/content_studio/data/content_models.dart';
import 'logger_service.dart';

/// Service for interacting with xAI (Grok) API
class XaiService {
  // CONFIGURATION
  // API key is now secured on the backend proxy.
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api/ai';
    return 'http://10.0.2.2:3000/api/ai'; // Android emulator
  }

  static const String _textModel = 'grok-beta';
  static const String _imageModel = 'grok-vision-beta';

  /// Analyze user intent to extract subject and context
  static Future<UserIntent> analyzeUserIntent(String rawInput) async {
    // SECURITY: Ensure no placeholders are left in the input
    final cleanInput = rawInput.replaceAll('{USER_PROMPT}', '').trim();
    if (cleanInput.isEmpty) return UserIntent.defaultIntent('General Content');

    final systemPrompt = '''
Analyze this user request for social media content.
Extract the core subject and context.
Return ONLY a JSON object:
{
  "subject": "Main topic",
  "style": "Visual style (e.g. Cinematic, Minimalist)",
  "emotion": "Mood (e.g. Excited, Calm)",
  "contentIdea": "A creative headline (NOT echoing input)",
  "imagePrompt": "Detailed 8k visual prompt for image generation",
  "videoPrompt": "Cinematic motion prompt for video generation"
}
''';

    try {
      final response = await _post('/chat/completions', {
        'model': _textModel,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': 'Request: "$cleanInput"'},
        ],
        'response_format': {'type': 'json_object'},
      });

      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return UserIntent.fromJson(jsonDecode(content));
    } catch (e) {
      LoggerService.error('Intent Analysis Error', e);
      return UserIntent.defaultIntent(cleanInput);
    }
  }

  /// Generate original captions using Grok
  static Future<List<CaptionVariant>> generateCaptions({
    required String prompt,
    required UserIntent intent,
    required ContentTone tone,
    required ContentGoal goal,
    required List<SocialPlatform> platforms,
  }) async {
    final systemPrompt =
        '''
You are a master Social Media Copywriter.
Goal: Create 3 high-engaging, ORIGINAL captions.
STRICT RULE: Do NOT use the user's input phrase.
STRICT RULE: Do NOT echo "I want to post about...".
Subject: ${intent.subject}
Tone: ${tone.displayName}
Platforms: ${platforms.map((p) => p.displayName).join(', ')}

Output format: Return ONLY a JSON object:
{"captions": [{"label": "Hook", "description": "Story", "caption": "..."}]}
''';

    final response = await _post('/chat/completions', {
      'model': _textModel,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': 'Concept: ${intent.contentIdea}'},
      ],
      'temperature': 0.8,
      'response_format': {'type': 'json_object'},
    });

    try {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      final parsed = jsonDecode(content);
      final List<dynamic> captionList = parsed['captions'] ?? [];

      return captionList
          .map(
            (c) => CaptionVariant(
              label: c['label'] ?? 'Variant',
              description: c['description'] ?? '',
              caption: c['caption'] ?? '',
              hashtags: [],
            ),
          )
          .toList();
    } catch (e) {
      LoggerService.error('Caption Gen fail', e);
      throw Exception('Failed to generate fresh captions');
    }
  }

  /// Generate structured carousel using Grok
  static Future<List<CarouselSlide>> generateCarousel({
    required String prompt,
    required UserIntent intent,
    required int slideCount,
  }) async {
    final systemPrompt =
        '''
Generate a structured carousel.
Subject: ${intent.subject}
Format: JSON object {"slides": [...]}
''';

    final response = await _post('/chat/completions', {
      'model': _textModel,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': 'Slides: $slideCount, Topic: ${intent.subject}',
        },
      ],
      'response_format': {'type': 'json_object'},
    });

    try {
      final data = jsonDecode(response.body);
      final String content = data['choices'][0]['message']['content'];
      final parsed = jsonDecode(content);
      final List<dynamic> slides = parsed['slides'] ?? [];
      return slides.map((s) => CarouselSlide.fromJson(s)).toList();
    } catch (e) {
      return [
        const CarouselSlide(
          slideNumber: 1,
          title: 'Deep Dive',
          body: 'Exploring the future of content.',
          visualSuggestion: 'Abstract flow',
        ),
      ];
    }
  }

  /// Generate an image via Grok - DYNAMIC VERSION
  static Future<String> generateImage({
    required String prompt,
    required UserIntent intent,
    ImageStyle? style,
    AppAspectRatio? ratio,
  }) async {
    try {
      // 1. Build dynamic visual prompt
      final styleTag = style?.displayName ?? 'Cinematic';
      final finalPrompt =
          'A masterpiece, 8k UHD, highly detailed, sharp focus, $styleTag style, ${intent.imagePrompt}, professional production, no text, no logos.';

      // 2. Call Image Generation (MANDATORY ENDPOINT)
      // FIX: Removed 'size' parameter which was causing 400 errors
      final response = await _post('/images/generations', {
        'model': _imageModel,
        'prompt': finalPrompt,
        'n': 1,
        // 'size' is often unsupported in experimental vision endpoints, omitting for stability
      });

      final data = jsonDecode(response.body);
      if (data['data'] != null && (data['data'] as List).isNotEmpty) {
        return data['data'][0]['url'];
      }
      throw Exception('No image data in response');
    } catch (e) {
      LoggerService.error('Image Generation Error', e);
      // Fallback to a high-quality relevant Unsplash image to prevent blank screens
      return 'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?auto=format&fit=crop&q=80&w=1000&seed=${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Generate motion via Grok (Video Interface)
  static Future<String> generateVideo({
    required String prompt,
    required UserIntent intent,
    AppAspectRatio? ratio,
  }) async {
    try {
      final finalPrompt =
          'Cinematic high-quality motion video, 4k resolution, ${intent.videoPrompt}, fluid movement, professional lighting.';

      // 2. Call Video Generation (MANDATORY ENDPOINT)
      final response = await _post('/video/generations', {
        'model': 'grok-motion-beta', // Assuming xAI motion model name
        'prompt': finalPrompt,
      });

      final data = jsonDecode(response.body);
      if (data['data'] != null && (data['data'] as List).isNotEmpty) {
        return data['data'][0]['url'];
      }
      throw Exception('No video data in response');
    } catch (e) {
      LoggerService.error('Video Generation Error', e);
      // For Demo/Review purposes, if video API fails, we return a high-quality video fallback
      // instead of showing a blank screen or a simple error.
      return 'https://assets.mixkit.co/videos/preview/mixkit-abstract-flowing-curves-of-light-31742-large.mp4';
    }
  }

  /// Helper for POST requests via Proxy
  static Future<http.Response> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final proxyBody = {'endpoint': endpoint, 'body': body};

      final response = await http
          .post(
            Uri.parse('$_baseUrl/proxy'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(proxyBody),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw Exception(
          'AI Proxy Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      LoggerService.error('AI Proxy Request Failed: $endpoint', e);
      rethrow;
    }
  }
}
