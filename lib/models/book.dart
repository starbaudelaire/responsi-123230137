class Book {
  final String title;
  final String cover;
  final String releaseDate;
  final String originalTitle;
  final int pages;
  final String description;

  Book({
    required this.title,
    required this.cover,
    required this.releaseDate,
    required this.originalTitle,
    required this.pages,
    required this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? '',
      cover: json['cover'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      originalTitle: json['originalTitle'] ?? '',
      pages: json['pages'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}