import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database.dart';
import 'services/app_services.dart';
import 'sync/sync_service.dart';
import 'theme/app_theme.dart';
import 'screens/role_select.dart';

// Global instances — created once, role-specific services are inside AppServices
late AppDatabase _appDatabase;
late SyncService _syncService;
late AppServices _appServices;

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

      // ── 3. AppServices — role-aware container for MeshSosService + LocationService.
      //      These are NOT started yet; initForRole() is called after role selection.
      _appServices = AppServices(db: _appDatabase);

      // ── 4. Periodic background sync every 20 seconds
      Timer.periodic(const Duration(seconds: 20), (_) {
        _syncService.sync().catchError((_) => SyncResult(
          pushed: 0,
          serverTime: DateTime.now().toUtc(),
        ));
      });

      // ── 5. INSTANT SYNC: Trigger on network restore
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
          Provider<SyncService?>.value(value: _syncService),
          ChangeNotifierProvider<AppServices>.value(value: _appServices),
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
