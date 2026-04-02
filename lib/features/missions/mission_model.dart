class Mission {
  final String id;
  final String title;
  final String description;
  final int target;
  final String type; // reps, workout, streak

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.type,
  });
}
