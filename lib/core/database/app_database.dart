import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'rpg.db'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [
  Routines,
  RoutineExercises,
  WeeklyPlan,
  Workouts,
  WorkoutSets,
  UserStatsTable,
  NutritionLogs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 10;
}

class Routines extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class RoutineExercises extends Table {
  TextColumn get id => text()();
  TextColumn get routineId => text()();
  TextColumn get name => text()();
  TextColumn get muscleGroup => text()(); // 🔥 NUEVO

  IntColumn get targetSets => integer()();
  IntColumn get suggestedMinReps => integer()(); // 🔥 solo guía
  IntColumn get suggestedMaxReps => integer()(); // 🔥 solo guía
  BoolColumn get hasDropSet => boolean()();
  IntColumn get restSeconds => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class WeeklyPlan extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get monday => text().nullable()();
  TextColumn get tuesday => text().nullable()();
  TextColumn get wednesday => text().nullable()();
  TextColumn get thursday => text().nullable()();
  TextColumn get friday => text().nullable()();
  TextColumn get saturday => text().nullable()();
  TextColumn get sunday => text().nullable()();
}

class Workouts extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get routineId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutSets extends Table {
  TextColumn get id => text()();
  TextColumn get workoutId => text()();
  TextColumn get exerciseId => text()(); // 🔥 NUEVO

  IntColumn get reps => integer()();
  RealColumn get weight => real()();

  IntColumn get setNumber => integer()(); // 🔥
  IntColumn get restSeconds => integer()(); // 🔥
  BoolColumn get isDropSet => boolean()(); // 🔥

  @override
  Set<Column> get primaryKey => {id};
}

class UserStatsTable extends Table {
  TextColumn get id => text()();

  // 🔥 CORE RPG
  IntColumn get xp => integer()();
  IntColumn get level => integer()();

  // 🔥 FITNESS STATS
  IntColumn get strength => integer()();
  IntColumn get endurance => integer()();
  IntColumn get agility => integer()();
  IntColumn get aesthetics => integer()();
  IntColumn get power => integer()();

  // 🔥 META SYSTEM (hábitos / vida)
  IntColumn get discipline => integer()(); // hábitos
  IntColumn get balance => integer()(); // nutrición / estilo de vida

  IntColumn get streak =>
      integer().withDefault(const Constant(0))(); //streak diario

  @override
  Set<Column> get primaryKey => {id};
}

class NutritionLogs extends Table {
  TextColumn get id => text()();
  TextColumn get mealType => text()(); // breakfast, lunch...
  IntColumn get calories => integer()();
  IntColumn get protein => integer()();
  IntColumn get carbs => integer()();
  IntColumn get fats => integer()();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
