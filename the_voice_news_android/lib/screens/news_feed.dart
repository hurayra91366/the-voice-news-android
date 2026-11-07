import 'package:flutter/material.dart';
import '../core/labels.dart';
import '../models/article.dart';
import '../services/news_api.dart';
import '../widgets/article_tile.dart';
import 'article_screen.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({super.key, required this.language, this.search, this.category});
  final String language;
  final String? search;
  final int? category;
  @override State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  final _api = NewsApi();
  List<Article> _articles = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  @override void initState() { super.initState(); _load(reset: true); }
  @override void didUpdateWidget(covariant NewsFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language || oldWidget.search != widget.search ||
        oldWidget.category != widget.category) _load(reset: true);
  }
  @override void dispose() { _api.dispose(); super.dispose(); }

  Future<void> _load({bool reset = false}) async {
    if (_loading && !reset) return;
    final requestedPage = reset ? 1 : _page;
    setState(() {
      _loading = true; _error = null;
      if (reset) { _articles = []; _page = 1; _hasMore = true; }
    });
    try {
      final incoming = await _api.getPosts(language: widget.language,
        page: requestedPage, category: widget.category, search: widget.search);
      if (!mounted) return;
      setState(() {
        _articles = reset ? incoming : [..._articles, ...incoming];
        _page = requestedPage + 1;
        _hasMore = incoming.length == 15;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override Widget build(BuildContext context) {
    final labels = Labels(widget.language);
    if (_loading && _articles.isEmpty) return const Center(child: CircularProgressIndicator());
    if (_error != null && _articles.isEmpty) return Center(child:
      Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min,
        children: [Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 12), ElevatedButton(onPressed: () => _load(reset: true), child: Text(labels.retry))])));
    if (_articles.isEmpty) return Center(child: Text(labels.empty));
    return RefreshIndicator(onRefresh: () => _load(reset: true), child:
      ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _articles.length + 1, itemBuilder: (context, index) {
          if (index == _articles.length) {
            if (!_hasMore) return const SizedBox(height: 25);
            return Padding(padding: const EdgeInsets.all(14), child: Center(child: TextButton(
              onPressed: _loading ? null : () => _load(),
              child: _loading ? const CircularProgressIndicator() :
                Text(widget.language == 'bn' ? 'আরও সংবাদ' : 'Load more'))));
          }
          final article = _articles[index];
          return Column(children: [ArticleTile(article: article, featured: index == 0,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ArticleScreen(article: article)))),
            const Divider(height: 17)]);
        }));
  }
}
