import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/labels.dart';
import '../models/article.dart';
import '../services/bookmark_store.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key, required this.article});
  final Article article;
  @override State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final _bookmarks = BookmarkStore();
  bool _saved = false;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final v = await _bookmarks.contains(widget.article);
    if (mounted) setState(() => _saved = v);
  }
  Future<void> _toggle() async {
    await _bookmarks.toggle(widget.article);
    await _load();
  }
  @override Widget build(BuildContext context) {
    final article = widget.article;
    final labels = Labels(article.language);
    return Scaffold(appBar: AppBar(title: const Text('THE VOICE NEWS'), actions: [
      IconButton(tooltip: labels.saved, icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border), onPressed: _toggle),
      IconButton(tooltip: labels.share, icon: const Icon(Icons.share_outlined),
        onPressed: () => Share.share(article.url)),
    ]), body: SelectionArea(child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 30), children: [
      Html(data: article.title, style: {'body': Style(margin: Margins.zero,
        fontSize: FontSize(27), fontWeight: FontWeight.bold, lineHeight: const LineHeight(1.25))}),
      const SizedBox(height: 8),
      Text(DateFormat.yMMMMd().format(article.published), style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 16),
      if (article.imageUrl.isNotEmpty) ...[
        ClipRRect(borderRadius: BorderRadius.circular(12), child:
          CachedNetworkImage(imageUrl: article.imageUrl, fit: BoxFit.cover)),
        const SizedBox(height: 16),
      ],
      Html(data: article.html, style: {'body': Style(fontSize: FontSize(17),
        lineHeight: const LineHeight(1.65), margin: Margins.zero)},
        onLinkTap: (url, _, __) async {
          if (url == null) return;
          final uri = Uri.tryParse(url);
          if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }),
      const SizedBox(height: 12),
      OutlinedButton.icon(icon: const Icon(Icons.open_in_browser), label: Text(labels.source),
        onPressed: () async {
          final uri = Uri.tryParse(article.url);
          if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
        }),
    ])));
  }
}
