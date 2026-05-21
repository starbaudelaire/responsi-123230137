import 'package:hive/hive.dart';

part 'spell.g.dart';

@HiveType(typeId: 0)
class Spell extends HiveObject {
  @HiveField(0)
  final String spell;

  @HiveField(1)
  final String use;

  @HiveField(2)
  final int index;

  Spell({required this.spell, required this.use, required this.index});

  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      spell: json['spell'] ?? '',
      use: json['use'] ?? '',
      index: json['index'] ?? 0,
    );
  }
}