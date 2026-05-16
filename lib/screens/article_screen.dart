import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article_model.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class ArticleScreen extends StatefulWidget {
  final ArticleModel article;

  const ArticleScreen({super.key, required this.article});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final _db = DatabaseService();
  bool _isSaved = false;
  bool _showWebView = false;
  late WebViewController _webController;

  @override
  void initState() {
    super.initState();
    _checkSaved();
    _initWebView();
  }

  Future<void> _checkSaved() async {
    final saved = await _db.isArticleSaved(widget.article.url);
    setState(() => _isSaved = saved);
  }

  void _initWebView() {
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.article.url));
  }

  Future<void> _toggleSave() async {
    if (_isSaved) {
      await _db.deleteArticle(widget.article.url);
    } else {
      await _db.saveArticle(widget.article);
    }
    setState(() => _isSaved = !_isSaved);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved ? 'Artigo salvo!' : 'Artigo removido dos salvos.'),
        backgroundColor: _isSaved ? AppTheme.accent : AppTheme.textSecondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat("dd 'de' MMMM 'de' yyyy, HH:mm", 'pt_BR').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.article;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          a.source,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? AppTheme.accentLight : Colors.white,
            ),
            onPressed: _toggleSave,
            tooltip: _isSaved ? 'Remover dos salvos' : 'Salvar',
          ),
          IconButton(
            icon: Icon(
              _showWebView ? Icons.article_outlined : Icons.open_in_browser,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _showWebView = !_showWebView),
            tooltip: _showWebView ? 'Ver resumo' : 'Abrir matéria completa',
          ),
        ],
      ),
      body: _showWebView
          ? WebViewWidget(controller: _webController)
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem
                  if (a.imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: a.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        height: 120,
                        color: const Color(0xFFF3F4F6),
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined,
                              size: 40, color: Color(0xFFD1D5DB)),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categoria + fonte
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                a.category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.newspaper_rounded,
                                size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                a.source,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Título
                        Text(
                          a.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Data
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(a.publishedAt),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        // Descrição
                        Text(
                          a.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                            height: 1.7,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botão matéria completa
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                setState(() => _showWebView = true),
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Ler matéria completa'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
