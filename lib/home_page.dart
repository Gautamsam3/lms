import 'package:flutter/material.dart';

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

  Widget _buildNoteCard(BuildContext context, int index) {
    final notes = [
      {'title': 'Data Structures - Chapter 5', 'subject': 'Computer Science', 'author': 'John Doe'},
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