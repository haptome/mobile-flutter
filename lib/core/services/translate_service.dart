// Purpose: Lightweight Google Translate service using the unofficial mobile endpoint.
// No API key needed. Results are cached in-memory to avoid repeated network calls.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TranslateService {
  TranslateService._();
  static final TranslateService instance = TranslateService._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  // In-memory cache: "text|targetLang" -> translated string
  final Map<String, String> _cache = {};

  /// Translates [text] from [from] language to [to] language.
  /// Returns the original [text] on any error so the UI always has something to show.
  Future<String> translate(
    String text, {
    String from = 'en',
    String to = 'am',
  }) async {
    if (text.trim().isEmpty) return text;
    if (from == to) return text;

    final cacheKey = '$text|$to';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    try {
      final response = await _dio.get(
        'https://translate.google.com/m',
        queryParameters: {'sl': from, 'tl': to, 'q': text},
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
                '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          },
          responseType: ResponseType.plain,
        ),
      );

      final body = response.data as String;
      final result = _parse(body);

      if (result != null && result.isNotEmpty) {
        _cache[cacheKey] = result;
        return result;
      }
    } catch (e) {
      debugPrint('[TranslateService] Error translating "$text": $e');
    }

    // Fallback to original text on any failure
    return text;
  }

  /// Clears the in-memory cache (useful when switching languages back to EN).
  void clearCache() => _cache.clear();

  String? _parse(String html) {
    const tag = '<div class="result-container">';
    final start = html.indexOf(tag);
    if (start == -1) return null;
    final end = html.indexOf('</div>', start + tag.length);
    if (end == -1) return null;
    // Decode common HTML entities
    return html
        .substring(start + tag.length, end)
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }
}
