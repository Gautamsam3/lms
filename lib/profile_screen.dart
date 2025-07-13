import 'package:flutter/material.dart';
import 'main.dart';
import 'landing_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;
  String? _error;


  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }


      // Try to get existing profile
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();


      if (mounted) {
        if (response == null) {
          print('No profile found, creating new one'); // Debug log
          
          // No profile found, create one
          final newProfile = {
            'id': user.id,
            'email': user.email ?? 'No email',
            'full_name': user.userMetadata?['full_name'] ?? 
                        user.userMetadata?['name'] ?? 
                        'Unknown User',
            'course': null,
          };

          try {
            // Insert new profile into database
            final insertedProfile = await supabase
                .from('profiles')
                .insert(newProfile)
                .select()
                .single();
            
            print('Profile created: $insertedProfile'); // Debug log
            
            setState(() {
              _userProfile = insertedProfile;
              _isLoading = false;
            });
          } catch (insertError) {
            print('Insert error: $insertError'); // Debug log
            
            // If insert fails, use temporary profile
            setState(() {
              _userProfile = newProfile;
              _isLoading = false;
            });
          }
        } else {
          
          setState(() {
            _userProfile = response;
            _isLoading = false;
          });
        }
      }
    } catch (error) {
      print('Load profile error: $error'); // Debug log
      
      if (mounted) {
        setState(() {
          _error = 'Failed to load profile: ${error.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      try {
        await supabase.auth.signOut();
        
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signed out successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );

          // Navigate to landing page - replace with your actual landing page route
          // Navigator.of(context).pushNamedAndRemoveUntil(
          //   '/', // Replace with your landing page route name
          //   (route) => false, // Remove all previous routes
          // );
          
          // Alternative: If you're using a specific landing page widget
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false,
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) {
      // Try to get name from user metadata if profile name is empty
      final user = supabase.auth.currentUser;
      final metadataName = user?.userMetadata?['full_name']?.toString() ?? 
                          user?.userMetadata?['name']?.toString() ?? 
                          user?.email?.split('@')[0] ?? 'U';
      name = metadataName;
    }
    
    if (name.isEmpty) return 'U';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile feature coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _error!,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Profile Header
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: Text(
                                    _getInitials(_userProfile?['full_name']),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _userProfile?['full_name']?.toString().isNotEmpty == true 
                                    ? _userProfile!['full_name'].toString()
                                    : supabase.auth.currentUser?.userMetadata?['full_name']?.toString() 
                                    ?? supabase.auth.currentUser?.userMetadata?['name']?.toString()
                                    ?? 'Unknown User',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _userProfile?['course']?.toString().isNotEmpty == true 
                                    ? _userProfile!['course'].toString()
                                    : 'No Course Selected',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: _userProfile?['course']?.toString().isNotEmpty == true 
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _userProfile?['email']?.toString() ?? 
                                  supabase.auth.currentUser?.email ?? 'No Email',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    supabase.auth.currentUser?.emailConfirmedAt != null 
                                        ? 'Verified' 
                                        : 'Unverified',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stats Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(context, 'Notes Shared', '12', Icons.note),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(context, 'Downloads', '456', Icons.download),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(context, 'Applications', '8', Icons.send),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(context, 'Bookmarks', '34', Icons.bookmark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Menu Items
                        Card(
                          child: Column(
                            children: [
                              _buildMenuItem(context, 'My Notes', Icons.note, () {
                                // TODO: Navigate to notes page
                              }),
                              _buildMenuItem(context, 'My Applications', Icons.work, () {
                                // TODO: Navigate to applications page
                              }),
                              _buildMenuItem(context, 'Bookmarks', Icons.bookmark, () {
                                // TODO: Navigate to bookmarks page
                              }),
                              _buildMenuItem(context, 'Settings', Icons.settings, () {
                                // TODO: Navigate to settings page
                              }),
                              _buildMenuItem(context, 'Help & Support', Icons.help, () {
                                // TODO: Navigate to help page
                              }),
                              _buildMenuItem(context, 'About', Icons.info, () {
                                // TODO: Show about dialog
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _signOut,
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
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

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
