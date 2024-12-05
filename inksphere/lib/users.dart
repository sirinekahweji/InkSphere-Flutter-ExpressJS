import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Users extends StatefulWidget {
  final dynamic idUser;

  const Users({super.key, required this.idUser});

  @override
  State<Users> createState() => _UsersPageState();
}

class _UsersPageState extends State<Users> {
  List<User> users = [];
  List<User> filteredUsers = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  Future<void> fetchUsers() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/api/user'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        users = data.map((json) => User.fromJson(json)).toList();
        filteredUsers = users;
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  void filterUsers() {
    setState(() {
      filteredUsers = users
          .where((user) =>
              user.name
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              user.email
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> addUser() async {
    final newUser = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
    };

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/user/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newUser),
    );

    if (response.statusCode == 200) {
      fetchUsers();
      clearForm();
    } else {
      throw Exception('Failed to add user');
    }
    Navigator.pop(context);
  }

  Future<void> updateUser(String userId) async {
    final updatedUser = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
    };

    final response = await http.put(
      Uri.parse('http://localhost:5000/api/user/update/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedUser),
    );

    if (response.statusCode == 200) {
      fetchUsers();
      clearForm();
    } else {
      throw Exception('Failed to update user');
    }
    Navigator.pop(context);
  }

  Future<void> showDeleteConfirmationDialog(String userId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this user?'),
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
                deleteUser(userId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  Future<void> deleteUser(String userId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:5000/api/user/delete/$userId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        users.removeWhere((user) => user.id == userId);
        filteredUsers = users;
      });
    } else {
      throw Exception('Failed to delete user');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
    searchController.addListener(filterUsers);
  }

  @override
  void dispose() {
    searchController.removeListener(filterUsers);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Users',
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
                // Search TextField
                SizedBox(
                  width: 300,
                  height: 40,
                  child: TextField(
                    controller: searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Color(0xFF6F4F37),
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
                          title: const Text('Add New User'),
                          content: UserForm(
                            nameController: nameController,
                            emailController: emailController,
                            passwordController: passwordController,
                            onSubmit: addUser,
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
                      Text('Add User'),
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
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 5,
                  child: ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: Text(
                      user.name,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      user.email,
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
                            nameController.text = user.name;
                            emailController.text = user.email;
                            passwordController.text = user.password;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Edit User'),
                                  content: UserForm(
                                    nameController: nameController,
                                    emailController: emailController,
                                    passwordController: passwordController,
                                    onSubmit: () => updateUser(user.id),
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
                            showDeleteConfirmationDialog(user.id);
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

class UserForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Future<void> Function() onSubmit;

  const UserForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onSubmit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

// User class to represent user data
class User {
  final String id;
  final String name;
  final String email;
  final String password;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }
}
