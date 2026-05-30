import 'package:flutter/material.dart';
import '../../../shared/widgets/menu_item.dart';
import '../../../shared/widgets/section_header.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        children: [
          const SectionHeader(
            title: 'GET HELP',
            subtitle: 'Find answers and support',
          ),
          MenuItem(
            icon: Icons.help_outline,
            title: 'FAQ',
            subtitle: 'Frequently asked questions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FAQScreen(),
                ),
              );
            },
          ),
          MenuItem(
            icon: Icons.email_outlined,
            title: 'Contact Support',
            subtitle: 'Get in touch with our team',
            onTap: () {
              _showContactSupportDialog(context);
            },
          ),
          MenuItem(
            icon: Icons.bug_report_outlined,
            title: 'Report a Problem',
            subtitle: 'Let us know about issues',
            onTap: () {
              _showReportProblemDialog(context);
            },
          ),
          const SectionHeader(
            title: 'RESOURCES',
          ),
          MenuItem(
            icon: Icons.school_outlined,
            title: 'App Tutorial',
            subtitle: 'Learn how to use the app',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tutorial feature coming soon')),
              );
            },
          ),
          MenuItem(
            icon: Icons.book_outlined,
            title: 'Community Guidelines',
            subtitle: 'Learn about our community rules',
            onTap: () {
              _showGuidelinesDialog(context);
            },
          ),
          MenuItem(
            icon: Icons.chat_outlined,
            title: 'Feature Requests',
            subtitle: 'Suggest new features',
            onTap: () {
              _showFeatureRequestDialog(context);
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text(
          'You can reach our support team at:\n\nsupport@communityapp.com\n\nWe typically respond within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening email app...')),
              );
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _showReportProblemDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Problem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please describe the issue you\'re experiencing:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the problem...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Problem report submitted. Thank you!')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showGuidelinesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Community Guidelines'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Be respectful and kind to all members\n\n'
            '2. No harassment, bullying, or hate speech\n\n'
            '3. Keep conversations appropriate\n\n'
            '4. Respect privacy and confidentiality\n\n'
            '5. No spam or self-promotion\n\n'
            '6. Report inappropriate behavior\n\n'
            '7. Follow local laws and regulations\n\n'
            'Violation of these guidelines may result in account suspension.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  void _showFeatureRequestDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feature Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tell us what feature you\'d like to see:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the feature...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature request submitted. Thanks for your feedback!')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
      ),
      body: ListView(
        children: const [
          FAQItem(
            question: 'How do I find nearby users?',
            answer: 'Navigate to the "Nearby" tab to see users in your vicinity. Make sure location services are enabled.',
          ),
          FAQItem(
            question: 'How do I join a community?',
            answer: 'Go to the "Communities" tab, browse available communities, and tap "Join" on any community that interests you.',
          ),
          FAQItem(
            question: 'How do I send a message?',
            answer: 'Tap on any user from the Nearby or Communities section to start a chat.',
          ),
          FAQItem(
            question: 'How do I change my profile picture?',
            answer: 'Go to Profile > Edit Profile (pencil icon) > tap on your profile picture to change it.',
          ),
          FAQItem(
            question: 'How do I block someone?',
            answer: 'Open a chat with the user, tap the three dots menu, and select "Block User".',
          ),
          FAQItem(
            question: 'Is my data secure?',
            answer: 'Yes! We use industry-standard encryption and security measures to protect your data.',
          ),
          FAQItem(
            question: 'How do I delete my account?',
            answer: 'Go to Profile > Account Settings > Delete Account. Note: This action is permanent.',
          ),
        ],
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Text(
              widget.answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        Divider(height: 1, color: Colors.grey[300]),
      ],
    );
  }
}
