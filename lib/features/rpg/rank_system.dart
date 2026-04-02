String getRank({
  required int strength,
  required int discipline,
  required int consistency,
  required int balance,
}) {
  double score =
      strength * 0.3 + discipline * 0.25 + consistency * 0.25 + balance * 0.2;

  if (score < 10) return "E";
  if (score < 20) return "D";
  if (score < 35) return "C";
  if (score < 50) return "B";
  if (score < 70) return "A";
  if (score < 90) return "S";
  if (score < 120) return "SS";
  return "SSS";
}
