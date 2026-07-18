import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/core/constants/app_colors.dart';
import 'package:fitness_tracker/core/constants/app_routes.dart';

class DashboardFab extends StatelessWidget {
  const DashboardFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push(AppRoutes.addActivity),
      backgroundColor: AppColors.accent,
      elevation: 10,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}
