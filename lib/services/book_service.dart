import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  final Uri _url = Uri.parse('https://potterapi-fedeperin.vercel.app/en/books');

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(_url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data buku');
    }
  }
}