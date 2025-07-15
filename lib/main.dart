import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'landing_page.dart';
import 'profile_screen.dart';
import 'opportunity_screen.dart';
import 'notes_screen.dart';
import 'home_page.dart';
//Main Function
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oswbyzlotnshvusgndcg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9zd2J5emxvdG5zaHZ1c2duZGNnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzNzkwMjIsImV4cCI6MjA2Nzk1NTAyMn0.zoOdiJSxX9fCZElu6nCfLobm6IfNi-L40GI_29AX44s',
  );

  runApp(const MyApp());
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
      // floatingActionButton: _selectedIndex == 1 || _selectedIndex == 2
      //     ? FloatingActionButton.extended(
      //         onPressed: () {
      //           _showAddDialog(context);
      //         },
      //         icon: const Icon(Icons.add),
      //         label: Text(_selectedIndex == 1 ? 'Add Note' : 'Add Opportunity'),
      //       )
      //     : null,
    );
  }

//   void _showAddDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(_selectedIndex == 1 ? 'Add New Note' : 'Add New Opportunity'),
//         content: const Text('Feature will be implemented with backend integration.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
}

