import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';

class CoalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final MockUser user;
  final List<String> mines;

  const CoalAppBar({
    super.key,
    required this.user,
    this.mines = const ['Sardega OCP', 'Basundhara West OCP', 'Lakhanpur OCP', 'Jhanjra UG'],
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.absoluteBlack,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.amberAccent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.shield, color: AppTheme.nearBlackCoal, size: 20),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CoalGov',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              )),
          Text(user.mineName,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              )),
        ],
      ),
      actions: [
        // Role badge
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.amberAccent),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            user.role.shortLabel,
            style: const TextStyle(
              color: AppTheme.amberAccent,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white54, size: 22),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
