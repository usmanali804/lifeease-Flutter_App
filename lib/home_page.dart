import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/home_stats_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.calendar_today,
        'label': 'Task Scheduler',
        'route': '/task',
      },
      {'icon': Icons.chat_bubble_outline, 'label': 'Chat', 'route': '/chat'},
      {
        'icon': Icons.self_improvement,
        'label': 'Wellness',
        'route': '/wellness',
      },
      {'icon': Icons.camera_alt, 'label': 'OCR', 'route': '/ocr'},
      {'icon': Icons.language, 'label': 'Languages', 'route': '/languages'},
      {
        'icon': Icons.notifications,
        'label': 'Notifications',
        'route': '/notifications',
      },
      {'icon': Icons.person, 'label': 'Profile', 'route': '/profile'},
      {'icon': Icons.settings, 'label': 'Settings', 'route': '/settings'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeEase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back, Usman 👋',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<HomeStatsProvider>(
                  builder: (context, homeStats, child) {
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildInfoTile('🗓 Tasks', '${homeStats.tasksDue} Due'),
                        _buildInfoTile(
                          '💧 Water',
                          '${homeStats.waterPercent}%',
                        ),
                        _buildInfoTile('😊 Mood', homeStats.mood),
                        _buildInfoTile(
                          '💤 Sleep',
                          '${homeStats.sleepHours} hrs',
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final feature = features[index];
                      return GestureDetector(
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              feature['route'] as String,
                            ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(feature['icon'] as IconData, size: 36),
                                const SizedBox(height: 8),
                                Text(
                                  feature['label'] as String,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: features.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home tab
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on Home, do nothing or refresh
              break;
            case 1:
              Navigator.pushNamed(context, '/task');
              break;
            case 2:
              Navigator.pushNamed(context, '/chat');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
