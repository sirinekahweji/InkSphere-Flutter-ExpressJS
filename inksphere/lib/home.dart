import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
      body: const Center(
        child: Text('Bienvenue à la page d\'accueil'),
      ),
    );
  }
}
