import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spell.dart';

class SpellService {
  final Uri _url = Uri.parse('https://potterapi-fedeperin.vercel.app/en/spells');

  Future<List<Spell>> fetchSpells() async {
    final response = await http.get(_url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Spell.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data spell');
    }
  }
}