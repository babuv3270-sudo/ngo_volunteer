List<String> badgesForHours(int totalHours) {
  final List<String> badges = <String>[];
  if (totalHours >= 1) badges.add('First Step');
  if (totalHours >= 10) badges.add('10 Hour Hero');
  if (totalHours >= 25) badges.add('25 Hour Champion');
  if (totalHours >= 50) badges.add('Community Star');
  if (totalHours >= 100) badges.add('100 Hour Legend');
  return badges;
}

List<String> mergeBadges(List<String> current, int totalHours) {
  final Set<String> merged = Set<String>.from(current);
  merged.addAll(badgesForHours(totalHours));
  return merged.toList();
}