class ArticleModel {
  final int? id;
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String source;
  final String publishedAt;
  final String category;
  bool isRead;
  bool isSaved;

  ArticleModel({
    this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.category,
    this.isRead = false,
    this.isSaved = false,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json, String category) {
    return ArticleModel(
      title: json['title'] ?? 'Sem título',
      description: json['description'] ?? 'Sem descrição',
      url: json['url'] ?? '',
      imageUrl: json['image'] ?? '',
      source: json['source']?['name'] ?? 'Fonte desconhecida',
      publishedAt: json['publishedAt'] ?? '',
      category: category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'image_url': imageUrl,
      'source': source,
      'published_at': publishedAt,
      'category': category,
      'is_read': isRead ? 1 : 0,
      'is_saved': isSaved ? 1 : 0,
    };
  }

  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      url: map['url'],
      imageUrl: map['image_url'],
      source: map['source'],
      publishedAt: map['published_at'],
      category: map['category'],
      isRead: map['is_read'] == 1,
      isSaved: map['is_saved'] == 1,
    );
  }

  ArticleModel copyWith({bool? isRead, bool? isSaved}) {
    return ArticleModel(
      id: id,
      title: title,
      description: description,
      url: url,
      imageUrl: imageUrl,
      source: source,
      publishedAt: publishedAt,
      category: category,
      isRead: isRead ?? this.isRead,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
