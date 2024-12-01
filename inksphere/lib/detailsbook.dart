
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inksphere/home.dart';

class BookDetailsPage extends StatelessWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              book.image != null
                  ? Image.memory(
                      base64Decode(
                        book.image!.replaceFirst('data:image/jpeg;base64,', ''),
                      ),
                      width: 150,
                      height: 150,
                    )
                  : const SizedBox.shrink(),
              SizedBox(height: 20),
              Text(
                book.title,
                style: GoogleFonts.lato(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color:const Color.fromARGB(255, 116, 46, 17) ),
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
              SizedBox(height: 20),
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
     )
    );
  }
}
