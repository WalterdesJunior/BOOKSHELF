import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/article_model.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import 'article_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final _db = DatabaseService();
  List<ArticleModel> _saved = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _saved = await _db.getSavedArticles();
    setState(() => _loading = false);
  }

  Future<void> _toggleRead(ArticleModel article) async {
    await _db.markAsRead(article.url, !article.isRead);
    await _load();
  }

  Future<void> _remove(ArticleModel article) async {
    await _db.deleteArticle(article.url);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Artigo removido dos salvos.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _saved.where((a) => !a.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Salvos'),
            if (_saved.isNotEmpty)
              Text(
                '$unread não lido${unread != 1 ? 's' : ''}',
                style: const TextStyle(
                    fontSize: 12, color: Colors.white60),
              ),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : _saved.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border,
                          size: 70, color: AppTheme.textSecondary),
                      SizedBox(height: 14),
                      Text(
                        'Nenhum artigo salvo ainda.',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 16),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Toque no 🔖 para salvar notícias.',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _saved.length,
                  itemBuilder: (_, i) {
                    final a = _saved[i];
                    return Dismissible(
                      key: Key(a.url),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: AppTheme.error,
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white, size: 28),
                      ),
                      onDismissed: (_) => _remove(a),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: a.isRead
                              ? const Color(0xFFF9FAFB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: a.isRead
                                ? const Color(0xFFE5E7EB)
                                : AppTheme.accent.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArticleScreen(article: a),
                            ),
                          ).then((_) => _load()),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Checkbox lida
                                Column(
                                  children: [
                                    Checkbox(
                                      value: a.isRead,
                                      onChanged: (_) => _toggleRead(a),
                                      activeColor: AppTheme.success,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const Text(
                                      'lida',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),

                                // Conteúdo
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Fonte + data
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              a.source,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: a.isRead
                                                    ? AppTheme.textSecondary
                                                    : AppTheme.accent,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            _formatDate(a.publishedAt),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Título
                                      Text(
                                        a.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: a.isRead
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          color: a.isRead
                                              ? AppTheme.textSecondary
                                              : AppTheme.textPrimary,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      // Badge não lida
                                      if (!a.isRead) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accent
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'Não lida',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.accent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Miniatura
                                if (a.imageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: a.imageUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        width: 70,
                                        height: 70,
                                        color: const Color(0xFFF3F4F6),
                                        child: const Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 24,
                                            color: Color(0xFFD1D5DB)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
