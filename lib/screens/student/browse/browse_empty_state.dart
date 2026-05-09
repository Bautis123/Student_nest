import 'package:flutter/material.dart';
import 'package:student_nest/core/widgets/sn_empty_state.dart';

class BrowseEmptyState extends StatelessWidget {
  const BrowseEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const SNEmptyState(
      icon: Icons.home_work_outlined,
      title: 'No listings found',
      subtitle: 'Try changing your search, school, or filters.',
    );
  }
}
