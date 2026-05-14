class ContentModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? imageUrl;
  final String? videoUrl;
  final String? body;
  final String? externalUrl;
  final List<String> tags;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    this.videoUrl,
    this.body,
    this.externalUrl,
    this.tags = const [],
  });

  factory ContentModel.fromMap(Map<String, dynamic> map) {
    return ContentModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Geral',
      imageUrl: map['imageUrl']?.toString(),
      videoUrl: map['videoUrl']?.toString(),
      body: map['body']?.toString(),
      externalUrl: map['externalUrl']?.toString(),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}
