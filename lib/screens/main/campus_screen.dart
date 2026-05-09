import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';

import '../../utils/student_nest_icons.dart';
import 'campus_guide.dart';
import 'campus_guide_sheet.dart';
import 'campus_widgets.dart';

class CampusScreen extends StatelessWidget {
  const CampusScreen({super.key});

  static const _safetyGuide = CampusGuide(
    title: 'Safety checklist',
    subtitle: 'Before paying',
    icon: StudentNestIcons.safety,
    intro: 'Use this before you send money or sign anything.',
    items: [
      'Visit the room in person or ask for a live video tour.',
      'Confirm the landlord or caretaker has authority to rent it out.',
      'Check locks, lighting, windows, and the route back from campus.',
      'Ask whether water, power, Wi-Fi, and security are included.',
      'Do not pay full rent before you have a receipt or written agreement.',
      'Save payment proof, landlord phone number, and property address.',
    ],
  );

  static const _budgetGuide = CampusGuide(
    title: 'Budget planner',
    subtitle: 'Monthly costs',
    icon: StudentNestIcons.payment,
    intro: 'Plan beyond rent so the place stays affordable.',
    items: [
      'Rent per month',
      'Deposit or advance payment',
      'Transport to campus',
      'Food and groceries',
      'Utilities if not included',
      'Laundry, data, and emergency money',
    ],
  );

  static const _viewingGuide = CampusGuide(
    title: 'Viewing day',
    subtitle: 'What to inspect',
    icon: StudentNestIcons.calendar,
    intro: 'A quick room viewing checklist.',
    items: [
      'Open taps and check water pressure.',
      'Test lights, sockets, and phone signal.',
      'Look for leaks, damp walls, and broken windows.',
      'Ask about curfew, visitors, cleaning, and noise rules.',
      'Check distance to transport and campus routes.',
    ],
  );

  static const _moveInGuide = CampusGuide(
    title: 'Move-in kit',
    subtitle: 'Pack the essentials',
    icon: StudentNestIcons.room,
    intro: 'Small things that make the first week easier.',
    items: [
      'Bedding, towel, and toiletries',
      'Extension cable and charger',
      'Padlock or spare lock if allowed',
      'Basic plates, mug, and cutlery',
      'Cleaning cloth, soap, and bucket',
      'Printed or saved emergency contacts',
    ],
  );

  static const _transportGuide = CampusGuide(
    title: 'Transport',
    subtitle: 'Daily movement',
    icon: StudentNestIcons.location,
    intro: 'Think about the daily trip, not only the room.',
    items: [
      'Estimate walking time to campus.',
      'Check taxi or bus availability early and late.',
      'Ask students nearby about regular transport costs.',
      'Avoid routes that feel unsafe after evening classes.',
    ],
  );

  void _showGuide(BuildContext context, CampusGuide guide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CampusGuideSheet(guide: guide),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.page(context),
      appBar: AppBar(
        title: Text(
          'Campus',
          style: TextStyle(
            color: AppDesign.text(context),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppDesign.surface(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StudentNestIcon(
              StudentNestIcons.notifications,
              size: 21,
              color: AppDesign.text(context),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const CampusHeroCard(),
          const SizedBox(height: 16),
          CampusQuickActions(
            guides: const [
              _safetyGuide,
              _viewingGuide,
              _moveInGuide,
              _transportGuide,
            ],
            onGuideTap: (guide) => _showGuide(context, guide),
          ),
          const SizedBox(height: 16),
          CampusListRow(
            guide: _safetyGuide,
            onTap: () => _showGuide(context, _safetyGuide),
          ),
          const SizedBox(height: 10),
          CampusListRow(
            guide: _budgetGuide,
            onTap: () => _showGuide(context, _budgetGuide),
          ),
        ],
      ),
    );
  }
}
