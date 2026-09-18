import 'package:flutter/foundation.dart';
import '../database/database.dart';
import 'location_service.dart';
import 'mesh_sos_service.dart';

/// AppServices holds role-specific service instances.
/// Call [initForRole] after the user picks their role on the login screen.
/// Both MeshSosService and LocationService are re-initialised with the
/// correct userId / role so that the UDP self-filter and location tags
/// carry the actual user identity.
class AppServices extends ChangeNotifier {
  final AppDatabase db;

  MeshSosService? meshSosService;
  LocationService? locationService;

  bool _initialised = false;
  bool get initialised => _initialised;

  AppServices({required this.db});

  /// Call once after role selection.
  Future<void> initForRole({
    required String userId,
    required String role,
    required String userName,
  }) async {
    // Stop any previously running services
    locationService?.stop();
    meshSosService?.stopListening();

    // Create fresh instances with the correct identity
    locationService = LocationService(db: db, role: role, userId: userId);
    await locationService!.start();

    meshSosService = MeshSosService(
      db: db,
      locationService: locationService!,
      userId: userId,
      role: role,
      userName: userName,
    );
    // Start listening for peer SOS signals (UDP + BT Nearby)
    await meshSosService!.startListening();

    _initialised = true;
    notifyListeners();
  }
}
