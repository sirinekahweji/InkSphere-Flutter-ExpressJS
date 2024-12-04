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

  // Fetch users from the backend
  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/user'));

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

  // Filter users based on the search text
  void filterUsers() {
    setState(() {
      filteredUsers = users
          .where((user) => user.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
                          user.email.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  // Add a new user
  Future<void> addUser() async {
    final newUser = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text, // Add password here
    };

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/user/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newUser),
    );

    if (response.statusCode == 200) {
      fetchUsers(); // Refresh the list
      Navigator.pop(context); // Close the form after adding
    } else {
      throw Exception('Failed to add user');
    }
  }

  // Update user information
  Future<void> updateUser(String userId) async {
    final updatedUser = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text, // Add password here
    };

    final response = await http.put(
      Uri.parse('http://localhost:5000/api/user/update/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedUser),
    );

    if (response.statusCode == 200) {
      fetchUsers(); // Refresh the list
      Navigator.pop(context); // Close the form after updating
    } else {
      throw Exception('Failed to update user');
    }
  }

  // Show confirmation dialog for deleting a user
  Future<void> showDeleteConfirmationDialog(String userId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteUser(userId); // Delete the user
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Delete user
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
                Container(
                  width: 300,
                  height: 40,
                  child: TextField(
                    controller: searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Rounded corners
                        borderSide: BorderSide(
                          color: _searchFocusNode.hasFocus ? Color(0xFF6F4F37) : Color(0xFFA65233), // Brown color when focused
                          width: 1,
                        ),
                      ),
                      suffixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFA65233), // Brown icon color
                      ),
                    ),
                  ),
                ),
                // Add User Button
                ElevatedButton(
                  onPressed: () {
                    // Show form for adding a new user
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Add New User'),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Add User'),
                      SizedBox(width: 8),
                      Icon(Icons.add),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA65233),
                    foregroundColor: Colors.white,
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
                    leading: Icon(Icons.account_circle), // Icon before the name
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
                          icon: Icon(Icons.edit, color: Color.fromARGB(255, 13, 126, 32)),
                          onPressed: () {
                            nameController.text = user.name;
                            emailController.text = user.email;
                            passwordController.text = user.password;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Edit User'),
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
                          icon: Icon(Icons.delete, color: Color.fromARGB(255, 245, 2, 2)),
                          onPressed: () {
                            showDeleteConfirmationDialog(user.id); // Show delete confirmation
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
          decoration: InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: onSubmit,
          child: Text('Submit'),
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

  User({required this.id, required this.name, required this.email, required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      password: json['password'], // Include password in the User model
    );
  }
}
