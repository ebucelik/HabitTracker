enum HabitCategory {
  art("Art"),
  finances("Finances"),
  fitness("Fitness"),
  health("Health"),
  nutrition("Nutrition"),
  social("Social"),
  study("Study"),
  work("Work"),
  other("Other"),
  morning("Morning"),
  day("Day"),
  evening("Evening");

  const HabitCategory(this.value);

  final String value;
}
