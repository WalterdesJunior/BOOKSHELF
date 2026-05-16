import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/news_service.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/category_chips.dart';
import 'article_screen.dart';
import 'saved_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _newsService = NewsService();
  final _db = DatabaseService();
  final _prefs = PreferencesService();
  final _searchController = TextEditingController();

  static const _categories = [
    'Geral', 'Tecnologia', 'Esportes', 'Ciência', 'Saúde', 'Entretenimento',
  ];

  String _selectedCategory = 'Geral';
  bool _isBrasil = true;
  bool _isSearching = false;
  Set<String> _savedUrls = {};
  late Future<List<ArticleModel>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadSavedUrls();
  }

  Future<void> _loadPreferences() async {
    final cat = await _prefs.getDefaultCategory();
    final brasil = await _prefs.getBrasilMode();
    setState(() {
      _selectedCategory = cat;
      _isBrasil = brasil;
      _newsFuture = _fetchNews();
    });
  }

  Future<void> _loadSavedUrls() async {
    final saved = await _db.getSavedArticles();
    setState(() {
      _savedUrls = saved.map((a) => a.url).toSet();
    });
  }

  Future<List<ArticleModel>> _fetchNews() {
    return _newsService.getTopHeadlines(
      category: _selectedCategory,
      brasil: _isBrasil,
    );
  }

  Future<List<ArticleModel>> _search(String query) {
    return _newsService.searchNews(query: query, brasil: _isBrasil);
  }

  void _onCategoryChange(String cat) async {
    setState(() {
      _selectedCategory = cat;
      _isSearching = false;
      _searchController.clear();
      _newsFuture = _fetchNews();
    });
    await _prefs.setDefaultCategory(cat);
  }

  void _onBrasilToggle(bool val) async {
    setState(() {
      _isBrasil = val;
      _newsFuture = _isSearching && _searchController.text.isNotEmpty
          ? _search(_searchController.text)
          : _fetchNews();
    });
    await _prefs.setBrasilMode(val);
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _newsFuture = _fetchNews();
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _newsFuture = _search(query.trim());
    });
  }

  Future<void> _toggleSave(ArticleModel article) async {
    final isSaved = _savedUrls.contains(article.url);
    if (isSaved) {
      await _db.deleteArticle(article.url);
      setState(() => _savedUrls.remove(article.url));
    } else {
      await _db.saveArticle(article);
      setState(() => _savedUrls.add(article.url));
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _errorMessage(dynamic e) {
    final msg = e.toString();
    if (msg.contains('limite_requisicoes')) {
      return 'Limite de requisições atingido.\nTente novamente mais tarde.';
    }
    if (msg.contains('sem_conexao')) {
      return 'Sem conexão com a internet.\nVerifique sua rede.';
    }
    return 'Nenhum resultado encontrado.';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_stories_rounded, size: 22),
            const SizedBox(width: 8),
            const Text('BookShelf'),
          ],
        ),
        actions: [
          // Switch Brasil/Internacional
          Row(
            children: [
              Text(
                _isBrasil ? '🇧🇷' : '🌍',
                style: const TextStyle(fontSize: 18),
              ),
              Switch(
                value: _isBrasil,
                onChanged: _onBrasilToggle,
                activeColor: AppTheme.accentLight,
                inactiveThumbColor: Colors.white,
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'Usuário',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(user?.email ?? 'email@exemplo.com',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: AppTheme.error),
                    SizedBox(width: 8),
                    Text('Sair', style: TextStyle(color: AppTheme.error)),
                  ],
                ),
              ),
            ],
            onSelected: (val) {
              if (val == 'logout') _logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
              onChanged: (v) {
                if (v.isEmpty && _isSearching) {
                  setState(() {
                    _isSearching = false;
                    _newsFuture = _fetchNews();
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Buscar notícias...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.accent),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _isSearching = false;
                            _newsFuture = _fetchNews();
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Categorias
          if (!_isSearching)
            CategoryChips(
              categories: _categories,
              selected: _selectedCategory,
              onSelected: _onCategoryChange,
            ),
          if (!_isSearching) const SizedBox(height: 8),

          // Lista de notícias
          Expanded(
            child: FutureBuilder<List<ArticleModel>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.accent),
                        SizedBox(height: 12),
                        Text('Carregando notícias...',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            size: 60, color: AppTheme.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage(snapshot.error),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              setState(() => _newsFuture = _fetchNews()),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final articles = snapshot.data ?? [];
                if (articles.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined,
                            size: 60, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text(
                          'Nenhuma notícia encontrada.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _newsFuture = _fetchNews());
                  },
                  color: AppTheme.accent,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: articles.length,
                    itemBuilder: (_, i) {
                      final a = articles[i];
                      return ArticleCard(
                        article: a,
                        isSaved: _savedUrls.contains(a.url),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArticleScreen(article: a),
                            ),
                          );
                          _loadSavedUrls();
                        },
                        onSave: () => _toggleSave(a),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedScreen()),
            ).then((_) => _loadSavedUrls());
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Salvos',
          ),
        ],
      ),
    );
  }
}
