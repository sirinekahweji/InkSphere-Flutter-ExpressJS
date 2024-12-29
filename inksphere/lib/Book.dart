class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String? image;
  final String? price;
  final String? category;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    this.image,
    this.price,
    this.category,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      image: json['image'],
    price: json['price']?.toString(),
      category: json['category'],
    );
  }
}
