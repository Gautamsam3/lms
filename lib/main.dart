import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'landing_page.dart';
import 'profile_screen.dart';
import 'opportunity_screen.dart';
import 'notes_screen.dart';


//Main Function
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

final supabaseUrl = dotenv.env['SUPABASE_URL'];
final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

if (supabaseUrl == null || supabaseAnonKey == null) {
  throw Exception('Missing required Supabase environment variables');
}

await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
);
  
  runApp(MyApp());
}

final supabase = Supabase.instance.client;
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Notes & Opportunities',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//Main Screen
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State createState() => _MainScreenState();
}

class _MainScreenState extends State {
  int _selectedIndex = 0;

  final List _screens = [
    const HomeScreen(),
    const NotesScreen(),
    const OpportunitiesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Opportunities',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1 || _selectedIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                _showAddDialog(context);
              },
              icon: const Icon(Icons.add),
              label: Text(_selectedIndex == 1 ? 'Add Note' : 'Add Opportunity'),
            )
          : null,
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_selectedIndex == 1 ? 'Add New Note' : 'Add New Opportunity'),
        content: const Text('Feature will be implemented with backend integration.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College Hub'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share knowledge, discover opportunities',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Notes Shared',
                    '1,234',
                    Icons.note,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Opportunities',
                    '89',
                    Icons.work,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Notes Section
            Text(
              'Recent Notes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildNoteCard(context, index);
              },
            ),
            const SizedBox(height: 24),

            // Recent Opportunities Section
            Text(
              'Latest Opportunities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return _buildOpportunityCard(context, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
                       IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, int index) {
    final notes = [
      {'title': 'Data Structures - Chapter 5', 'subject': 'Computer Science', 'author': 'g Doe'},
      {'title': 'Calculus Integration Notes', 'subject': 'Mathematics', 'author': 'Jane Smith'},
      {'title': 'Physics Mechanics Summary', 'subject': 'Physics', 'author': 'Mike Johnson'},
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.note, color: Colors.white),
        ),
        title: Text(notes[index]['title']!),
        subtitle: Text('${notes[index]['subject']} • ${notes[index]['author']}'),
        trailing: IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(BuildContext context, int index) {
    final opportunities = [
      {'title': 'Summer Internship at Tech Corp', 'type': 'Internship', 'deadline': '2 days left'},
      {'title': 'Research Assistant Position', 'type': 'Job', 'deadline': '1 week left'},
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.work, color: Colors.white),
        ),
        title: Text(opportunities[index]['title']!),
        subtitle: Text('${opportunities[index]['type']} • ${opportunities[index]['deadline']}'),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {},
        ),
      ),
    );
  }
}
