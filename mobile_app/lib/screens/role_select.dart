import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';
import 'sirdar/sirdar_home.dart';
import 'worker/worker_home.dart';
import 'contractor/contractor_home.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  void _navigate(BuildContext context, UserRole role) {
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
        context, MaterialPageRoute(builder: (_) => home));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Slightly off-black to verify rendering
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
