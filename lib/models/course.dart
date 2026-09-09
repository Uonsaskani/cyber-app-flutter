class Lesson {
  final String title;
  final String type; // content | quiz

  Lesson({required this.title, required this.type});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(title: json['title'], type: json['type']);
  }
}

class CourseModule {
  final int id;
  final String title;
  final String subtitle;
  final bool free;
  final List<Lesson> lessons;

  CourseModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.free,
    required this.lessons,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      free: json['free'] ?? false,
      lessons: (json['lessons'] as List)
          .map((l) => Lesson.fromJson(l))
          .toList(),
    );
  }
}

class CourseSection {
  final String label;
  final List<CourseModule> modules;

  CourseSection({required this.label, required this.modules});

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    return CourseSection(
      label: json['label'],
      modules: (json['modules'] as List)
          .map((m) => CourseModule.fromJson(m))
          .toList(),
    );
  }
}
