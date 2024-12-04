import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inksphere/books.dart';
import 'package:inksphere/detailsbook.dart';
import 'package:inksphere/main.dart';
import 'package:inksphere/mybooks.dart';
import 'package:inksphere/users.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  final String idUser;
  final String role;
  final String email;
  const HomePage(
      {super.key,
      required this.idUser,
      required this.role,
      required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Book> books = [];

  Future<void> fetchBooks() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/api/book/dispo'));

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


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 70,
              height: 70,
            ),
            Text(
              'InkSphere',
              style: GoogleFonts.lobster(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Image.asset(
              'assets/logo.png',
              width: 70,
              height: 70,
            ),
          ],
        ),
        backgroundColor: const Color(0xFFA65233),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                'InkSphere', 
                style: GoogleFonts.lobster(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              accountEmail: Text(widget.email),
              currentAccountPicture: const CircleAvatar(
                backgroundImage:
                    AssetImage('assets/logo.png'), 
              ),

              decoration: const BoxDecoration(
                color: Color(0xFFA65233),
              ),
              margin: EdgeInsets.zero,
            ),
            ListTile(
              title: Text("My Books"),
              leading: Icon(Icons.favorite, color: Color(0xFFA65233)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyBooks(idUser: widget.idUser),
                  ),
                );
              },
            ),
             if (widget.role == 'admin') ...[
              ListTile(
                title: Text("Users"),
                leading: Icon(Icons.person_2, color: Color(0xFFA65233)),
                onTap: () {

                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Users(idUser: widget.idUser),
                  ),
                );
                },
              ),
            ],
            if (widget.role == 'admin') ...[
              ListTile(
                title: Text("Books"),
                leading: Icon(Icons.menu_book, color: Color(0xFFA65233)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Books(idUser: widget.idUser),
                    ),
                  );
                },
              ),
            ],
            
             ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.exit_to_app, color: Color(0xFFA65233)),
              onTap: () {
                logout(); 
              },
            ),
          ],
        ),
      ),
      body: Padding(
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
                                    'data:image/jpeg;base64,', ''),
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
                      onTap: () {
                        print(
                            "ID utilisateur avant détails : ${widget.idUser}");
                        print(
                            "Livre sélectionné avant détails : ${book.title}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailsPage(
                                book: book, idUser: widget.idUser),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String? image;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    this.image,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      image: json['image'],
    );
  }
}
