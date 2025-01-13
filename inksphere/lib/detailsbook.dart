import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inksphere/Book.dart';
import 'package:inksphere/home.dart';

class BookDetailsPage extends StatelessWidget {
  final Book book;
  final String idUser;

  const BookDetailsPage({super.key, required this.book, required this.idUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA65233),
        title: Text(
          book.title,
          style: GoogleFonts.lobster(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('/ng.png'),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                book.image != null
                    ? Image.memory(
                        base64Decode(
                          book.image!
                              .replaceFirst('data:image/jpeg;base64,', ''),
                        ),
                        width: 150,
                        height: 150,
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 20),
                Text(
                  book.title,
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 116, 46, 17),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Author: ${book.author}',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final response = await http.put(
                        Uri.parse('http://192.168.1.2:5000/api/book/${book.id}'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({'userId': idUser, 'statu': 1}),
                      );

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ' Book borrowed successfully',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 253, 254, 254),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.check_circle,
                                      color: Color.fromARGB(255, 251, 252, 251),
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            backgroundColor: Color.fromARGB(255, 68, 81, 56),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      } else {
                        throw Exception('Failed to borrow book');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Error borrowing the book')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA65233),
                  ),
                  child: const Text(
                    'Borrow Book',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  book.description,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
