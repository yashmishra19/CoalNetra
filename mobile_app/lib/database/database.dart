import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Location confidence constants
const String locConfidenceLive = 'gps_live';
const String locConfidenceLastKnown = 'gps_last_known';

// Observations table
class Observations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orgId => text()();
  TextColumn get reportedBy => text()();
  TextColumn get category => text()();
  TextColumn get location => text()();
  TextColumn get severity => text().withDefault(const Constant('MEDIUM'))();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get clientUuid => text().unique()();
  RealColumn get trustScore => real().nullable()();

  // Sync status: 0 = pending, 1 = synced
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}

// Evidence table
class Evidences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // e.g., 'observation'
  TextColumn get entityId => text()(); // observation client_uuid
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get location => text()();
  TextColumn get filePath => text()();
  RealColumn get trustScore => real().nullable()();
  TextColumn get phash => text().nullable()();
}

// Grievances table
class Grievances extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clientUuid => text().unique()();
  TextColumn get orgId => text()();
  TextColumn get raisedBy => text().nullable()();
  BoolColumn get isAnonymous => boolean().withDefault(const Constant(false))();
  TextColumn get lang => text()();
  TextColumn get rawText => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Sync status: 0 = pending, 1 = synced
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}

class CachedObligations extends Table {
  TextColumn get remoteId => text()();
  TextColumn get mineId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get frequency => text()();
  TextColumn get ownerRole => text()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get status => text()();
  TextColumn get category => text().withDefault(const Constant('Safety'))();
  TextColumn get evidenceRequired => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get syncStatus => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {remoteId};
}

class SosSignals extends Table {
  TextColumn get clientUuid => text()();
  TextColumn get userName => text()();
  TextColumn get role => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get status => text().withDefault(const Constant('ACTIVE'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {clientUuid};
}

// Location pings table — stores periodic GPS readings
class LocationPings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clientUuid => text().unique()();
  TextColumn get reportedBy => text()();
  TextColumn get role => text()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get accuracy => real().nullable()();
  TextColumn get locationConfidence => text().withDefault(const Constant('gps_last_known'))();
  DateTimeColumn get capturedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}

// SOS events table — stores emergency distress signals
class SosEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clientUuid => text().unique()();
  TextColumn get triggeredBy => text()();
  TextColumn get role => text()();
  TextColumn get userName => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  TextColumn get locationConfidence => text().withDefault(const Constant('unknown'))();
  TextColumn get sentViaChannel => text().withDefault(const Constant('cellular'))();
  DateTimeColumn get triggeredAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}

