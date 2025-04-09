class Sport {
  final String name;
  final List<String> skillLevels;

  Sport({
    required this.name,
    required this.skillLevels,
  });

  static List<Sport> defaultSports = [
    Sport(
      name: 'Volleyball',
      skillLevels: ['Beginner', 'Intermediate', 'Advanced', 'Semi-Pro'],
    ),
    Sport(
      name: 'Basketball',
      skillLevels: ['Beginner', 'Intermediate', 'Advanced', 'Semi-Pro'],
    ),
    Sport(
      name: 'Tennis',
      skillLevels: ['Beginner', 'Intermediate', 'Advanced', 'Competition'],
    ),
    Sport(
      name: 'Ping Pong',
      skillLevels: ['Beginner', 'Intermediate', 'Advanced', 'Competition'],
    ),
    Sport(
      name: 'Football',
      skillLevels: ['Beginner', 'Intermediate', 'Advanced', 'Semi-Pro'],
    ),
    Sport(
      name: 'Swimming',
      skillLevels: ['Beginner', 'Intermediate', 'Advanced', 'Competition'],
    ),
    Sport(
      name: 'Running',
      skillLevels: ['Beginner (5K)', 'Intermediate (10K)', 'Advanced (Half Marathon)', 'Elite (Marathon)'],
    ),
    Sport(
      name: 'Rock Climbing',
      skillLevels: ['Beginner (V0-V2)', 'Intermediate (V3-V5)', 'Advanced (V6-V8)', 'Expert (V9+)'],
    ),
    Sport(
      name: 'Yoga',
      skillLevels: ['Beginner', 'Intermediate', 'Advanced', 'Instructor'],
    ),
    Sport(
      name: 'Boxing',
      skillLevels: ['Beginner', 'Intermediate', 'Advanced', 'Competition'],
    ),
  ];
}