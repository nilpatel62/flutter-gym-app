import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('No user data available'),
        ),
      );
    }

    // Extract user metadata
    final userMetadata = user.userMetadata ?? {};
    final firstName = userMetadata['first_name'] as String? ?? 'N/A';
    final lastName = userMetadata['last_name'] as String? ?? 'N/A';
    final phone = userMetadata['phone'] as String? ?? 'N/A';
    final email = user.email ?? 'N/A';
    final userId = user.id;
    
    // Parse createdAt - it might be a String or DateTime
    DateTime? createdAt;
    try {
      if (user.createdAt != null) {
        if (user.createdAt is String) {
          createdAt = DateTime.parse(user.createdAt as String);
        } else if (user.createdAt is DateTime) {
          createdAt = user.createdAt as DateTime;
        }
      }
    } catch (e) {
      // If parsing fails, createdAt will remain null
      createdAt = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Profile Header Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${firstName[0]}${lastName[0]}'.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Full Name
                        Text(
                          '$firstName $lastName',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Details Section
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 16),
                // Email Card
                _DetailCard(
                  icon: Icons.email,
                  label: 'Email',
                  value: email,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                // Phone Card
                _DetailCard(
                  icon: Icons.phone,
                  label: 'Phone Number',
                  value: phone,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                // Name Cards
                _DetailCard(
                  icon: Icons.person_outline,
                  label: 'First Name',
                  value: firstName,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  icon: Icons.person_outline,
                  label: 'Last Name',
                  value: lastName,
                  color: Colors.purple,
                ),
                const SizedBox(height: 12),
                // Account Created Date
                if (createdAt != null)
                  _DetailCard(
                    icon: Icons.calendar_today,
                    label: 'Member Since',
                    value: _formatDate(createdAt),
                    color: Colors.teal,
                  ),
                const SizedBox(height: 12),
                // User ID (optional, can be hidden if not needed)
                _DetailCard(
                  icon: Icons.fingerprint,
                  label: 'User ID',
                  value: userId.substring(0, 8) + '...',
                  color: Colors.grey,
                ),
                const SizedBox(height: 32),
                // Sign Out Button
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await SupabaseService.signOut();
                        // Navigation will be handled by auth state listener
                      }
                    },
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
