import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State {
  List<Map<String, dynamic>> opportunities = [];
  List<Map<String, dynamic>> filteredOpportunities = [];
  bool isLoading = true;
  final supabase = Supabase.instance.client;
  String? currentUserId;
  bool isAdmin = false;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadOpportunities();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Handle search text changes
  void _onSearchChanged() {
    _filterOpportunities(_searchController.text);
  }

  // Filter opportunities based on search query
  void _filterOpportunities(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredOpportunities = opportunities;
      } else {
        filteredOpportunities = opportunities.where((opportunity) {
          final title = opportunity['title']?.toString().toLowerCase() ?? '';
          final company = opportunity['company']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          return title.contains(searchQuery) || company.contains(searchQuery);
        }).toList();
      }
    });
  }

  // Toggle search mode
  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        _searchController.clear();
        filteredOpportunities = opportunities;
      }
    });
  }

  // Get current user and check if admin
  Future<void> _getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        currentUserId = user.id;
        
        // Check if user is admin - you can implement this based on your admin system
        // For now, we'll disable admin functionality until you add a role column
        // or implement a different admin check method
        
        // Option 1: Check if profiles table has role column
        // try {
        //   final profileResponse = await supabase
        //       .from('profiles')
        //       .select('role')
        //       .eq('id', user.id)
        //       .single();
        //   
        //   setState(() {
        //     isAdmin = profileResponse['role'] == 'admin';
        //   });
        // } catch (e) {
        //   // Role column doesn't exist, set isAdmin to false
        //   setState(() {
        //     isAdmin = false;
        //   });
        // }
        
        // Option 2: Check against a list of admin user IDs
        // const adminUserIds = ['your-admin-user-id-here'];
        // setState(() {
        //   isAdmin = adminUserIds.contains(user.id);
        // });
        
        // Option 3: For now, disable admin functionality
        setState(() {
          isAdmin = false;
        });
      }
    } catch (e) {
      // Handle error silently or log it
      print('Error getting user: $e');
    }
  }

  // Load opportunities from Supabase
  Future<void> _loadOpportunities() async {
    try {
      setState(() => isLoading = true);
      
      final response = await supabase
          .from('opportunities')
          .select('id, title, company, location, salary, url, created_at, created_by')
          .order('created_at', ascending: false);
      
      setState(() {
        opportunities = List<Map<String, dynamic>>.from(response);
        filteredOpportunities = opportunities;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading opportunities: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching 
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search by company or role...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
              )
            : const Text('Opportunities'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOpportunities,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredOpportunities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchController.text.isNotEmpty ? Icons.search_off : Icons.work_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isNotEmpty 
                            ? 'No opportunities found'
                            : 'No opportunities available',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchController.text.isNotEmpty 
                            ? 'Try searching with different keywords'
                            : 'Be the first to add an opportunity!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_searchController.text.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            _searchController.clear();
                            _filterOpportunities('');
                          },
                          child: const Text('Clear Search'),
                        ),
                      ],
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search results info
                    if (_searchController.text.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: Colors.grey[100],
                        child: Text(
                          'Found ${filteredOpportunities.length} result${filteredOpportunities.length == 1 ? '' : 's'} for "${_searchController.text}"',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    // Opportunities list
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadOpportunities,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOpportunities.length,
                          itemBuilder: (context, index) {
                            final opportunity = filteredOpportunities[index];
                            return _buildOpportunityCard(context, opportunity);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOpportunityDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Show dialog to add new opportunity
  void _showAddOpportunityDialog(BuildContext context) {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final locationController = TextEditingController();
    final salaryController = TextEditingController();
    final urlController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Opportunity'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title/Role *',
                        hintText: 'e.g., Software Developer',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: companyController,
                      decoration: const InputDecoration(
                        labelText: 'Company *',
                        hintText: 'e.g., Google Inc.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location *',
                        hintText: 'e.g., New York, NY or Remote',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: salaryController,
                      decoration: const InputDecoration(
                        labelText: 'Salary *',
                        hintText: 'e.g., \$4,000/month or Free',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: 'Application URL *',
                        hintText: 'https://example.com/apply',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSubmitting ? null : () async {
                    if (_validateForm(titleController, companyController, locationController, 
                                   salaryController, urlController)) {
                      setDialogState(() => isSubmitting = true);
                      
                      await _addOpportunity(
                        titleController.text,
                        companyController.text,
                        locationController.text,
                        salaryController.text,
                        urlController.text,
                      );
                      
                      Navigator.of(context).pop();
                    }
                  },
                  child: isSubmitting 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Validate form fields
  bool _validateForm(TextEditingController title, TextEditingController company,
                    TextEditingController location, TextEditingController salary,
                    TextEditingController url) {
    if (title.text.isEmpty || company.text.isEmpty || location.text.isEmpty ||
        salary.text.isEmpty || url.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return false;
    }
    
    // Basic URL validation
    if (!url.text.startsWith('http://') && !url.text.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL (starting with http:// or https://)')),
      );
      return false;
    }
    
    return true;
  }

  // Add new opportunity to Supabase
  Future<void> _addOpportunity(String title, String company, String location,
                      String salary, String url) async {
    try {
      await supabase.from('opportunities').insert({
        'title': title,
        'company': company,
        'location': location,
        'salary': salary,
        'url': url,
        'created_by': currentUserId, // Track who created this opportunity
        'created_at': DateTime.now().toIso8601String(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opportunity added successfully!')),
      );
      
      // Reload opportunities
      _loadOpportunities();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding opportunity: $e')),
      );
    }
  }

  // Delete opportunity
  Future<void> _deleteOpportunity(String opportunityId) async {
    try {
      await supabase
          .from('opportunities')
          .delete()
          .eq('id', opportunityId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opportunity deleted successfully!')),
      );
      
      // Reload opportunities
      _loadOpportunities();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting opportunity: $e')),
      );
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(String opportunityId, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Opportunity'),
          content: Text('Are you sure you want to delete "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteOpportunity(opportunityId);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Check if user can delete opportunity
  bool _canDeleteOpportunity(Map<String, dynamic> opportunity) {
    if (currentUserId == null) return false;
    
    // Admin can delete any opportunity
    if (isAdmin) return true;
    
    // Creator can delete their own opportunity
    return opportunity['created_by'] == currentUserId;
  }

  Widget _buildOpportunityCard(BuildContext context, Map<String, dynamic> opportunity) {
    final canDelete = _canDeleteOpportunity(opportunity);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Company with Delete Button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity['title'] ?? 'No Title',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opportunity['company'] ?? 'No Company',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(
                      opportunity['id'],
                      opportunity['title'] ?? 'this opportunity',
                    ),
                    tooltip: 'Delete opportunity',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Location
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    opportunity['location'] ?? 'No location',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Salary
            Row(
              children: [
                Icon(Icons.attach_money, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    opportunity['salary'] ?? 'Not specified',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Created date
            Row(
              children: [
                Icon(Icons.schedule, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _formatDate(opportunity['created_at']),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Apply button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openOpportunityUrl(opportunity['url']),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format created_at date
  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return 'Unknown date';
    
    try {
      final date = DateTime.parse(createdAt.toString());
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  // Function to open opportunity URLs
  void _openOpportunityUrl(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No application URL available')),
      );
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening URL: $e')),
      );
    }
  }
}



