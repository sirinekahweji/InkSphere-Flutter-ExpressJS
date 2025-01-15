import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inksphere/Book.dart';
import 'package:inksphere/detailsbook.dart';

class MyBooks extends StatefulWidget {
  final dynamic idUser;

  const MyBooks({super.key, required this.idUser});

  @override
  State<MyBooks> createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooks> {
  List<Book> books = [];

  Future<void> fetchBooks() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.2:5000/api/book/user/${widget.idUser}'));

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
        title: Text(
          "My Books",
          style: GoogleFonts.lobster(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '"Once you learn to read, you will be forever free"',
                style: GoogleFonts.lobster(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 5,
                      child: ListTile(
                        leading: book.image != null
                            ? Image.memory(
                                base64Decode(
                                  book.image!.replaceFirst(
                                      'data:application/octet-stream;base64,', ''),
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
                      ),
                    );
                  },
                ),
              ),
            ]),
      ),
    );
  }
}
