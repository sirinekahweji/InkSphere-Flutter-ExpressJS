import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Importez le package image_picker
import 'dart:convert';
import 'dart:io'; // Pour manipuler les fichiers image
import 'package:http/http.dart' as http;
import 'package:inksphere/Book.dart';
import 'package:inksphere/details.dart';
import 'package:http/http.dart' show MediaType;


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
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Variable pour stocker l'image sélectionnée
  File? _imageFile;

  final FocusNode _searchFocusNode = FocusNode();

  Future<void> fetchBooks() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.4:5000/api/book'));

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
          .where((book) =>
              book.title
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              book.author
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> addBook() async {
  var uri = Uri.parse('http://192.168.1.4:5000/api/book/add');
  var request = http.MultipartRequest('POST', uri);

  request.fields['title'] = titleController.text;
  request.fields['author'] = authorController.text;
  request.fields['description'] = descriptionController.text;
  request.fields['price'] = priceController.text;
  request.fields['category'] = categoryController.text;

  if (_imageFile != null) {
    var imageBytes = await _imageFile!.readAsBytes();
    var imageMultipart = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: _imageFile!.path.split('/').last, 
    );
    request.files.add(imageMultipart);
  }

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      fetchBooks();
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      throw Exception('Failed to add book');
    }
  } catch (e) {
    Navigator.pop(context);
    print(e);
    throw Exception('Failed to add book');
  }
}


  Future<void> updateBook(String bookId) async {
    final updatedBook = {
      'title': titleController.text,
      'author': authorController.text,
      'description': descriptionController.text,
      'image': _imageFile != null ? base64Encode(_imageFile!.readAsBytesSync()) : '',
      'price': priceController.text,
      'category': categoryController.text,
    };

    final response = await http.put(
      Uri.parse('http://192.168.1.4:5000/api/book/$bookId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedBook),
    );

    if (response.statusCode == 200) {
      fetchBooks();
      Navigator.pop(context);
    } else {
      Navigator.of(context).pop();
      throw Exception('Failed to update book');
    }
  }

  Future<void> showDeleteConfirmationDialog(String bookId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this book?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteBook(bookId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteBook(String bookId) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.4:5000/api/book/$bookId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        books.removeWhere((book) => book.id == bookId);
        filteredBooks = books;
      });
    } else {
      throw Exception('Failed to delete book');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
                SizedBox(
                  width: 300,
                  height: 40,
                  child: TextField(
                    controller: searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: _searchFocusNode.hasFocus
                              ? const Color(0xFF6F4F37)
                              : const Color(0xFFA65233),
                          width: 1,
                        ),
                      ),
                      suffixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFA65233),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            'Add New Book',
                          ),
                          content: BookForm(
                            titleController: titleController,
                            authorController: authorController,
                            descriptionController: descriptionController,
                            priceController: priceController,
                            categoryController: categoryController,
                            imageFile: _imageFile,
                            onImagePick: _pickImage, // Passer la fonction de sélection d'image
                            onSubmit: addBook,
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA65233),
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Add Book'),
                      SizedBox(width: 8),
                      Icon(Icons.add),
                    ],
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(bookdetails: book),
                        ),
                      );
                    },
                    leading: book.image != null
                        ? Image.memory(
                            base64Decode(
                              book.image!
                                  .replaceFirst('data:image/jpeg;base64,', ''),
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
                          icon: const Icon(Icons.edit,
                              color: Color.fromARGB(255, 13, 126, 32)),
                          onPressed: () {
                            titleController.text = book.title;
                            authorController.text = book.author;
                            descriptionController.text = book.description;
                            priceController.text = book.price ?? '';
                            categoryController.text = book.category ?? '';
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Edit Book'),
                                  content: BookForm(
                                    titleController: titleController,
                                    authorController: authorController,
                                    descriptionController:
                                        descriptionController,
                                    priceController: priceController,
                                    categoryController: categoryController,
                                    imageFile: _imageFile,
                                    onImagePick: _pickImage, // Passer la fonction de sélection d'image
                                    onSubmit: () => updateBook(book.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Color.fromARGB(255, 245, 2, 2)),
                          onPressed: () {
                            showDeleteConfirmationDialog(book.id);
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
  final TextEditingController priceController;
  final TextEditingController categoryController;
  final File? imageFile;
  final Future<void> Function() onSubmit;
  final VoidCallback onImagePick;

  const BookForm({
    super.key,
    required this.titleController,
    required this.authorController,
    required this.descriptionController,
    required this.priceController,
    required this.categoryController,
    required this.imageFile,
    required this.onImagePick,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        TextField(
          controller: authorController,
          decoration: const InputDecoration(labelText: 'Author'),
        ),
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        TextField(
          controller: priceController,
          decoration: const InputDecoration(labelText: 'Price'),
        ),
        TextField(
          controller: categoryController,
          decoration: const InputDecoration(labelText: 'Category'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            imageFile != null
                ? Image.file(
                    imageFile!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                : const Text('No image selected'),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: onImagePick,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA65233),
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
