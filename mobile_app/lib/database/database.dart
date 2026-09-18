import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Location confidence enum
const String locConfidenceLive = 'gps_live';
const String locConfidenceLastKnown = 'last_known';

// Observations table
class Observations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orgId => text()();
  TextColumn get reportedBy => text()();
  TextColumn get category => text()();
  TextColumn get location => text()();
  TextColumn get clientUuid => text().unique()();
  RealColumn get trustScore => real().nullable()();
  
  // Sync status: 0 = pending, 1 = synced
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}

// Evidence table
class Evidences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // e.g., 'observation'
  TextColumn get entityId => text()();   // observation client_uuid
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

// Location pings — synced every 2 min to web dashboard
class LocationPings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clientUuid => text().unique()();
  TextColumn get reportedBy => text()();
  TextColumn get role => text()(); // 'sirdar' | 'worker' | 'contractor'
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get accuracy => real().nullable()();
  TextColumn get locationConfidence => text()(); // 'gps_live' | 'last_known'
  DateTimeColumn get capturedAt => dateTime()();
  // 0=pending sync, 1=synced
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}

// SOS events — triggered by EMERGENCY button, sent via UDP mesh + cellular
class SosEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clientUuid => text().unique()();
  TextColumn get triggeredBy => text()();
  TextColumn get role => text()();
  TextColumn get userName => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  TextColumn get locationConfidence => text()(); // 'gps_live' | 'last_known' | 'unknown'
  // Which channel was used: 'cellular' | 'udp_lan' | 'both'
  TextColumn get sentViaChannel => text().withDefault(const Constant('cellular'))();
  // UUID of the device that relayed this via mesh (null if sent directly)
  TextColumn get meshRelayedBy => text().nullable()();
  DateTimeColumn get triggeredAt => dateTime()();
  // 0=pending sync, 1=synced
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [Observations, Evidences, Grievances, LocationPings, SosEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) await m.addColumn(grievances, grievances.clientUuid);
      if (from < 3) {
        await m.createTable(locationPings);
        await m.createTable(sosEvents);
      }
      if (from < 4) {
        await m.addColumn(sosEvents, sosEvents.userName);
      }
    },
  );

  // Insert observation offline
  Future<int> addObservation(ObservationsCompanion entry) {
    return into(observations).insert(entry);
  }

  Future<int> addGrievance(GrievancesCompanion entry) {
    return into(grievances).insert(entry);
  }

  // Get pending observations
  Future<List<Observation>> getPendingObservations() {
    return (select(observations)..where((t) => t.syncStatus.equals(0))).get();
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

  // ── Location Pings ──────────────────────────────────────────
  Future<int> addLocationPing(LocationPingsCompanion entry) {
    return into(locationPings).insert(entry);
  }

  Future<List<LocationPing>> getPendingLocationPings() {
    // Only send the latest 5 pings per sync to keep payload small on 3G
    return (select(locationPings)
      ..where((t) => t.syncStatus.equals(0))
      ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])
      ..limit(5)).get();
  }

  Future<void> markLocationPingSynced(String clientUuid) async {
    await (update(locationPings)..where((t) => t.clientUuid.equals(clientUuid)))
        .write(const LocationPingsCompanion(syncStatus: Value(1)));
  }

  /// Stream of latest pings (last 30 min) for the map tab
  Stream<List<LocationPing>> watchRecentLocationPings() {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 30));
    return (select(locationPings)
      ..where((t) => t.capturedAt.isBiggerThanValue(cutoff))
      ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])).watch();
  }

  // ── SOS Events ──────────────────────────────────────────────
  Future<int> addSosEvent(SosEventsCompanion entry) {
    return into(sosEvents).insert(entry);
  }

  Future<List<SosEvent>> getPendingSosEvents() {
    return (select(sosEvents)..where((t) => t.syncStatus.equals(0))).get();
  }

  Future<void> markSosEventSynced(String clientUuid) async {
    await (update(sosEvents)..where((t) => t.clientUuid.equals(clientUuid)))
        .write(const SosEventsCompanion(syncStatus: Value(1)));
  }

  /// Stream all SOS events (not just pending) for map tab
  Stream<List<SosEvent>> watchRecentSosEvents() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 8));
    return (select(sosEvents)
      ..where((t) => t.triggeredAt.isBiggerThanValue(cutoff))
      ..orderBy([(t) => OrderingTerm.desc(t.triggeredAt)])).watch();
  }

  /// Total pending count (observations + grievances) for sync strip UI
  Future<int> getPendingCount() async {
    final obs = await getPendingObservations();
    final grv = await getPendingGrievances();
    final loc = await getPendingLocationPings();
    final sos = await getPendingSosEvents();
    return obs.length + grv.length + loc.length + sos.length;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