@DriftDatabase(
  tables: [Observations, Evidences, Grievances, CachedObligations, SosSignals, LocationPings, SosEvents],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) await m.addColumn(grievances, grievances.clientUuid);
      if (from < 3) {
        await m.addColumn(observations, observations.severity);
        await m.addColumn(observations, observations.description);
        await m.addColumn(observations, observations.createdAt);
      }
      if (from < 4) await m.createTable(cachedObligations);
      if (from < 5) await m.createTable(sosSignals);
      if (from < 6) await m.createTable(locationPings);
      if (from < 7) await m.createTable(sosEvents);
    },
  );

  // Insert observation offline
  Future<int> addObservation(ObservationsCompanion entry) {
    return into(observations).insert(entry);
  }

  Future<int> addGrievance(GrievancesCompanion entry) {
    return into(grievances).insert(entry);
  }

  Future<List<CachedObligation>> getCachedObligations() {
    return (select(
      cachedObligations,
    )..orderBy([(row) => OrderingTerm(expression: row.dueDate)])).get();
  }

  Future<void> cacheObligations(List<CachedObligationsCompanion> rows) async {
    await batch((batch) {
      batch.insertAll(
        cachedObligations,
        rows,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> seedDemoDataIfEmpty() async {
    final cached = await getCachedObligations();
    if (cached.isEmpty) {
      final now = DateTime.now().toUtc();
      await cacheObligations([
        _demoObligation(
          id: 'd0000000-0000-4000-8000-000000000001',
          title: 'Pre-shift gas test at active face',
          description: 'Record methane and oxygen readings before entry.',
          category: 'Safety',
          dueDate: now.add(const Duration(hours: 3)),
          status: 'PENDING',
        ),
        _demoObligation(
          id: 'd0000000-0000-4000-8000-000000000002',
          title: 'Inspect haul-road berm',
          description:
              'Check berm height and continuity along the north route.',
          category: 'Equipment',
          dueDate: now.subtract(const Duration(hours: 5)),
          status: 'OVERDUE',
        ),
        _demoObligation(
          id: 'd0000000-0000-4000-8000-000000000003',
          title: 'Dust suppression water check',
          description: 'Verify spray line pressure and log the reading.',
          category: 'Environment',
          dueDate: now.add(const Duration(days: 1)),
          status: 'COMPLETED',
        ),
      ]);
    }

    if ((await getAllObservations()).isEmpty) {
      final now = DateTime.now().toUtc();
      await into(observations).insert(
        ObservationsCompanion.insert(
          orgId: 'demo-mine',
          reportedBy: 'demo-sirdar',
          category: 'Safety Hazard',
          location: 'North haul road',
          severity: const Value('HIGH'),
          description: const Value('Demo: berm needs a continuity inspection.'),
          createdAt: Value(now),
          clientUuid: 'd0000000-0000-4000-8000-000000000101',
          syncStatus: const Value(2),
        ),
      );
      await into(observations).insert(
        ObservationsCompanion.insert(
          orgId: 'demo-mine',
          reportedBy: 'demo-sirdar',
          category: 'Environment',
          location: 'Bench 3',
          severity: const Value('MEDIUM'),
          description: const Value('Demo: dust suppression reading is due.'),
          createdAt: Value(now.subtract(const Duration(hours: 2))),
          clientUuid: 'd0000000-0000-4000-8000-000000000102',
          syncStatus: const Value(2),
        ),
      );
    }
  }

  CachedObligationsCompanion _demoObligation({
    required String id,
    required String title,
    required String description,
    required String category,
    required DateTime dueDate,
    required String status,
  }) => CachedObligationsCompanion.insert(
    remoteId: id,
    mineId: 'demo-mine',
    title: title,
    description: Value(description),
    frequency: 'DAILY',
    ownerRole: 'FIELD_OFFICER',
    dueDate: dueDate,
    status: status,
    category: Value(category),
    evidenceRequired: const Value('Inspection notes'),
    syncStatus: const Value(2),
  );

  Future<void> saveSosSignal({
    required String clientUuid,
    required String userName,
    required String role,
    required String status,
    double? latitude,
    double? longitude,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await (select(
      sosSignals,
    )..where((row) => row.clientUuid.equals(clientUuid))).getSingleOrNull();
    await into(sosSignals).insertOnConflictUpdate(
      SosSignalsCompanion.insert(
        clientUuid: clientUuid,
        userName: userName,
        role: role,
        latitude: Value(latitude),
        longitude: Value(longitude),
        status: Value(status),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        syncStatus: const Value(0),
      ),
    );
  }

  Future<List<SosSignal>> getPendingSosSignals() =>
      (select(sosSignals)..where((row) => row.syncStatus.equals(0))).get();

  Future<void> markSosSignalSynced(String clientUuid) async {
    await (update(sosSignals)
          ..where((row) => row.clientUuid.equals(clientUuid)))
        .write(const SosSignalsCompanion(syncStatus: Value(1)));
  }

  Future<void> updateObligationOffline({
    required String remoteId,
    String? status,
    DateTime? dueDate,
  }) async {
    if (status == null && dueDate == null) return;
    final row = await (select(
      cachedObligations,
    )..where((item) => item.remoteId.equals(remoteId))).getSingleOrNull();
    if (row == null) return;
    await (update(
      cachedObligations,
    )..where((row) => row.remoteId.equals(remoteId))).write(
      CachedObligationsCompanion(
        status: status == null ? const Value.absent() : Value(status),
        dueDate: dueDate == null
            ? const Value.absent()
            : Value(dueDate.toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
        syncStatus: Value(row.syncStatus == 2 ? 2 : 0),
      ),
    );
  }

  Future<List<CachedObligation>> getPendingObligationUpdates() {
    return (select(
      cachedObligations,
    )..where((row) => row.syncStatus.equals(0))).get();
  }

  Future<void> markObligationSynced(String remoteId) async {
    await (update(cachedObligations)
          ..where((row) => row.remoteId.equals(remoteId)))
        .write(const CachedObligationsCompanion(syncStatus: Value(1)));
  }

  // Get pending observations
  Future<List<Observation>> getPendingObservations() {
    return (select(observations)..where((t) => t.syncStatus.equals(0))).get();
  }

  Future<List<Observation>> getAllObservations() {
    return (select(observations)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Future<void> cacheRemoteObservations(List<Map<String, dynamic>> rows) async {
    for (final row in rows) {
      final remoteId = row['id']?.toString();
      final clientUuid = row['client_uuid']?.toString();
      final stableUuid = clientUuid?.isNotEmpty == true
          ? clientUuid!
          : remoteId == null
          ? null
          : 'remote-$remoteId';
      if (stableUuid == null) continue;

      final existing = await (select(
        observations,
      )..where((item) => item.clientUuid.equals(stableUuid))).getSingleOrNull();
      if (existing != null && existing.syncStatus == 0) continue;

      final createdAt =
          DateTime.tryParse(
            (row['client_created_at'] ??
                    row['server_created_at'] ??
                    row['created_at'] ??
                    '')
                .toString(),
          ) ??
          DateTime.now().toUtc();
      await into(observations).insertOnConflictUpdate(
        ObservationsCompanion(
          orgId: Value((row['mine_id'] ?? 'demo-mine').toString()),
          reportedBy: Value((row['reported_by'] ?? 'demo-user').toString()),
          category: Value((row['category'] ?? 'Safety Hazard').toString()),
          location: Value(
            (row['location'] ?? 'Location unavailable').toString(),
          ),
          severity: Value(
            (row['severity'] ?? 'MEDIUM').toString().toUpperCase(),
          ),
          description: Value((row['description'] ?? '').toString()),
          createdAt: Value(createdAt.toUtc()),
          clientUuid: Value(stableUuid),
          trustScore: Value((row['trust_score'] as num?)?.toDouble()),
          syncStatus: const Value(1),
        ),
      );
    }
  }

  Future<List<Grievance>> getPendingGrievances() {
    return (select(grievances)..where((t) => t.syncStatus.equals(0))).get();
  }

  Future<void> markObservationSynced(String clientUuid) async {
    await (update(observations)..where((t) => t.clientUuid.equals(clientUuid)))
        .write(const ObservationsCompanion(syncStatus: Value(1)));
  }

  Future<void> markGrievanceSynced(String clientUuid) async {
    await (update(grievances)..where((t) => t.clientUuid.equals(clientUuid)))
        .write(const GrievancesCompanion(syncStatus: Value(1)));
  }

  Stream<List<Grievance>> watchAllGrievances() {
    return (select(grievances)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  Stream<List<Observation>> watchAllObservations() {
    return (select(observations)..orderBy([
          (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  // ── LocationPings methods ──

  Future<int> addLocationPing(LocationPingsCompanion entry) {
    return into(locationPings).insert(entry);
  }

  Stream<List<LocationPing>> watchRecentLocationPings() {
    return (select(locationPings)
          ..orderBy([
                (t) => OrderingTerm(
                    expression: t.capturedAt, mode: OrderingMode.desc),
              ])
          ..limit(50))
        .watch();
  }

  Future<List<LocationPing>> getPendingLocationPings() {
    return (select(locationPings)
          ..where((t) => t.syncStatus.equals(0)))
        .get();
  }

  Future<void> markLocationPingSynced(String clientUuid) async {
    await (update(locationPings)
          ..where((t) => t.clientUuid.equals(clientUuid)))
        .write(const LocationPingsCompanion(syncStatus: Value(1)));
  }

  // ── SosEvents methods ──

  Future<int> addSosEvent(SosEventsCompanion entry) {
    return into(sosEvents).insert(entry);
  }

  Stream<List<SosEvent>> watchRecentSosEvents() {
    return (select(sosEvents)
          ..orderBy([
                (t) => OrderingTerm(
                    expression: t.triggeredAt, mode: OrderingMode.desc),
              ])
          ..limit(50))
        .watch();
  }

  Future<List<SosEvent>> getPendingSosEvents() {
    return (select(sosEvents)
          ..where((t) => t.syncStatus.equals(0)))
        .get();
  }

  Future<void> markSosEventSynced(String clientUuid) async {
    await (update(sosEvents)
          ..where((t) => t.clientUuid.equals(clientUuid)))
        .write(const SosEventsCompanion(syncStatus: Value(1)));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
