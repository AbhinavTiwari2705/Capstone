class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String source;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['link'] ?? '', // NewsData.io uses 'link' instead of 'url'
      urlToImage: json['image_url'] ?? '', // NewsData.io uses 'image_url'
      publishedAt: json['pubDate'] ?? '', // NewsData.io uses 'pubDate'
      source: json['source_id'] ?? '', // NewsData.io uses 'source_id'
    );
  }
}
