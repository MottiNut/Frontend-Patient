import 'package:flutter/material.dart';

class NotificationFilterTabs extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;

  const NotificationFilterTabs({
    super.key,
    required this.controller,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: Colors.blue,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Todas'),
          Tab(text: 'No leídas'),
          Tab(text: 'Hoy'),
        ],
      ),
    );
  }
}