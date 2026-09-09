import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import '../services/api_service.dart';
import 'module_detail_screen.dart';
import 'subscription_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CourseSection> _sections = [];
  bool _isSubscribed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sections = await CourseService.loadSections();
    final subscribed = await ApiService.checkSubscription();
    setState(() {
      _sections = sections;
      _isSubscribed = subscribed;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('امنیت سایبری از صفر تا صد')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!_isSubscribed)
              Card(
                color: Colors.amber.shade50,
                child: ListTile(
                  title: const Text('اشتراک فعال نیست'),
                  subtitle: const Text('برای دسترسی به همه ماژول‌ها اشتراک بخر'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SubscriptionScreen()),
                      );
                      _load();
                    },
                    child: const Text('خرید اشتراک'),
                  ),
                ),
              ),
            for (final section in _sections) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(section.label,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              for (final module in section.modules)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${module.id}')),
                    title: Text(module.title),
                    subtitle: Text(module.subtitle),
                    trailing: (module.free || _isSubscribed)
                        ? const Icon(Icons.lock_open, color: Colors.teal)
                        : const Icon(Icons.lock, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ModuleDetailScreen(
                            module: module,
                            unlocked: module.free || _isSubscribed,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
