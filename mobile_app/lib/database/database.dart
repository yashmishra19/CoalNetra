import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

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

@DriftDatabase(tables: [Observations, Evidences, Grievances])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) await m.addColumn(grievances, grievances.clientUuid);
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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
