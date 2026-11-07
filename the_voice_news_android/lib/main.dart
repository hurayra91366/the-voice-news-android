import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/config.dart';
import 'core/labels.dart';
import 'models/article.dart';
import 'screens/article_screen.dart';
import 'screens/news_feed.dart';
import 'services/bookmark_store.dart';
import 'services/news_api.dart';
import 'widgets/article_tile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VoiceNewsApp());
}

class VoiceNewsApp extends StatefulWidget {
  const VoiceNewsApp({super.key});
  @override State<VoiceNewsApp> createState() => _VoiceNewsAppState();
}

class _VoiceNewsAppState extends State<VoiceNewsApp> {
  String _lang = 'en';
  ThemeMode _theme = ThemeMode.system;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() {
      _lang = p.getString('language') ?? 'en';
      _theme = p.getBool('dark') == true ? ThemeMode.dark : ThemeMode.system;
    });
  }
  Future<void> _setLang(String lang) async {
    await (await SharedPreferences.getInstance()).setString('language', lang);
    setState(() => _lang = lang);
  }
  Future<void> _setDark(bool dark) async {
    await (await SharedPreferences.getInstance()).setBool('dark', dark);
    setState(() => _theme = dark ? ThemeMode.dark : ThemeMode.light);
  }
  @override Widget build(BuildContext context) {
    ThemeData theme(Brightness brightness) {
      final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFFB51625), brightness: brightness);
      return ThemeData(colorScheme: scheme, useMaterial3: true,
        scaffoldBackgroundColor: scheme.surface,
        appBarTheme: AppBarTheme(backgroundColor: scheme.surface,
          titleTextStyle: TextStyle(color: scheme.onSurface, fontSize: 18,
            fontWeight: FontWeight.w900, letterSpacing: 0.2)));
    }
    return MaterialApp(title: 'The Voice News', debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light), darkTheme: theme(Brightness.dark), themeMode: _theme,
      home: MainShell(language: _lang, onLanguageChange: _setLang, dark: _theme == ThemeMode.dark,
        onDarkChange: _setDark));
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.language, required this.onLanguageChange,
    required this.dark, required this.onDarkChange});
  final String language;
  final ValueChanged<String> onLanguageChange;
  final bool dark;
  final ValueChanged<bool> onDarkChange;
  @override State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  @override Widget build(BuildContext context) {
    final labels = Labels(widget.language);
    final sections = [
      _HomePage(language: widget.language),
      _SearchPage(language: widget.language),
      _MediaPage(language: widget.language),
      _SavedPage(language: widget.language),
    ];
    return Scaffold(
      appBar: AppBar(title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('THE VOICE NEWS'),
        Text(labels.edition, style: Theme.of(context).textTheme.labelSmall),
      ]), actions: [
        PopupMenuButton<String>(tooltip: 'Language', icon: const Icon(Icons.language),
          onSelected: widget.onLanguageChange, itemBuilder: (_) => const [
            PopupMenuItem(value: 'en', child: Text('English')),
            PopupMenuItem(value: 'bn', child: Text('বাংলা')),
          ]),
        PopupMenuButton<String>(icon: const Icon(Icons.more_vert), onSelected: (v) async {
          if (v == 'dark') widget.onDarkChange(!widget.dark);
          if (v == 'web') {
            final url = widget.language == 'bn' ? AppConfig.banglaUrl : AppConfig.englishUrl;
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          }
        }, itemBuilder: (_) => [
          PopupMenuItem(value: 'dark', child: Text(widget.dark ? 'Light mode' : 'Dark mode')),
          const PopupMenuItem(value: 'web', child: Text('Open website')),
        ]),
      ]),
      body: IndexedStack(index: _tab, children: sections),
      bottomNavigationBar: NavigationBar(selectedIndex: _tab,
        onDestinationSelected: (v) => setState(() => _tab = v), destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: labels.home),
          NavigationDestination(icon: const Icon(Icons.search), label: labels.search),
          NavigationDestination(icon: const Icon(Icons.play_circle_outline), label: labels.videos),
          NavigationDestination(icon: const Icon(Icons.bookmark_border), label: labels.saved),
        ]),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage({required this.language});
  final String language;
  @override State<_HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<_HomePage> {
  final _api = NewsApi();
  List<NewsCategory> _categories = [];
  int? _category;
  @override void initState() { super.initState(); _loadCategories(); }
  @override void didUpdateWidget(covariant _HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) { _category = null; _loadCategories(); }
  }
  Future<void> _loadCategories() async {
    try {
      final data = await _api.getCategories(widget.language);
      if (mounted) setState(() => _categories = data);
    } catch (_) { /* Feed remains usable without category listing. */ }
  }
  @override void dispose() { _api.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final labels = Labels(widget.language);
    return Column(children: [
      Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(labels.latest, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
      SizedBox(height: 45, child: ListView(scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12), children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child:
            ChoiceChip(label: Text(labels.all), selected: _category == null,
              onSelected: (_) => setState(() => _category = null))),
          ..._categories.map((category) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4), child:
              ChoiceChip(label: Text(category.name), selected: _category == category.id,
                onSelected: (_) => setState(() => _category = category.id)))),
        ])),
      Expanded(child: NewsFeed(key: ValueKey('${widget.language}:$_category'),
        language: widget.language, category: _category)),
    ]);
  }
}

