import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'books_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameC = TextEditingController();
  final TextEditingController _passwordC = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn && mounted) {
      final username = prefs.getString('username') ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BooksPage(username: username)),
      );
    }
  }

  Future<void> _login() async {
    final username = _usernameC.text.trim();
    final password = _passwordC.text.trim();

    if (username.length < 5) {
      setState(() {
        _errorMessage = 'Username minimal 5 karakter!';
      });
      return;
    }

    const String nim = '123230137';

    if (password == nim) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BooksPage(username: username)),
      );
    } else {
      setState(() {
        _errorMessage = 'Password salah! Gunakan NIM kamu.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harry Potter App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: Colors.amber),
            const SizedBox(height: 30),

            TextField(
              controller: _usernameC,
              decoration: InputDecoration(
                labelText: 'Username',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
                errorText: _errorMessage != null &&
                        _errorMessage!.contains('Username')
                    ? _errorMessage
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordC,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password (NIM)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                errorText: _errorMessage != null &&
                        !_errorMessage!.contains('Username')
                    ? _errorMessage
                    : null,
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: _login,
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}