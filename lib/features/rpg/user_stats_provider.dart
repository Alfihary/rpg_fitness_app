import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

final userStatsStreamProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);

  return db.select(db.userStatsTable).watchSingle();
});
