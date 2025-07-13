import 'package:flutter/material.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State {
  String selectedType = 'All';
  final List types = ['All', 'Internship', 'Job', 'Research', 'Event', 'Workshop'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunities'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Type Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: types.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16 : 8,
                    right: index == types.length - 1 ? 16 : 0,
                  ),
                  child: FilterChip(
                    label: Text(types[index]),
                    selected: selectedType == types[index],
                    onSelected: (selected) {
                      setState(() {
                        selectedType = types[index];
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Opportunities List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildOpportunityCard(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(BuildContext context, int index) {
    final opportunities = [
      {
        'title': 'Software Engineering Internship',
        'company': 'Tech Innovators Inc.',
        'type': 'Internship',
        'location': 'San Francisco, CA',
        'deadline': '3 days left',
        'salary': '\$3,000/month',
        'urgent': true,
      },
      {
        'title': 'Data Science Research Assistant',
        'company': 'University Research Lab',
        'type': 'Research',
        'location': 'Cambridge, MA',
        'deadline': '2 weeks left',
        'salary': '\$2,500/month',
        'urgent': false,
      },
      {
        'title': 'Machine Learning Workshop',
        'company': 'AI Academy',
        'type': 'Workshop',
        'location': 'Online',
        'deadline': '5 days left',
        'salary': 'Free',
        'urgent': false,
      },
    ];

    final opportunity = opportunities[index % opportunities.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opportunity['company'] as String,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (opportunity['urgent'] as bool)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(
                    opportunity['type'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  opportunity['location'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  opportunity['salary'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  opportunity['deadline'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.info),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                    label: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
