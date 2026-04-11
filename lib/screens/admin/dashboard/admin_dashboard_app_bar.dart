import 'package:flutter/material.dart';

class AdminDashboardAppBar extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;

  const AdminDashboardAppBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarColor = theme.appBarTheme.backgroundColor ?? colorScheme.primary;
    final onAppBar = theme.appBarTheme.foregroundColor ?? colorScheme.onPrimary;

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: appBarColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: appBarColor,
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Panel',
                style: TextStyle(
                  color: onAppBar,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Bautis Digital Innovations',
                style: TextStyle(
                  color: onAppBar.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: onAppBar.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: controller,
                  indicatorColor: onAppBar,
                  labelColor: onAppBar,
                  unselectedLabelColor: onAppBar.withValues(alpha: 0.6),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: tabs,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
