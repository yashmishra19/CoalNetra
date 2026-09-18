import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database.dart';
import 'services/location_service.dart';
import 'services/mesh_sos_service.dart';
import 'sync/sync_service.dart';
import 'theme/app_theme.dart';
import 'screens/role_select.dart';

// Global service instances — initialised once in main() and passed via Provider
late AppDatabase _appDatabase;
late LocationService _locationService;
late MeshSosService _meshSosService;
late SyncService _syncService;

void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    ErrorWidget.builder = (errorDetails) {
      return Scaffold(
        backgroundColor: Colors.red[900],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            'CRASH REPORT:\n\n${errorDetails.exception}\n\n${errorDetails.stack}',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
      );
    };

    String? initError;

    try {
      // ── 1. Database
      _appDatabase = AppDatabase();

      // ── 2. Sync service
      _syncService = SyncService(_appDatabase);

      // ── 3. Location service — default to sirdar; role is updated on login
      _locationService = LocationService(
        db: _appDatabase,
        role: 'sirdar',
        userId: 'field_officer_01',
      );
      await _locationService.start(); // Immediately starts 2-min pinging

      // ── 4. SOS mesh service
      _meshSosService = MeshSosService(
        db: _appDatabase,
        locationService: _locationService,
        userId: 'field_officer_01',
        role: 'sirdar',
        userName: 'B. Oraon',
      );
      await _meshSosService.startListening(); // Listens for peer SOS over UDP

      // ── 5. Periodic background sync every 20 seconds
      Timer.periodic(const Duration(seconds: 20), (_) {
        _syncService.sync().catchError((_) => SyncResult(
          pushed: 0,
          serverTime: DateTime.now().toUtc(),
        ));
      });

      // ── 6. INSTANT SYNC TRIGGER: Listen to real-time network state changes (WiFi / 4G / 5G)
      Connectivity().onConnectivityChanged.listen((results) {
        if (!results.contains(ConnectivityResult.none)) {
          debugPrint('NETWORK RESTORED: Triggering immediate DB sync');
          _syncService.sync().catchError((e) {
            debugPrint('Instant sync error: $e');
            return SyncResult(pushed: 0, serverTime: DateTime.now().toUtc());
          });
        }
      });

    } catch (e) {
      initError = e.toString();
      debugPrint('INIT FAILED: $e');
    }

    runApp(
      MultiProvider(
        providers: [
          Provider<AppDatabase?>.value(value: _appDatabase),
          Provider<LocationService?>.value(value: _locationService),
          Provider<MeshSosService?>.value(value: _meshSosService),
          Provider<SyncService?>.value(value: _syncService),
        ],
        child: CoalGovApp(initError: initError),
      ),
    );
  }, (error, stackTrace) {
    debugPrint('Fatal Error in Zone: $error');
    debugPrint(stackTrace.toString());
  });
}

class CoalGovApp extends StatelessWidget {
  final String? initError;
  const CoalGovApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoalNetra',
      theme: AppTheme.lightTheme,
      home: initError != null
          ? Scaffold(
              backgroundColor: Colors.red[900],
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Init Error: $initError',
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                  ),
                ),
              ),
            )
          : const RoleSelectScreen(),
      debugShowCheckedModeBanner: false,
      builder: (context, widget) => widget ?? const SizedBox.shrink(),
    );
  }
}
