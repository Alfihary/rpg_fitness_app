import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/app_database.dart';
import '../features/rpg/game_engine.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final gameEngineProvider = Provider<GameEngine>((ref) {
  final db = ref.watch(databaseProvider);
  return GameEngine(db);
});