class _SearchPage extends StatefulWidget {
  const _SearchPage({required this.language});
  final String language;
  @override State<_SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends State<_SearchPage> {
  final _controller = TextEditingController();
  String _query = '';
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(controller: _controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(prefixIcon: const Icon(Icons.search),
          labelText: Labels(widget.language).search, border: const OutlineInputBorder()),
        onSubmitted: (v) => setState(() => _query = v.trim()))),
      Expanded(child: _query.isEmpty ? Center(child: Text(Labels(widget.language).search)) :
        NewsFeed(key: ValueKey('${widget.language}:$_query'), language: widget.language, search: _query)),
    ]);
  }
}

class _MediaPage extends StatelessWidget {
  const _MediaPage({required this.language});
  final String language;
  @override Widget build(BuildContext context) {
    final labels = Labels(language);
    Widget mediaCard(String title, String description, String url, IconData icon) =>
      Card(margin: const EdgeInsets.symmetric(vertical: 8), child: ListTile(
        contentPadding: const EdgeInsets.all(18), leading: Icon(icon, size: 35),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(url.isEmpty ? description : url),
        trailing: const Icon(Icons.open_in_new),
        onTap: () async {
          if (url.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(description)));
            return;
          }
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }));
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(labels.videos, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 12),
      mediaCard(labels.live, labels.liveSetup, AppConfig.youtubeLiveUrl, Icons.live_tv),
      mediaCard(labels.videos, labels.videoSetup, AppConfig.youtubeChannelUrl, Icons.ondemand_video),
    ]);
  }
}

class _SavedPage extends StatefulWidget {
  const _SavedPage({required this.language});
  final String language;
  @override State<_SavedPage> createState() => _SavedPageState();
}
class _SavedPageState extends State<_SavedPage> {
  final _store = BookmarkStore();
  late Future<List<Article>> _future;
  @override void initState() { super.initState(); _refresh(); }
  void _refresh() { _future = _store.list(); }
  @override Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(future: _future, builder: (context, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final articles = snapshot.data!;
      if (articles.isEmpty) return Center(child: Text(Labels(widget.language).empty));
      return ListView.builder(padding: const EdgeInsets.all(16), itemCount: articles.length,
        itemBuilder: (context, index) => ArticleTile(article: articles[index], onTap: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (_) => ArticleScreen(article: articles[index])));
          setState(_refresh);
        }));
    });
  }
}
