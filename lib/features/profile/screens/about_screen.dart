import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../shared/widgets/menu_item.dart';
import '../../../shared/widgets/section_header.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _version = '1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          // App Logo/Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.groups,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Community Chat',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Version $_version',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const SectionHeader(
            title: 'LEGAL',
          ),
          MenuItem(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms and conditions',
            onTap: () {
              _showTermsOfService();
            },
          ),
          MenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Learn how we protect your data',
            onTap: () {
              _showPrivacyPolicy();
            },
          ),
          MenuItem(
            icon: Icons.gavel_outlined,
            title: 'Licenses',
            subtitle: 'Open source licenses',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Community Chat',
                applicationVersion: _version,
                applicationIcon: const Icon(Icons.groups),
              );
            },
          ),
          const SectionHeader(
            title: 'INFORMATION',
          ),
          MenuItem(
            icon: Icons.code_outlined,
            title: 'Developer',
            subtitle: 'Community Chat Team',
            onTap: null,
            showDivider: false,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '© 2026 Community Chat. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'TERMS OF SERVICE\n\n'
            '1. Acceptance of Terms\n'
            'By accessing and using Community Chat, you accept and agree to be bound by these terms.\n\n'
            '2. User Accounts\n'
            'You are responsible for maintaining the confidentiality of your account and password.\n\n'
            '3. User Conduct\n'
            'You agree to use the service in compliance with all applicable laws and regulations.\n\n'
            '4. Privacy\n'
            'Your use of the service is also governed by our Privacy Policy.\n\n'
            '5. Intellectual Property\n'
            'All content and materials are protected by copyright and other intellectual property rights.\n\n'
            '6. Termination\n'
            'We reserve the right to terminate or suspend your account at our discretion.\n\n'
            '7. Disclaimer\n'
            'The service is provided "as is" without warranties of any kind.\n\n'
            '8. Limitation of Liability\n'
            'We shall not be liable for any indirect, incidental, or consequential damages.\n\n'
            'Last Updated: February 2026',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'PRIVACY POLICY\n\n'
            '1. Information We Collect\n'
            'We collect information you provide directly to us, including name, email, profile picture, and location data.\n\n'
            '2. How We Use Your Information\n'
            '- To provide and maintain our service\n'
            '- To notify you about changes to our service\n'
            '- To provide customer support\n'
            '- To detect and prevent fraud\n\n'
            '3. Data Storage\n'
            'Your data is stored securely on our servers with industry-standard encryption.\n\n'
            '4. Data Sharing\n'
            'We do not sell or share your personal information with third parties except as described in this policy.\n\n'
            '5. Your Rights\n'
            'You have the right to access, update, or delete your personal information at any time.\n\n'
            '6. Location Data\n'
            'We collect location data to show nearby users. You can disable this in your device settings.\n\n'
            '7. Cookies\n'
            'We use cookies and similar technologies to improve your experience.\n\n'
            '8. Security\n'
            'We implement appropriate security measures to protect your data.\n\n'
            '9. Changes to This Policy\n'
            'We may update this policy from time to time. We will notify you of any changes.\n\n'
            'Last Updated: February 2026',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
