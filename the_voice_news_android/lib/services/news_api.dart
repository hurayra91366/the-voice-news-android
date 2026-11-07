import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/article.dart';

class NewsApi {
  final http.Client _client;
  NewsApi([http.Client? client]) : _client = client ?? http.Client();

  Future<List<Article>> getPosts({required String language, int page = 1,
      int? category, String? search, int perPage = 15}) async {
    final params = <String, String>{
      'per_page': '$perPage', 'page': '$page', '_embed': '1',
      'lang': language,
      if (category != null) 'categories': '$category',
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };
    final url = Uri.parse('${AppConfig.apiUrl}/posts').replace(queryParameters: params);
    final response = await _client.get(url, headers: {'Accept':'application/json'})
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 400 && response.body.contains('rest_post_invalid_page_number')) {
      return [];
    }
    if (response.statusCode != 200) {
      throw Exception('WordPress returned HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! List) throw const FormatException('Unexpected WordPress response');
    final posts = decoded.whereType<Map<String, dynamic>>()
        .map((json) => Article.fromJson(json, language)).toList();
    // Defense against a plugin ignoring the `lang` query parameter.
    return posts.where((post) {
      final path = Uri.tryParse(post.url)?.path ?? '';
      final isBanglaPath = path == '/bn' || path.startsWith('/bn/');
      return language == 'bn' ? isBanglaPath : !isBanglaPath;
    }).toList();
  }

  Future<List<NewsCategory>> getCategories(String language) async {
    final url = Uri.parse('${AppConfig.apiUrl}/categories').replace(queryParameters: {
      'per_page':'100', 'hide_empty':'true', 'lang':language,
    });
    final response = await _client.get(url).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw Exception('Category request failed (${response.statusCode})');
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return (decoded as List).whereType<Map<String, dynamic>>()
        .map(NewsCategory.fromJson).toList();
  }

  void dispose() => _client.close();
}
