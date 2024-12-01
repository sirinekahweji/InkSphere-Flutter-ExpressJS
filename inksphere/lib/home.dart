import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    List<Book> books = [];
  Future<void> fetchBooks() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/book'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        books = data.map((json) => Book.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load books');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA65233),

        leading: Image.asset(
          'assets/logo.png',
          height: 60,
        ),
        title: Text(
          'InkSphere',
          style: GoogleFonts.lobster(
            fontSize: 30, 
            fontWeight: FontWeight.bold, 
            color: Colors.white, 
          ),
        ),

        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white), 
            onPressed: () {
            },
          ),
        ],
      ),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '"I do believe something very magical can happen when you read a good book."',
              style: GoogleFonts.lobster(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            // Liste des livres
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(2.0),
                      leading: book.image != null
                          ? Image.memory(
                              base64Decode(
                                book.image!.replaceFirst('data:image/jpeg;base64,', ''),
                              ),
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
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
                      onTap: () {
                        // Vous pouvez ajouter ici un comportement quand un livre est sélectionné
                      },
                    ),
                  );
                },
              ),
            ),
          ]))
    );
  }
}

class Book {
  final String title;
  final String author;
  final String? image;

  Book({
    required this.title,
    required this.author,
    this.image,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      image: json['image'],
    );
  }
}
