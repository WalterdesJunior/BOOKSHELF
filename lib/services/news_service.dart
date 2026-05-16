import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class NewsService {

  static const String _apiKey = '875c80b5b0cfbf8624b3a04611591241';
  static const String _baseUrl = 'https://gnews.io/api/v4';

  static const Map<String, String> categoryMap = {
    'Geral': 'general',
    'Tecnologia': 'technology',
    'Esportes': 'sports',
    'Ciência': 'science',
    'Saúde': 'health',
    'Entretenimento': 'entertainment',
  };

  Future<List<ArticleModel>> getTopHeadlines({
    required String category,
    bool brasil = true,
    int max = 10,
  }) async {
    final lang = brasil ? 'pt' : 'en';
    final country = brasil ? 'br' : 'us';
    final cat = categoryMap[category] ?? 'general';

    final uri = Uri.parse('$_baseUrl/top-headlines').replace(
      queryParameters: {
        'category': cat,
        'lang': lang,
        'country': country,
        'max': max.toString(),
        'apikey': _apiKey,
      },
    );

    return _fetch(uri, category);
  }

  Future<List<ArticleModel>> searchNews({
    required String query,
    bool brasil = true,
    int max = 10,
  }) async {
    final lang = brasil ? 'pt' : 'en';

    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'q': query,
        'lang': lang,
        'max': max.toString(),
        'apikey': _apiKey,
      },
    );

    return _fetch(uri, 'Geral');
  }

  Future<List<ArticleModel>> _fetch(Uri uri, String category) async {
    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List? ?? [];
        return articles
            .map((a) => ArticleModel.fromJson(a, category))
            .toList();
      } else if (response.statusCode == 429) {
        throw Exception('limite_requisicoes');
      } else {
        throw Exception('erro_servidor');
      }
    } catch (e) {
      if (e.toString().contains('limite_requisicoes')) rethrow;
      if (e.toString().contains('erro_servidor')) rethrow;
      throw Exception('sem_conexao');
    }
  }
}
