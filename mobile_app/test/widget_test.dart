import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:mobile_app/database/database.dart';
import 'package:mobile_app/screens/shared/documents_tab.dart';
import 'package:mobile_app/screens/shared/sos_beacon_screen.dart';
import 'package:mobile_app/services/sos_service.dart';

void main() {
  test('offline observation persists its editable fields', () async {
    final database = AppDatabase.forTesting();
    await database.addObservation(
      ObservationsCompanion(
        orgId: const drift.Value('demo-org'),
        reportedBy: const drift.Value('demo-user'),
        category: const drift.Value('Safety Hazard'),
        location: const drift.Value('20.01, 78.11'),
        severity: const drift.Value('CRITICAL'),
        description: const drift.Value('Loose roof support at entry'),
        clientUuid: const drift.Value('test-observation-uuid'),
      ),
    );

    final stored = await database.getAllObservations();
    expect(stored, hasLength(1));
    expect(stored.single.severity, 'CRITICAL');
    expect(stored.single.description, 'Loose roof support at entry');
    await database.close();
  });

  test('remote demo observations are cached for offline viewing', () async {
    final database = AppDatabase.forTesting();
    await database.cacheRemoteObservations([
      {
        'id': '99999999-9999-4999-8999-999999999901',
        'mine_id': '55555555-5555-4555-8555-555555555501',
        'category': 'Safety Hazard',
        'severity': 'CRITICAL',
        'description': 'Haul road berm damage',
        'location': '20.0315, 78.1325',
        'server_created_at': '2026-09-26T12:00:00Z',
      },
    ]);

    final cached = await database.getAllObservations();
    expect(cached, hasLength(1));
    expect(cached.single.description, 'Haul road berm damage');
    expect(cached.single.severity, 'CRITICAL');
    expect(cached.single.syncStatus, 1);
    await database.close();
  });

  test('obligation edits stay queued until accepted by sync', () async {
    final database = AppDatabase.forTesting();
    final initialDueDate = DateTime.utc(2026, 10, 1);
    await database.cacheObligations([
      CachedObligationsCompanion(
        remoteId: const drift.Value('88888888-8888-4888-8888-888888888801'),
        mineId: const drift.Value('55555555-5555-4555-8555-555555555501'),
        title: const drift.Value('Demo inspection obligation'),
        frequency: const drift.Value('DAILY'),
        ownerRole: const drift.Value('FIELD_OFFICER'),
        dueDate: drift.Value(initialDueDate),
        status: const drift.Value('PENDING'),
      ),
    ]);

    await database.updateObligationOffline(
      remoteId: '88888888-8888-4888-8888-888888888801',
      status: 'COMPLETED',
      dueDate: DateTime.utc(2026, 10, 2),
    );

    final updated = (await database.getCachedObligations()).single;
    expect(updated.status, 'COMPLETED');
    expect(updated.dueDate.toUtc(), DateTime.utc(2026, 10, 2));
    expect((await database.getPendingObligationUpdates()), hasLength(1));
    await database.close();
  });

  test(
    'bundled demo obligations persist locally and never enter sync queue',
    () async {
      final database = AppDatabase.forTesting();
      await database.seedDemoDataIfEmpty();
      final fixtures = await database.getCachedObligations();
      expect(fixtures, hasLength(3));
      expect(fixtures.every((row) => row.syncStatus == 2), isTrue);

      await database.updateObligationOffline(
        remoteId: fixtures.first.remoteId,
        status: 'COMPLETED',
      );
      expect(await database.getPendingObligationUpdates(), isEmpty);
      await database.seedDemoDataIfEmpty();
      expect(await database.getCachedObligations(), hasLength(3));
      await database.close();
    },
  );

  test(
    'SOS updates and cancellation remain in the local sync outbox',
    () async {
      final database = AppDatabase.forTesting();
      await database.saveSosSignal(
        clientUuid: 'sos-client-uuid',
        userName: 'Demo worker',
        role: 'Mine Worker',
        latitude: 20.025,
        longitude: 78.125,
        status: 'ACTIVE',
      );
      final activation = (await database.getPendingSosSignals()).single;

      await database.saveSosSignal(
        clientUuid: 'sos-client-uuid',
        userName: 'Demo worker',
        role: 'Mine Worker',
        latitude: 20.026,
        longitude: 78.126,
        status: 'CANCELLED',
      );

      final cancelled = (await database.getPendingSosSignals()).single;
      expect(cancelled.status, 'CANCELLED');
      expect(cancelled.latitude, 20.026);
      expect(cancelled.createdAt, activation.createdAt);
      await database.close();
    },
  );

  testWidgets('documents screen labels bundled examples as local demo data', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SizedBox(height: 700, child: DocumentsTab())),
      ),
    );

    expect(
      find.text('LOCAL DEMO RECORDS · NOT VERIFIED OR STORED IN THE DATABASE'),
      findsOneWidget,
    );
    expect(find.text('DGMS Blasting Certificate · S. Oram'), findsOneWidget);
    expect(find.text('Download'), findsNothing);
    expect(find.text('Re-upload'), findsNothing);

    await tester.tap(find.text('OCR Upload'));
    await tester.pumpAndSettle();
    expect(
      find.text('Document upload and OCR are not connected.'),
      findsOneWidget,
    );
  });

  testWidgets('opening SOS does not activate or seed a remote alert', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SOSBeaconScreen()));

    expect(find.text('SOS INACTIVE'), findsOneWidget);
    expect(
      find.textContaining('Nearby app phones can discover this device by BLE'),
      findsOneWidget,
    );
    expect(SOSService.instance.isSOSActive, isFalse);
    expect(SOSService.instance.networkBeacons, isEmpty);
  });
}
