import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Books extends StatefulWidget {
  final dynamic idUser;

  const Books({super.key, required this.idUser});

  @override
  State<Books> createState() => _BooksPageState();
}

class _BooksPageState extends State<Books> {
  List<Book> books = [];
  List<Book> filteredBooks = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  Future<void> fetchBooks() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/book'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        books = data.map((json) => Book.fromJson(json)).toList();
        filteredBooks = books;
      });
    } else {
      throw Exception('Failed to load books');
    }
  }

  void filterBooks() {
    setState(() {
      filteredBooks = books
          .where((book) => book.title.toLowerCase().contains(searchController.text.toLowerCase()) ||
                          book.author.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> addBook() async {
    final newBook = {
      'title': titleController.text,
      'author': authorController.text,
      'description': descriptionController.text,
      'image': imageController.text,
      'price': priceController.text,
      'category': categoryController.text,
    };

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/book/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newBook),
    );

    if (response.statusCode == 200) {
      fetchBooks(); // Refresh the list
      Navigator.pop(context); // Close the form after adding
    } else {
      throw Exception('Failed to add book');
    }
  }

  Future<void> updateBook(String bookId) async {
    final updatedBook = {
      'title': titleController.text,
      'author': authorController.text,
      'description': descriptionController.text,
      'image': imageController.text,
      'price': priceController.text,
      'category': categoryController.text,
    };

    final response = await http.put(
      Uri.parse('http://localhost:5000/api/book/$bookId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedBook),
    );

    if (response.statusCode == 200) {
      fetchBooks(); // Refresh the list
      Navigator.pop(context); // Close the form after updating
    } else {
      throw Exception('Failed to update book');
    }
  }

  Future<void> showDeleteConfirmationDialog(String bookId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this book?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteBook(bookId); // Delete the book
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteBook(String bookId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:5000/api/book/$bookId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        books.removeWhere((book) => book.id == bookId);
        filteredBooks = books; // Update filtered list after deletion
      });
    } else {
      throw Exception('Failed to delete book');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
    searchController.addListener(filterBooks);
  }

  @override
  void dispose() {
    searchController.removeListener(filterBooks);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Books',
          style: GoogleFonts.lobster(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFA65233),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Search TextField
                Container(
                  width: 300, 
                  height: 40,
                  child: TextField(
                    controller: searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Rounded corners
                        borderSide: BorderSide(
                          color: _searchFocusNode.hasFocus ? Color(0xFF6F4F37) : Color(0xFFA65233), // Brown color when focused
                          width: 1,
                        ), 
                      ),
                      suffixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFA65233), // Brown icon color
                      ),
                    ),
                  ),
                ),
                // Add Book Button
                ElevatedButton(
                  onPressed: () {
                    // Show form for adding a new book
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Add New Book',),
                          content: BookForm(
                            titleController: titleController,
                            authorController: authorController,
                            descriptionController: descriptionController,
                            imageController: imageController,
                            priceController: priceController,
                            categoryController: categoryController,
                            onSubmit: addBook,
                          ),
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Add Book'),
                      SizedBox(width: 8), // Add some spacing between the text and icon
                      Icon(Icons.add), // Add the add icon
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA65233), 
                    foregroundColor: Colors.white, 
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 5,
                  child: ListTile(
                    leading: book.image != null
                        ? Image.memory(
                            base64Decode(
                              book.image!.replaceFirst('data:image/jpeg;base64,', ''),
                            ),
                            width: 70,
                            height: 70,
                            fit: BoxFit.contain,
                          )
                        : null,
                    title: Text(
                      book.title,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      book.author,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Color.fromARGB(255, 13, 126, 32)),
                          onPressed: () {
                            titleController.text = book.title;
                            authorController.text = book.author;
                            descriptionController.text = book.description;
                            imageController.text = book.image ?? '';
                            priceController.text = book.price ?? '';
                            categoryController.text = book.category ?? '';
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Edit Book'),
                                  content: BookForm(
                                    titleController: titleController,
                                    authorController: authorController,
                                    descriptionController: descriptionController,
                                    imageController: imageController,
                                    priceController: priceController,
                                    categoryController: categoryController,
                                    onSubmit: () => updateBook(book.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Color.fromARGB(255, 245, 2, 2)),
                          onPressed: () {
                            showDeleteConfirmationDialog(book.id); // Show delete confirmation
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



class BookForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController authorController;
  final TextEditingController descriptionController;
  final TextEditingController imageController;
  final TextEditingController priceController;
  final TextEditingController categoryController;
  final Future<void> Function() onSubmit;

  const BookForm({
    super.key,
    required this.titleController,
    required this.authorController,
    required this.descriptionController,
    required this.imageController,
    required this.priceController,
    required this.categoryController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: 'Title'),
        ),
        TextField(
          controller: authorController,
          decoration: InputDecoration(labelText: 'Author'),
        ),
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(labelText: 'Description'),
        ),
        TextField(
          controller: imageController,
          decoration: InputDecoration(labelText: 'Image URL'),
        ),
        TextField(
          controller: priceController,
          decoration: InputDecoration(labelText: 'Price'),
        ),
        TextField(
          controller: categoryController,
          decoration: InputDecoration(labelText: 'Category'),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: onSubmit,
          child: Text('Submit'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Color(0xFFA65233), 
          ),
        ),
      ],
    );
  }
}

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