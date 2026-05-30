import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../providers/nearby_provider.dart';

class NearbyUsersScreen extends StatefulWidget {
  const NearbyUsersScreen({super.key});

  @override
  State<NearbyUsersScreen> createState() => _NearbyUsersScreenState();
}

class _NearbyUsersScreenState extends State<NearbyUsersScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch nearby users on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NearbyProvider>().fetchNearbyUsers();
    });
  }

  Future<void> _handleRefresh() async {
    await context.read<NearbyProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: Consumer<NearbyProvider>(
        builder: (context, nearbyProvider, child) {
          if (nearbyProvider.isLoading && nearbyProvider.nearbyUsers.isEmpty) {
            return const LoadingIndicator(message: 'Finding nearby users...');
          }

          if (nearbyProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      nearbyProvider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleRefresh,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (nearbyProvider.nearbyUsers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No users nearby',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'There are no users within 50km radius',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: nearbyProvider.nearbyUsers.length,
              itemBuilder: (context, index) {
                final user = nearbyProvider.nearbyUsers[index];
                final distance = nearbyProvider.formatDistance(user);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ProfileAvatar(
                      imageUrl: user.profilePhoto,
                      size: 50,
                      showOnlineStatus: true,
                      isOnline: user.isOnline,
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distance,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (user.bio != null && user.bio!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.bio!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.message,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        // Navigate to chat screen
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: user,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
