import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class BookmarkStore {
  static const _key = 'saved_articles_v1';
  Future<List<Article>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);
    if (encoded == null) return [];
    try {
      final data = jsonDecode(encoded) as List;
      return data.whereType<Map<String, dynamic>>().map(Article.fromSaved).toList();
    } catch (_) { return []; }
  }
  Future<bool> contains(Article article) async =>
      (await list()).any((e) => e.id == article.id && e.language == article.language);

  Future<void> toggle(Article article) async {
    final items = await list();
    final index = items.indexWhere((e) => e.id == article.id && e.language == article.language);
    if (index >= 0) { items.removeAt(index); } else { items.insert(0, article); }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }
}
