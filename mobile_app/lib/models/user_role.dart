enum UserRole {
  fieldOfficer,
  mineWorker,
  contractorSup,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.fieldOfficer:
        return 'Field Officer (Sirdar)';
      case UserRole.mineWorker:
        return 'Mine Worker';
      case UserRole.contractorSup:
        return 'Contractor Sup.';
    }
  }

  String get shortLabel {
    switch (this) {
      case UserRole.fieldOfficer:
        return 'FIELD OFFICER';
      case UserRole.mineWorker:
        return 'MINE WORKER';
      case UserRole.contractorSup:
        return 'CONTRACTOR SUP.';
    }
  }

  String get userName {
    switch (this) {
      case UserRole.fieldOfficer:
        return 'S. Oram';
      case UserRole.mineWorker:
        return 'P. Kumar';
      case UserRole.contractorSup:
        return 'A. Gupta';
    }
  }
}

class MockUser {
  final UserRole role;
  final String mineName;
  final String subsidiary;

  const MockUser({
    required this.role,
    this.mineName = 'Sardega OCP',
    this.subsidiary = 'Mahanadi Coalfields',
  });
}
