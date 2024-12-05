import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inksphere/home.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signIn(String email, String password) async {
    final url = Uri.parse('http://localhost:5000/api/user');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['token'];
      final email = responseData['email'];
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final idUser = decodedToken['_id'];
      print('Connexion réussie, jeton: $token');
      print('user id: $idUser');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('idUser', idUser);
      await prefs.setString('role', responseData['role']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                idUser: idUser, role: responseData['role'], email: email)),
      );
    } else {
      final responseData = json.decode(response.body);
      print('Erreur: ${responseData['message']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 252, 250),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA65233),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: <Widget>[
              Image.asset('assets/logo.png', width: 150, height: 150),
              const SizedBox(height: 10),
              const Text(
                'INKSPHERE\nWelcome!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  //color: Color.fromARGB(255, 47, 123, 123),
                  color: Color(0xFFD96E30),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Entrez votre email',
                    labelStyle: TextStyle(color: Color(0xFF5D8C8C)),
                    hintStyle: TextStyle(color: Color(0xFF5D8C8C)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF5D8C8C)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF5D8C8C)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF29544)),
                    ),
                    prefixIcon: Icon(Icons.email, color: Color(0xFF5D8C8C)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    hintText: 'Entrez votre mot de passe',
                    labelStyle: TextStyle(color: Color(0xFF5D8C8C)),
                    hintStyle: TextStyle(color: Color(0xFF5D8C8C)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF5D8C8C)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF5D8C8C)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF29544)),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF5D8C8C)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  print('Email: $email, Mot de passe: $password');
                  signIn(email, password);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  backgroundColor: const Color(0xFFA65233),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Sign In',
                    style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 246, 236, 224))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
