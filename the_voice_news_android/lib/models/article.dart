class Article {
  final int id;
  final String title;
  final String excerpt;
  final String html;
  final String url;
  final String imageUrl;
  final DateTime published;
  final List<int> categoryIds;
  final String language;

  Article({required this.id, required this.title, required this.excerpt,
    required this.html, required this.url, required this.imageUrl,
    required this.published, required this.categoryIds, required this.language});

  factory Article.fromJson(Map<String, dynamic> json, String language) {
    final embedded = json['_embedded'];
    String image = '';
    if (embedded is Map && embedded['wp:featuredmedia'] is List &&
        (embedded['wp:featuredmedia'] as List).isNotEmpty) {
      final media = embedded['wp:featuredmedia'][0];
      if (media is Map) image = (media['source_url'] ?? '').toString();
    }
    String rendered(dynamic data) => data is Map ? (data['rendered'] ?? '').toString() : '';
    return Article(
      id: (json['id'] as num).toInt(),
      title: rendered(json['title']),
      excerpt: rendered(json['excerpt']),
      html: rendered(json['content']),
      url: (json['link'] ?? '').toString(),
      imageUrl: image,
      published: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      categoryIds: (json['categories'] as List? ?? []).whereType<num>().map((e) => e.toInt()).toList(),
      language: language,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': {'rendered': title}, 'excerpt': {'rendered': excerpt},
    'content': {'rendered': html}, 'link': url, 'date': published.toIso8601String(),
    'categories': categoryIds, 'savedImage': imageUrl, 'savedLanguage': language,
  };

  factory Article.fromSaved(Map<String, dynamic> json) {
    final item = Article.fromJson(json, (json['savedLanguage'] ?? 'en').toString());
    return Article(id: item.id, title: item.title, excerpt: item.excerpt,
      html: item.html, url: item.url,
      imageUrl: (json['savedImage'] ?? '').toString(), published: item.published,
      categoryIds: item.categoryIds, language: item.language);
  }
}

class NewsCategory {
  final int id;
  final String name;
  NewsCategory(this.id, this.name);
  factory NewsCategory.fromJson(Map<String, dynamic> json) =>
      NewsCategory((json['id'] as num).toInt(), (json['name'] ?? '').toString());
}
