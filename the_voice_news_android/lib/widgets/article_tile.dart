import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';

class ArticleTile extends StatelessWidget {
  const ArticleTile({super.key, required this.article, required this.onTap, this.featured = false});
  final Article article;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final title = Html(data: article.title, style: {
      'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero,
        fontSize: FontSize(featured ? 21 : 16), fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface, maxLines: featured ? 3 : 2,
        textOverflow: TextOverflow.ellipsis),
    });
    final image = article.imageUrl.isEmpty
      ? Container(color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.newspaper, size: 38))
      : CachedNetworkImage(imageUrl: article.imageUrl, fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const Icon(Icons.newspaper));
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child:
      Padding(padding: const EdgeInsets.symmetric(vertical: 9), child:
        featured
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(borderRadius: BorderRadius.circular(14), child:
                AspectRatio(aspectRatio: 16 / 9, child: image)),
              const SizedBox(height: 12), title, const SizedBox(height: 7),
              Text(DateFormat.yMMMd().format(article.published),
                style: Theme.of(context).textTheme.bodySmall),
            ])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 6),
                  Text(DateFormat.yMMMd().format(article.published),
                    style: Theme.of(context).textTheme.bodySmall)])),
              const SizedBox(width: 12),
              ClipRRect(borderRadius: BorderRadius.circular(10), child:
                SizedBox(width: 112, height: 83, child: image)),
            ])));
  }
}
