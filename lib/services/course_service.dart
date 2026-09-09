import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course.dart';

class CourseService {
  static Future<List<CourseSection>> loadSections() async {
    final raw = await rootBundle.loadString('assets/course_data.json');
    final json = jsonDecode(raw);
    return (json['sections'] as List)
        .map((s) => CourseSection.fromJson(s))
        .toList();
  }
}
