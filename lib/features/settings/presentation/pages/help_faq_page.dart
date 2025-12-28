import 'package:flutter/material.dart';

class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({super.key});

  static const List<_HelpSection> _sections = [
    _HelpSection(
      title: 'Getting Started',
      items: [
        _FaqItem(
          question: 'How do I set my macro goals?',
          answer:
              'Go to Settings > Update Macro Goals. You can enter custom targets or start with the suggested values.',
        ),
        _FaqItem(
          question: 'Why do I need to complete onboarding?',
          answer:
              'Onboarding sets your baseline goals so the dashboard and planner can tailor recommendations.',
        ),
      ],
    ),
    _HelpSection(
      title: 'Tracking Food',
      items: [
        _FaqItem(
          question: 'How do I log a meal?',
          answer:
              'Use the + button on the bottom bar to add a food entry. You can edit or delete entries from Settings.',
        ),
        _FaqItem(
          question: 'Can I save custom foods?',
          answer:
              'Yes. Open My Foods to add, edit, and favorite your custom entries.',
        ),
      ],
    ),
    _HelpSection(
      title: 'Plans & Insights',
      items: [
        _FaqItem(
          question: 'How does the meal planner work?',
          answer:
              'The planner uses your macro goals to suggest meals. You can regenerate plans until they fit your needs.',
        ),
        _FaqItem(
          question: 'Why does my analysis look empty?',
          answer:
              'Analysis appears once you have enough logged entries for the selected date range.',
        ),
      ],
    ),
    _HelpSection(
      title: 'Account & Security',
      items: [
        _FaqItem(
          question: 'How do I change my password?',
          answer:
              'Go to Settings > Change Password and follow the reset link sent to your email.',
        ),
        _FaqItem(
          question: 'How do I delete my account?',
          answer:
              'Open Settings and select Delete Account under Security. This action is permanent.',
        ),
      ],
    ),
    _HelpSection(
      title: 'Troubleshooting',
      items: [
        _FaqItem(
          question: 'Entries are not syncing. What should I do?',
          answer:
              'Check your internet connection and pull to refresh. If the issue persists, log out and sign back in.',
        ),
        _FaqItem(
          question: 'Notifications are missing.',
          answer:
              'Verify notifications are enabled in your device settings and that reminders are set in the app.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Help & FAQ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find quick answers and tips for getting the most out of NutriTrack.',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 20),
              const _SupportCard(),
              const SizedBox(height: 24),
              ..._sections
                  .map(
                    (section) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _SectionCard(section: section),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF1DD06C),
            child: Icon(Icons.support_agent, color: Colors.black),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need more help?',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6),
                Text(
                  'Reach us at support@nutritrack.app and we will get back within 24 hours.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final _HelpSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...section.items.asMap().entries.map(
                (entry) => Column(
                  children: [
                    if (entry.key != 0)
                      const Divider(color: Colors.white12, height: 16),
                    _FaqTile(item: entry.value),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});

  final _FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 4, bottom: 8),
        collapsedIconColor: Colors.white54,
        iconColor: const Color(0xFF1DD06C),
        title: Text(
          item.question,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        children: [
          Text(
            item.answer,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _HelpSection {
  final String title;
  final List<_FaqItem> items;

  const _HelpSection({required this.title, required this.items});
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
