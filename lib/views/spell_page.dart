import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/spell.dart';
import '../services/spell_service.dart';
import 'favorite_spell_page.dart';
import 'books_page.dart';
import 'login_page.dart';

class SpellPage extends StatefulWidget {
  final String username;
  const SpellPage({super.key, required this.username});

  @override
  State<SpellPage> createState() => _SpellPageState();
}

class _SpellPageState extends State<SpellPage> {
  final SpellService _service = SpellService();
  
  late Box<Spell> _favBox;
  
  final FlutterLocalNotificationsPlugin _notifPlugin =
      FlutterLocalNotificationsPlugin();

  List<Spell> _spells = [];
  List<Spell> _favoriteSpells = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initNotification();
    _initData();
  }

  Future<void> _initData() async {
    _favBox = Hive.box<Spell>('favorite_spells');
    
    _loadFavorites();
    
    await _fetchSpells();
  }

  Future<void> _initNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _notifPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (_) {},
    );
  }

  Future<void> _fetchSpells() async {
    try {
      final data = await _service.fetchSpells();
      setState(() {
        _spells = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _loadFavorites() {
    final allKeys = _favBox.keys.where((k) => k.toString().startsWith('${widget.username}_'));
    setState(() {
      _favoriteSpells = allKeys
          .map((k) => _favBox.get(k))
          .whereType<Spell>()
          .toList();
    });
  }

  bool _isFavorite(Spell spell) {
    return _favoriteSpells.any((s) => s.spell == spell.spell);
  }

  Future<void> _toggleFavorite(Spell spell) async {
    final key = '${widget.username}_${spell.spell}';
    if (_isFavorite(spell)) {
      await _favBox.delete(key);
      if (!mounted) return;
      setState(() {
        _favoriteSpells.removeWhere((s) => s.spell == spell.spell);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${spell.spell} dihapus dari favorit'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      await _favBox.put(key, spell);
      if (!mounted) return;
      setState(() {
        _favoriteSpells.add(spell);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${spell.spell} ditambahkan ke favorit ❤️'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harry Potter Spells'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoriteSpellPage(
                    username: widget.username,
                    notifPlugin: _notifPlugin,
                    onRemoved: _loadFavorites,
                  ),
                ),
              );
              _loadFavorites();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _spells.length,
              itemBuilder: (context, index) {
                final spell = _spells[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      spell.spell,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(spell.use),
                    trailing: IconButton(
                      icon: Icon(
                        _isFavorite(spell)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _isFavorite(spell) ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => _toggleFavorite(spell),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BooksPage(username: widget.username),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Spells'),
        ],
      ),
    );
  }
}