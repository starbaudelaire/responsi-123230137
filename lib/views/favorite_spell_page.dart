import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/spell.dart';

class FavoriteSpellPage extends StatefulWidget {
  final String username;
  final FlutterLocalNotificationsPlugin notifPlugin;
  final VoidCallback onRemoved;

  const FavoriteSpellPage({
    super.key,
    required this.username,
    required this.notifPlugin,
    required this.onRemoved,
  });

  @override
  State<FavoriteSpellPage> createState() => _FavoriteSpellPageState();
}

class _FavoriteSpellPageState extends State<FavoriteSpellPage> {
  late Box<Spell> _favBox;
  List<MapEntry<dynamic, Spell>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _favBox = Hive.box<Spell>('favorite_spells');
    _loadFavorites();
  }

  void _loadFavorites() {
    final entries = _favBox.toMap().entries
        .where((e) => e.key.toString().startsWith('${widget.username}_'))
        .map((e) => MapEntry(e.key, e.value))
        .toList();
    setState(() {
      _favorites = entries;
    });
  }

  Future<void> _removeSpell(dynamic key, Spell spell) async {
    await _favBox.delete(key);
    _loadFavorites();
    widget.onRemoved();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'fav_channel',
      'Favorite Spells',
      channelDescription: 'Notifikasi favorite spell',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);
    await widget.notifPlugin.show(
      id: 0,
      title: 'Favorit Dihapus!',
      body: '${spell.spell} telah dihapus dari daftar favorit.',
      notificationDetails: details,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Spell'),
      ),
      body: _favorites.isEmpty
          ? const Center(child: Text('Belum ada spell favorit nih!'))
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final entry = _favorites[index];
                final spell = entry.value;
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
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeSpell(entry.key, spell),
                    ),
                  ),
                );
              },
            ),
    );
  }
}