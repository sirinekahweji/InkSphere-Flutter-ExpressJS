import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inksphere/home.dart';
import 'package:inksphere/main.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signUp() async {
    final url = Uri.parse('http://192.168.1.2:5000/api/user/signup');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
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
            builder: (context) => MyApp()),
      );
    } else {
      final responseData = json.decode(response.body);
      print('Error: ${responseData['message']}');
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
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: <Widget>[
              Image.asset('assets/logo.png', width: 150, height: 150),
              const SizedBox(height: 5),
              const Text(
                'INKSPHERE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD96E30),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
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
                    prefixIcon: Icon(Icons.person, color: Color(0xFF5D8C8C)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
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
                    labelText: 'Password',
                    hintText: 'Enter your password',
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
                onPressed: signUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  backgroundColor: const Color(0xFFA65233),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 246, 236, 224),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
