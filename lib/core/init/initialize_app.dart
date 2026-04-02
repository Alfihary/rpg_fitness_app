import '../database/app_database.dart';

Future<void> initializeApp(AppDatabase db) async {
  final existing = await db.select(db.userStatsTable).get();

  if (existing.isNotEmpty) return;

  await db.into(db.userStatsTable).insert(
        UserStatsTableCompanion.insert(
          id: "user",
          xp: 0,
          level: 1,

          // fitness
          strength: 0,
          endurance: 0,
          agility: 0,
          aesthetics: 0,
          power: 0,

          // meta
          discipline: 0,
          balance: 0,
        ),
      );
}
