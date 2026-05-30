import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/community_model.dart';
import '../providers/community_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'community_chat_screen.dart';
import 'edit_community_screen.dart';
import '../../../core/models/user_model.dart';
import '../../chat/screens/chat_screen.dart';

class CommunityDetailScreen extends StatefulWidget {
  final CommunityModel community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  late CommunityModel _community;
  late bool _isJoined;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _community = widget.community;
    _isJoined = widget.community.isJoined;
  }

  Future<void> _handleJoin() async {
    setState(() => _isLoading = true);
    final provider = context.read<CommunityProvider>();
    final success = await provider.joinCommunity(_community.id);
    if (success && mounted) {
      setState(() {
        _isJoined = true;
        _isLoading = false;
      });
      provider.fetchCommunities();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Joined community successfully!')),
      );
    } else if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join community')),
      );
    }
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityChatScreen(community: _community),
      ),
    );
  }

  Future<void> _openEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditCommunityScreen(community: _community),
      ),
    );
    // If edit was saved, refresh community data from provider
    if (result == true && mounted) {
      final provider = context.read<CommunityProvider>();
      await provider.fetchCommunities();
      final updated = provider.communities.firstWhere(
        (c) => c.id == _community.id,
        orElse: () => _community,
      );
      if (mounted) {
        setState(() {
          _community = updated;
        });
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Community'),
        content: Text(
          'Are you sure you want to delete "${_community.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      final provider = context.read<CommunityProvider>();
      final success = await provider.deleteCommunity(_community.id);
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Community deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete community')),
          );
        }
      }
    }
  }

  void _showMembersSheet() async {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Community Members',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: context.read<CommunityProvider>().fetchCommunityMembers(_community.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No members found'));
                    }
                    final members = snapshot.data!;
                    final currentUserId = context.read<AuthProvider>().currentUser?.id.toString();

                    return ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final memberId = member['id'].toString();
                        final isMe = memberId == currentUserId;
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: member['profilePhoto'] != null
                                ? NetworkImage(member['profilePhoto'])
                                : null,
                            child: member['profilePhoto'] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            member['name'] ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: member['bio'] != null && member['bio'].toString().isNotEmpty
                              ? Text(member['bio'], maxLines: 1, overflow: TextOverflow.ellipsis)
                              : const Text('No bio yet'),
                          trailing: isMe
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('You', style: TextStyle(color: theme.colorScheme.primary, fontSize: 11)),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                                  color: theme.colorScheme.primary,
                                  onPressed: () {
                                    Navigator.pop(context); // Close sheet
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          otherUser: UserModel(
                                            id: memberId,
                                            name: member['name'] ?? 'User',
                                            email: member['email'] ?? '',
                                            profilePhoto: member['profilePhoto'],
                                            isOnline: member['isOnline'] ?? false,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _isCreator {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    return currentUserId != null &&
        _community.createdBy != null &&
        currentUserId.toString() == _community.createdBy.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            actions: [
              if (_isCreator)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'edit') _openEdit();
                    if (value == 'delete') _handleDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Edit Community'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete Community', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _community.cover != null
                  ? Image.network(
                      _community.cover!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultBanner(theme),
                    )
                  : _buildDefaultBanner(theme),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Community Icon / Logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 1.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _community.logo != null
                            ? Image.network(
                                _community.logo!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildDefaultLogoWidget(theme),
                              )
                            : _buildDefaultLogoWidget(theme),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _community.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                             GestureDetector(
                               onTap: _showMembersSheet,
                               child: MouseRegion(
                                 cursor: SystemMouseCursors.click,
                                 child: Row(
                                   children: [
                                     const Icon(Icons.people_rounded, size: 16, color: Colors.grey),
                                     const SizedBox(width: 4),
                                     Text(
                                       '${_community.membersCount} members (View all)',
                                       style: theme.textTheme.bodyMedium?.copyWith(
                                         color: theme.colorScheme.primary,
                                         fontWeight: FontWeight.w600,
                                         decoration: TextDecoration.underline,
                                       ),
                                     ),
                                     const SizedBox(width: 10),
                                     Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                       decoration: BoxDecoration(
                                         color: _community.type == 'public'
                                             ? Colors.green.withOpacity(0.12)
                                             : Colors.orange.withOpacity(0.12),
                                         borderRadius: BorderRadius.circular(6),
                                       ),
                                       child: Text(
                                         _community.type.toUpperCase(),
                                         style: TextStyle(
                                           fontSize: 10,
                                           fontWeight: FontWeight.bold,
                                           color: _community.type == 'public'
                                               ? Colors.green
                                               : Colors.orange,
                                         ),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                            if (_community.category.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _community.category,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _isJoined
                            ? ElevatedButton.icon(
                                onPressed: _openChat,
                                icon: const Icon(Icons.chat_bubble_outline_rounded),
                                label: const Text('Open Chat'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: _handleJoin,
                                icon: const Icon(Icons.group_add_rounded),
                                label: const Text('Join Community'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // About section
                  Text(
                    'About',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _community.description,
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Info',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.category_rounded, 'Category', _community.category, theme),
                  _buildInfoRow(Icons.public_rounded, 'Type', _community.type.toUpperCase(), theme),
                  _buildInfoRow(Icons.radar_rounded, 'Radius', '${_community.radius.toStringAsFixed(1)} km', theme),
                  GestureDetector(
                    onTap: _showMembersSheet,
                    child: _buildInfoRow(
                      Icons.people_rounded, 
                      'Members', 
                      '${_community.membersCount} (Tap to view)', 
                      theme,
                    ),
                  ),
                  if (_community.creatorName != null)
                    _buildInfoRow(Icons.person_rounded, 'Created by', _community.creatorName!, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultBanner(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.people_rounded, size: 72, color: Colors.white.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildDefaultLogoWidget(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Text(
          _community.name.isNotEmpty ? _community.name[0].toUpperCase() : 'C',
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
