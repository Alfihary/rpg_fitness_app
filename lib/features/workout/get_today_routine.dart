import '../../core/database/app_database.dart';

class GetTodayRoutine {
  final AppDatabase db;

  GetTodayRoutine(this.db);

  Future<String?> execute() async {
    final today = DateTime.now();
    final plan = await db.select(db.weeklyPlan).getSingleOrNull();

    if (plan == null) return null;

    switch (DateTime.now().weekday) {
      case 1:
        return plan.monday;
      case 2:
        return plan.tuesday;
      case 3:
        return plan.monday;
      case 4:
        return plan.tuesday;
      case 5:
        return plan.monday;
      default:
        return plan.monday;
    }
  }
}
