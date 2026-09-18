import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_role.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import 'sirdar/sirdar_home.dart';
import 'worker/worker_home.dart';
import 'contractor/contractor_home.dart';

import 'shared/permissions_gate.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  /// Each role gets a unique, stable userId so the UDP/Nearby self-filter
  /// (msg[triggeredBy] != _userId) works correctly across different devices.
  String _userIdFor(UserRole role) {
    switch (role) {
      case UserRole.fieldOfficer:
        return 'field_officer_01';
      case UserRole.mineWorker:
        return 'worker_p_kumar';
      case UserRole.contractorSup:
        return 'contractor_a_gupta';
    }
  }

  String _roleKey(UserRole role) {
    switch (role) {
      case UserRole.fieldOfficer:
        return 'sirdar';
      case UserRole.mineWorker:
        return 'worker';
      case UserRole.contractorSup:
        return 'contractor';
    }
  }

  Future<void> _navigate(BuildContext context, UserRole role) async {
    final appServices = Provider.of<AppServices>(context, listen: false);

    // Initialise role-specific services BEFORE navigating so the
    // MeshSosService listener starts with the correct userId/role.
    await appServices.initForRole(
      userId: _userIdFor(role),
      role: _roleKey(role),
      userName: role.userName,
    );

    if (!context.mounted) return;

    final user = MockUser(role: role);
    Widget home;
    switch (role) {
      case UserRole.fieldOfficer:
        home = SirdarHome(user: user);
        break;
      case UserRole.mineWorker:
        home = WorkerHome(user: user);
        break;
      case UserRole.contractorSup:
        home = ContractorHome(user: user);
        break;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PermissionsGateScreen(
          nextScreen: home,
          role: _roleKey(role),
          userId: _userIdFor(role),
          userName: role.userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.amberAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield,
                        color: AppTheme.nearBlackCoal, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'CoalGov',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const Text(
                'Smart Governance & Compliance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              // Mine selector
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: AppTheme.amberAccent, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sardega OCP  ·  Mahanadi Coalfields',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        color: Colors.white54, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'SELECT YOUR ROLE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _roleCard(
                context,
                role: UserRole.fieldOfficer,
                icon: Icons.engineering,
                description:
                    'Observations · Corrective Actions · Dashboard',
              ),
              const SizedBox(height: 12),
              _roleCard(
                context,
                role: UserRole.contractorSup,
                icon: Icons.groups,
                description:
                    'Dashboard · Observations · CAPAs · Contractors',
              ),
              const SizedBox(height: 12),
              _roleCard(
                context,
                role: UserRole.mineWorker,
                icon: Icons.person,
                description: 'Grievances only',
              ),
              const Spacer(),
              Text(
                'SARDEGA OCP  ·  SECL  ·  DEMO v1.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withAlpha(40), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required UserRole role,
    required IconData icon,
    required String description,
  }) {
    return GestureDetector(
      onTap: () => _navigate(context, role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.amberAccent.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  color: AppTheme.amberAccent, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }
}
