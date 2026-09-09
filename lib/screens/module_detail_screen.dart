import 'package:flutter/material.dart';
import '../models/course.dart';
import 'subscription_screen.dart';

class ModuleDetailScreen extends StatelessWidget {
  final CourseModule module;
  final bool unlocked;

  const ModuleDetailScreen(
      {super.key, required this.module, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(module.title)),
      body: unlocked
          ? ListView.separated(
              itemCount: module.lessons.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final lesson = module.lessons[i];
                return ListTile(
                  leading: Icon(lesson.type == 'quiz'
                      ? Icons.quiz
                      : Icons.menu_book),
                  title: Text(lesson.title),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('باز کردن: ${lesson.title}')),
                    );
                  },
                );
              },
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('برای دسترسی به این ماژول باید اشتراک بخری'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SubscriptionScreen()),
                        );
                      },
                      child: const Text('خرید اشتراک'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
