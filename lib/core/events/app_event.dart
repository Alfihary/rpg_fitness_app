class AppEvent {}

class WorkoutCompletedEvent extends AppEvent {
  final int totalReps;

  WorkoutCompletedEvent({required this.totalReps});
}
