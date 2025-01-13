import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inksphere/Book.dart';
import 'package:inksphere/home.dart';

class DetailsPage extends StatelessWidget {
  final Book bookdetails;

  const DetailsPage({super.key, required this.bookdetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA65233),
        title: Text(
          bookdetails.title,
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
                bookdetails.image != null
                    ? Image.memory(
                        base64Decode(
                          bookdetails.image!
                              .replaceFirst('data:image/jpeg;base64,', ''),
                        ),
                        width: 150,
                        height: 150,
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 20),
                Text(
                  bookdetails.title,
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 116, 46, 17),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Author: ${bookdetails.author}',
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
                        Uri.parse('http://192.168.1.2:5000/api/book/${bookdetails.id}'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({'statu': 0,'userId':''}),
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
                                      ' Book is Available',
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
                            backgroundColor:  Color.fromARGB(255, 6, 104, 86),
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
                    backgroundColor:const Color.fromARGB(255, 6, 104, 86),
                  ),
                  child: const Text(
                    'Available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  bookdetails.description,
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
