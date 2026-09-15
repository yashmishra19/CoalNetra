import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database.dart';
import 'sync/sync_service.dart';
import 'theme/app_theme.dart';
import 'screens/role_select.dart';

void main() {
  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("Flutter Error: ${details.exception}");
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    ErrorWidget.builder = (errorDetails) {
      return Scaffold(
        backgroundColor: Colors.red[900],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            "CRASH REPORT:\n\n${errorDetails.exception}\n\n${errorDetails.stack}",
            style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
      );
    };
    
    // Initialize database outside of Provider to catch boot-up crashes
    AppDatabase? database;
    String? initError;
    
    try {
      database = AppDatabase();
      // Drift database is lazy, but we can verify it can be instantiated
      final syncService = SyncService(database);
      syncService.sync().catchError((_) => SyncResult(
        pushed: 0,
        serverTime: DateTime.now().toUtc(),
      ));
      Timer.periodic(const Duration(seconds: 30), (_) {
        syncService.sync().catchError((_) => SyncResult(
          pushed: 0,
          serverTime: DateTime.now().toUtc(),
        ));
      });
    } catch (e) {
      initError = e.toString();
      debugPrint("DB INIT FAILED: $e");
    }

    runApp(
      Provider<AppDatabase?>.value(
        value: database,
        child: CoalGovApp(initError: initError),
      ),
    );
  }, (error, stackTrace) {
    debugPrint("Fatal Error in Zone: $error");
    debugPrint(stackTrace.toString());
  });
}

class CoalGovApp extends StatelessWidget {
  final String? initError;
  const CoalGovApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoalGov',
      theme: AppTheme.lightTheme,
      // If an error occurred during main(), show a red screen instead of black
      home: initError != null 
        ? Scaffold(
            backgroundColor: Colors.red[900],
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Init Error: $initError", 
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace')
                ),
              ),
            ),
          )
        : const RoleSelectScreen(),
      debugShowCheckedModeBanner: false,
      builder: (context, widget) {
        return widget ?? const SizedBox.shrink();
      },
    );
  }
}
