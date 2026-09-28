// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ObservationsTable extends Observations
    with TableInfo<$ObservationsTable, Observation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
    'org_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportedByMeta = const VerificationMeta(
    'reportedBy',
  );
  @override
  late final GeneratedColumn<String> reportedBy = GeneratedColumn<String>(
    'reported_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('MEDIUM'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _trustScoreMeta = const VerificationMeta(
    'trustScore',
  );
  @override
  late final GeneratedColumn<double> trustScore = GeneratedColumn<double>(
    'trust_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orgId,
    reportedBy,
    category,
    location,
    severity,
    description,
    createdAt,
    clientUuid,
    trustScore,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Observation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('org_id')) {
      context.handle(
        _orgIdMeta,
        orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orgIdMeta);
    }
    if (data.containsKey('reported_by')) {
      context.handle(
        _reportedByMeta,
        reportedBy.isAcceptableOrUnknown(data['reported_by']!, _reportedByMeta),
      );
    } else if (isInserting) {
      context.missing(_reportedByMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('trust_score')) {
      context.handle(
        _trustScoreMeta,
        trustScore.isAcceptableOrUnknown(data['trust_score']!, _trustScoreMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Observation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Observation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      orgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}org_id'],
      )!,
      reportedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_by'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      trustScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}trust_score'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ObservationsTable createAlias(String alias) {
    return $ObservationsTable(attachedDatabase, alias);
  }
}

class Observation extends DataClass implements Insertable<Observation> {
  final int id;
  final String orgId;
  final String reportedBy;
  final String category;
  final String location;
  final String severity;
  final String description;
  final DateTime createdAt;
  final String clientUuid;
  final double? trustScore;
  final int syncStatus;
  const Observation({
    required this.id,
    required this.orgId,
    required this.reportedBy,
    required this.category,
    required this.location,
    required this.severity,
    required this.description,
    required this.createdAt,
    required this.clientUuid,
    this.trustScore,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['org_id'] = Variable<String>(orgId);
    map['reported_by'] = Variable<String>(reportedBy);
    map['category'] = Variable<String>(category);
    map['location'] = Variable<String>(location);
    map['severity'] = Variable<String>(severity);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['client_uuid'] = Variable<String>(clientUuid);
    if (!nullToAbsent || trustScore != null) {
      map['trust_score'] = Variable<double>(trustScore);
    }
    map['sync_status'] = Variable<int>(syncStatus);
    return map;
  }

  ObservationsCompanion toCompanion(bool nullToAbsent) {
    return ObservationsCompanion(
      id: Value(id),
      orgId: Value(orgId),
      reportedBy: Value(reportedBy),
      category: Value(category),
      location: Value(location),
      severity: Value(severity),
      description: Value(description),
      createdAt: Value(createdAt),
      clientUuid: Value(clientUuid),
      trustScore: trustScore == null && nullToAbsent
          ? const Value.absent()
          : Value(trustScore),
      syncStatus: Value(syncStatus),
    );
  }

  factory Observation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Observation(
      id: serializer.fromJson<int>(json['id']),
      orgId: serializer.fromJson<String>(json['orgId']),
      reportedBy: serializer.fromJson<String>(json['reportedBy']),
      category: serializer.fromJson<String>(json['category']),
      location: serializer.fromJson<String>(json['location']),
      severity: serializer.fromJson<String>(json['severity']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      trustScore: serializer.fromJson<double?>(json['trustScore']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orgId': serializer.toJson<String>(orgId),
      'reportedBy': serializer.toJson<String>(reportedBy),
      'category': serializer.toJson<String>(category),
      'location': serializer.toJson<String>(location),
      'severity': serializer.toJson<String>(severity),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'trustScore': serializer.toJson<double?>(trustScore),
      'syncStatus': serializer.toJson<int>(syncStatus),
    };
  }

  Observation copyWith({
    int? id,
    String? orgId,
    String? reportedBy,
    String? category,
    String? location,
    String? severity,
    String? description,
    DateTime? createdAt,
    String? clientUuid,
    Value<double?> trustScore = const Value.absent(),
    int? syncStatus,
  }) => Observation(
    id: id ?? this.id,
    orgId: orgId ?? this.orgId,
    reportedBy: reportedBy ?? this.reportedBy,
    category: category ?? this.category,
    location: location ?? this.location,
    severity: severity ?? this.severity,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    clientUuid: clientUuid ?? this.clientUuid,
    trustScore: trustScore.present ? trustScore.value : this.trustScore,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Observation copyWithCompanion(ObservationsCompanion data) {
    return Observation(
      id: data.id.present ? data.id.value : this.id,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      reportedBy: data.reportedBy.present
          ? data.reportedBy.value
          : this.reportedBy,
      category: data.category.present ? data.category.value : this.category,
      location: data.location.present ? data.location.value : this.location,
      severity: data.severity.present ? data.severity.value : this.severity,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      trustScore: data.trustScore.present
          ? data.trustScore.value
          : this.trustScore,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Observation(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('reportedBy: $reportedBy, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('severity: $severity, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('trustScore: $trustScore, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orgId,
    reportedBy,
    category,
    location,
    severity,
    description,
    createdAt,
    clientUuid,
    trustScore,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Observation &&
          other.id == this.id &&
          other.orgId == this.orgId &&
          other.reportedBy == this.reportedBy &&
          other.category == this.category &&
          other.location == this.location &&
          other.severity == this.severity &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.clientUuid == this.clientUuid &&
          other.trustScore == this.trustScore &&
          other.syncStatus == this.syncStatus);
}

class ObservationsCompanion extends UpdateCompanion<Observation> {
  final Value<int> id;
  final Value<String> orgId;
  final Value<String> reportedBy;
  final Value<String> category;
  final Value<String> location;
  final Value<String> severity;
  final Value<String> description;
  final Value<DateTime> createdAt;
  final Value<String> clientUuid;
  final Value<double?> trustScore;
  final Value<int> syncStatus;
  const ObservationsCompanion({
    this.id = const Value.absent(),
    this.orgId = const Value.absent(),
    this.reportedBy = const Value.absent(),
    this.category = const Value.absent(),
    this.location = const Value.absent(),
    this.severity = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.trustScore = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  ObservationsCompanion.insert({
    this.id = const Value.absent(),
    required String orgId,
    required String reportedBy,
    required String category,
    required String location,
    this.severity = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String clientUuid,
    this.trustScore = const Value.absent(),
    this.syncStatus = const Value.absent(),
  }) : orgId = Value(orgId),
       reportedBy = Value(reportedBy),
       category = Value(category),
       location = Value(location),
       clientUuid = Value(clientUuid);
  static Insertable<Observation> custom({
    Expression<int>? id,
    Expression<String>? orgId,
    Expression<String>? reportedBy,
    Expression<String>? category,
    Expression<String>? location,
    Expression<String>? severity,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<String>? clientUuid,
    Expression<double>? trustScore,
    Expression<int>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orgId != null) 'org_id': orgId,
      if (reportedBy != null) 'reported_by': reportedBy,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (severity != null) 'severity': severity,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (trustScore != null) 'trust_score': trustScore,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  ObservationsCompanion copyWith({
    Value<int>? id,
    Value<String>? orgId,
    Value<String>? reportedBy,
    Value<String>? category,
    Value<String>? location,
    Value<String>? severity,
    Value<String>? description,
    Value<DateTime>? createdAt,
    Value<String>? clientUuid,
    Value<double?>? trustScore,
    Value<int>? syncStatus,
  }) {
    return ObservationsCompanion(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      reportedBy: reportedBy ?? this.reportedBy,
      category: category ?? this.category,
      location: location ?? this.location,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      clientUuid: clientUuid ?? this.clientUuid,
      trustScore: trustScore ?? this.trustScore,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (reportedBy.present) {
      map['reported_by'] = Variable<String>(reportedBy.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (trustScore.present) {
      map['trust_score'] = Variable<double>(trustScore.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservationsCompanion(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('reportedBy: $reportedBy, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('severity: $severity, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('trustScore: $trustScore, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $EvidencesTable extends Evidences
    with TableInfo<$EvidencesTable, Evidence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trustScoreMeta = const VerificationMeta(
    'trustScore',
  );
  @override
  late final GeneratedColumn<double> trustScore = GeneratedColumn<double>(
    'trust_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phashMeta = const VerificationMeta('phash');
  @override
  late final GeneratedColumn<String> phash = GeneratedColumn<String>(
    'phash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    capturedAt,
    location,
    filePath,
    trustScore,
    phash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Evidence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('trust_score')) {
      context.handle(
        _trustScoreMeta,
        trustScore.isAcceptableOrUnknown(data['trust_score']!, _trustScoreMeta),
      );
    }
    if (data.containsKey('phash')) {
      context.handle(
        _phashMeta,
        phash.isAcceptableOrUnknown(data['phash']!, _phashMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Evidence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Evidence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      trustScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}trust_score'],
      ),
      phash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phash'],
      ),
    );
  }

  @override
  $EvidencesTable createAlias(String alias) {
    return $EvidencesTable(attachedDatabase, alias);
  }
}

class Evidence extends DataClass implements Insertable<Evidence> {
  final int id;
  final String entityType;
  final String entityId;
  final DateTime capturedAt;
  final String location;
  final String filePath;
  final double? trustScore;
  final String? phash;
  const Evidence({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.capturedAt,
    required this.location,
    required this.filePath,
    this.trustScore,
    this.phash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['location'] = Variable<String>(location);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || trustScore != null) {
      map['trust_score'] = Variable<double>(trustScore);
    }
    if (!nullToAbsent || phash != null) {
      map['phash'] = Variable<String>(phash);
    }
    return map;
  }

  EvidencesCompanion toCompanion(bool nullToAbsent) {
    return EvidencesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      capturedAt: Value(capturedAt),
      location: Value(location),
      filePath: Value(filePath),
      trustScore: trustScore == null && nullToAbsent
          ? const Value.absent()
          : Value(trustScore),
      phash: phash == null && nullToAbsent
          ? const Value.absent()
          : Value(phash),
    );
  }

  factory Evidence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Evidence(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      location: serializer.fromJson<String>(json['location']),
      filePath: serializer.fromJson<String>(json['filePath']),
      trustScore: serializer.fromJson<double?>(json['trustScore']),
      phash: serializer.fromJson<String?>(json['phash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'location': serializer.toJson<String>(location),
      'filePath': serializer.toJson<String>(filePath),
      'trustScore': serializer.toJson<double?>(trustScore),
      'phash': serializer.toJson<String?>(phash),
    };
  }

  Evidence copyWith({
    int? id,
    String? entityType,
    String? entityId,
    DateTime? capturedAt,
    String? location,
    String? filePath,
    Value<double?> trustScore = const Value.absent(),
    Value<String?> phash = const Value.absent(),
  }) => Evidence(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    capturedAt: capturedAt ?? this.capturedAt,
    location: location ?? this.location,
    filePath: filePath ?? this.filePath,
    trustScore: trustScore.present ? trustScore.value : this.trustScore,
    phash: phash.present ? phash.value : this.phash,
  );
  Evidence copyWithCompanion(EvidencesCompanion data) {
    return Evidence(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      location: data.location.present ? data.location.value : this.location,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      trustScore: data.trustScore.present
          ? data.trustScore.value
          : this.trustScore,
      phash: data.phash.present ? data.phash.value : this.phash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Evidence(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('location: $location, ')
          ..write('filePath: $filePath, ')
          ..write('trustScore: $trustScore, ')
          ..write('phash: $phash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    capturedAt,
    location,
    filePath,
    trustScore,
    phash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Evidence &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.capturedAt == this.capturedAt &&
          other.location == this.location &&
          other.filePath == this.filePath &&
          other.trustScore == this.trustScore &&
          other.phash == this.phash);
}

class EvidencesCompanion extends UpdateCompanion<Evidence> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<DateTime> capturedAt;
  final Value<String> location;
  final Value<String> filePath;
  final Value<double?> trustScore;
  final Value<String?> phash;
  const EvidencesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.location = const Value.absent(),
    this.filePath = const Value.absent(),
    this.trustScore = const Value.absent(),
    this.phash = const Value.absent(),
  });
  EvidencesCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required DateTime capturedAt,
    required String location,
    required String filePath,
    this.trustScore = const Value.absent(),
    this.phash = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       capturedAt = Value(capturedAt),
       location = Value(location),
       filePath = Value(filePath);
  static Insertable<Evidence> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<DateTime>? capturedAt,
    Expression<String>? location,
    Expression<String>? filePath,
    Expression<double>? trustScore,
    Expression<String>? phash,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (location != null) 'location': location,
      if (filePath != null) 'file_path': filePath,
      if (trustScore != null) 'trust_score': trustScore,
      if (phash != null) 'phash': phash,
    });
  }

  EvidencesCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<DateTime>? capturedAt,
    Value<String>? location,
    Value<String>? filePath,
    Value<double?>? trustScore,
    Value<String?>? phash,
  }) {
    return EvidencesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      capturedAt: capturedAt ?? this.capturedAt,
      location: location ?? this.location,
      filePath: filePath ?? this.filePath,
      trustScore: trustScore ?? this.trustScore,
      phash: phash ?? this.phash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (trustScore.present) {
      map['trust_score'] = Variable<double>(trustScore.value);
    }
    if (phash.present) {
      map['phash'] = Variable<String>(phash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidencesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('location: $location, ')
          ..write('filePath: $filePath, ')
          ..write('trustScore: $trustScore, ')
          ..write('phash: $phash')
          ..write(')'))
        .toString();
  }
}

class $GrievancesTable extends Grievances
    with TableInfo<$GrievancesTable, Grievance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrievancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
    'org_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _raisedByMeta = const VerificationMeta(
    'raisedBy',
  );
  @override
  late final GeneratedColumn<String> raisedBy = GeneratedColumn<String>(
    'raised_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAnonymousMeta = const VerificationMeta(
    'isAnonymous',
  );
  @override
  late final GeneratedColumn<bool> isAnonymous = GeneratedColumn<bool>(
    'is_anonymous',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_anonymous" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientUuid,
    orgId,
    raisedBy,
    isAnonymous,
    lang,
    rawText,
    createdAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grievances';
  @override
  VerificationContext validateIntegrity(
    Insertable<Grievance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('org_id')) {
      context.handle(
        _orgIdMeta,
        orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orgIdMeta);
    }
    if (data.containsKey('raised_by')) {
      context.handle(
        _raisedByMeta,
        raisedBy.isAcceptableOrUnknown(data['raised_by']!, _raisedByMeta),
      );
    }
    if (data.containsKey('is_anonymous')) {
      context.handle(
        _isAnonymousMeta,
        isAnonymous.isAcceptableOrUnknown(
          data['is_anonymous']!,
          _isAnonymousMeta,
        ),
      );
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Grievance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Grievance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      orgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}org_id'],
      )!,
      raisedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raised_by'],
      ),
      isAnonymous: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_anonymous'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $GrievancesTable createAlias(String alias) {
    return $GrievancesTable(attachedDatabase, alias);
  }
}

class Grievance extends DataClass implements Insertable<Grievance> {
  final int id;
  final String clientUuid;
  final String orgId;
  final String? raisedBy;
  final bool isAnonymous;
  final String lang;
  final String rawText;
  final DateTime createdAt;
  final int syncStatus;
  const Grievance({
    required this.id,
    required this.clientUuid,
    required this.orgId,
    this.raisedBy,
    required this.isAnonymous,
    required this.lang,
    required this.rawText,
    required this.createdAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client_uuid'] = Variable<String>(clientUuid);
    map['org_id'] = Variable<String>(orgId);
    if (!nullToAbsent || raisedBy != null) {
      map['raised_by'] = Variable<String>(raisedBy);
    }
    map['is_anonymous'] = Variable<bool>(isAnonymous);
    map['lang'] = Variable<String>(lang);
    map['raw_text'] = Variable<String>(rawText);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<int>(syncStatus);
    return map;
  }

  GrievancesCompanion toCompanion(bool nullToAbsent) {
    return GrievancesCompanion(
      id: Value(id),
      clientUuid: Value(clientUuid),
      orgId: Value(orgId),
      raisedBy: raisedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(raisedBy),
      isAnonymous: Value(isAnonymous),
      lang: Value(lang),
      rawText: Value(rawText),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Grievance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Grievance(
      id: serializer.fromJson<int>(json['id']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      orgId: serializer.fromJson<String>(json['orgId']),
      raisedBy: serializer.fromJson<String?>(json['raisedBy']),
      isAnonymous: serializer.fromJson<bool>(json['isAnonymous']),
      lang: serializer.fromJson<String>(json['lang']),
      rawText: serializer.fromJson<String>(json['rawText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'orgId': serializer.toJson<String>(orgId),
      'raisedBy': serializer.toJson<String?>(raisedBy),
      'isAnonymous': serializer.toJson<bool>(isAnonymous),
      'lang': serializer.toJson<String>(lang),
      'rawText': serializer.toJson<String>(rawText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<int>(syncStatus),
    };
  }

  Grievance copyWith({
    int? id,
    String? clientUuid,
    String? orgId,
    Value<String?> raisedBy = const Value.absent(),
    bool? isAnonymous,
    String? lang,
    String? rawText,
    DateTime? createdAt,
    int? syncStatus,
  }) => Grievance(
    id: id ?? this.id,
    clientUuid: clientUuid ?? this.clientUuid,
    orgId: orgId ?? this.orgId,
    raisedBy: raisedBy.present ? raisedBy.value : this.raisedBy,
    isAnonymous: isAnonymous ?? this.isAnonymous,
    lang: lang ?? this.lang,
    rawText: rawText ?? this.rawText,
    createdAt: createdAt ?? this.createdAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Grievance copyWithCompanion(GrievancesCompanion data) {
    return Grievance(
      id: data.id.present ? data.id.value : this.id,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      raisedBy: data.raisedBy.present ? data.raisedBy.value : this.raisedBy,
      isAnonymous: data.isAnonymous.present
          ? data.isAnonymous.value
          : this.isAnonymous,
      lang: data.lang.present ? data.lang.value : this.lang,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Grievance(')
          ..write('id: $id, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('orgId: $orgId, ')
          ..write('raisedBy: $raisedBy, ')
          ..write('isAnonymous: $isAnonymous, ')
          ..write('lang: $lang, ')
          ..write('rawText: $rawText, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientUuid,
    orgId,
    raisedBy,
    isAnonymous,
    lang,
    rawText,
    createdAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Grievance &&
          other.id == this.id &&
          other.clientUuid == this.clientUuid &&
          other.orgId == this.orgId &&
          other.raisedBy == this.raisedBy &&
          other.isAnonymous == this.isAnonymous &&
          other.lang == this.lang &&
          other.rawText == this.rawText &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class GrievancesCompanion extends UpdateCompanion<Grievance> {
  final Value<int> id;
  final Value<String> clientUuid;
  final Value<String> orgId;
  final Value<String?> raisedBy;
  final Value<bool> isAnonymous;
  final Value<String> lang;
  final Value<String> rawText;
  final Value<DateTime> createdAt;
  final Value<int> syncStatus;
  const GrievancesCompanion({
    this.id = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.orgId = const Value.absent(),
    this.raisedBy = const Value.absent(),
    this.isAnonymous = const Value.absent(),
    this.lang = const Value.absent(),
    this.rawText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  GrievancesCompanion.insert({
    this.id = const Value.absent(),
    required String clientUuid,
    required String orgId,
    this.raisedBy = const Value.absent(),
    this.isAnonymous = const Value.absent(),
    required String lang,
    required String rawText,
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
  }) : clientUuid = Value(clientUuid),
       orgId = Value(orgId),
       lang = Value(lang),
       rawText = Value(rawText);
  static Insertable<Grievance> custom({
    Expression<int>? id,
    Expression<String>? clientUuid,
    Expression<String>? orgId,
    Expression<String>? raisedBy,
    Expression<bool>? isAnonymous,
    Expression<String>? lang,
    Expression<String>? rawText,
    Expression<DateTime>? createdAt,
    Expression<int>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (orgId != null) 'org_id': orgId,
      if (raisedBy != null) 'raised_by': raisedBy,
      if (isAnonymous != null) 'is_anonymous': isAnonymous,
      if (lang != null) 'lang': lang,
      if (rawText != null) 'raw_text': rawText,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  GrievancesCompanion copyWith({
    Value<int>? id,
    Value<String>? clientUuid,
    Value<String>? orgId,
    Value<String?>? raisedBy,
    Value<bool>? isAnonymous,
    Value<String>? lang,
    Value<String>? rawText,
    Value<DateTime>? createdAt,
    Value<int>? syncStatus,
  }) {
    return GrievancesCompanion(
      id: id ?? this.id,
      clientUuid: clientUuid ?? this.clientUuid,
      orgId: orgId ?? this.orgId,
      raisedBy: raisedBy ?? this.raisedBy,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      lang: lang ?? this.lang,
      rawText: rawText ?? this.rawText,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (raisedBy.present) {
      map['raised_by'] = Variable<String>(raisedBy.value);
    }
    if (isAnonymous.present) {
      map['is_anonymous'] = Variable<bool>(isAnonymous.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrievancesCompanion(')
          ..write('id: $id, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('orgId: $orgId, ')
          ..write('raisedBy: $raisedBy, ')
          ..write('isAnonymous: $isAnonymous, ')
          ..write('lang: $lang, ')
          ..write('rawText: $rawText, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $CachedObligationsTable extends CachedObligations
    with TableInfo<$CachedObligationsTable, CachedObligation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedObligationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mineIdMeta = const VerificationMeta('mineId');
  @override
  late final GeneratedColumn<String> mineId = GeneratedColumn<String>(
    'mine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerRoleMeta = const VerificationMeta(
    'ownerRole',
  );
  @override
  late final GeneratedColumn<String> ownerRole = GeneratedColumn<String>(
    'owner_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Safety'),
  );
  static const VerificationMeta _evidenceRequiredMeta = const VerificationMeta(
    'evidenceRequired',
  );
  @override
  late final GeneratedColumn<String> evidenceRequired = GeneratedColumn<String>(
    'evidence_required',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    mineId,
    title,
    description,
    frequency,
    ownerRole,
    dueDate,
    status,
    category,
    evidenceRequired,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_obligations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedObligation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('mine_id')) {
      context.handle(
        _mineIdMeta,
        mineId.isAcceptableOrUnknown(data['mine_id']!, _mineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mineIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('owner_role')) {
      context.handle(
        _ownerRoleMeta,
        ownerRole.isAcceptableOrUnknown(data['owner_role']!, _ownerRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerRoleMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('evidence_required')) {
      context.handle(
        _evidenceRequiredMeta,
        evidenceRequired.isAcceptableOrUnknown(
          data['evidence_required']!,
          _evidenceRequiredMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {remoteId};
  @override
  CachedObligation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedObligation(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
      mineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mine_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      ownerRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_role'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      evidenceRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_required'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $CachedObligationsTable createAlias(String alias) {
    return $CachedObligationsTable(attachedDatabase, alias);
  }
}

class CachedObligation extends DataClass
    implements Insertable<CachedObligation> {
  final String remoteId;
  final String mineId;
  final String title;
  final String? description;
  final String frequency;
  final String ownerRole;
  final DateTime dueDate;
  final String status;
  final String category;
  final String evidenceRequired;
  final DateTime updatedAt;
  final int syncStatus;
  const CachedObligation({
    required this.remoteId,
    required this.mineId,
    required this.title,
    this.description,
    required this.frequency,
    required this.ownerRole,
    required this.dueDate,
    required this.status,
    required this.category,
    required this.evidenceRequired,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['remote_id'] = Variable<String>(remoteId);
    map['mine_id'] = Variable<String>(mineId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['frequency'] = Variable<String>(frequency);
    map['owner_role'] = Variable<String>(ownerRole);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['status'] = Variable<String>(status);
    map['category'] = Variable<String>(category);
    map['evidence_required'] = Variable<String>(evidenceRequired);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<int>(syncStatus);
    return map;
  }

  CachedObligationsCompanion toCompanion(bool nullToAbsent) {
    return CachedObligationsCompanion(
      remoteId: Value(remoteId),
      mineId: Value(mineId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      frequency: Value(frequency),
      ownerRole: Value(ownerRole),
      dueDate: Value(dueDate),
      status: Value(status),
      category: Value(category),
      evidenceRequired: Value(evidenceRequired),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory CachedObligation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedObligation(
      remoteId: serializer.fromJson<String>(json['remoteId']),
      mineId: serializer.fromJson<String>(json['mineId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      frequency: serializer.fromJson<String>(json['frequency']),
      ownerRole: serializer.fromJson<String>(json['ownerRole']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      category: serializer.fromJson<String>(json['category']),
      evidenceRequired: serializer.fromJson<String>(json['evidenceRequired']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String>(remoteId),
      'mineId': serializer.toJson<String>(mineId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'frequency': serializer.toJson<String>(frequency),
      'ownerRole': serializer.toJson<String>(ownerRole),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'status': serializer.toJson<String>(status),
      'category': serializer.toJson<String>(category),
      'evidenceRequired': serializer.toJson<String>(evidenceRequired),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<int>(syncStatus),
    };
  }

  CachedObligation copyWith({
    String? remoteId,
    String? mineId,
    String? title,
    Value<String?> description = const Value.absent(),
    String? frequency,
    String? ownerRole,
    DateTime? dueDate,
    String? status,
    String? category,
    String? evidenceRequired,
    DateTime? updatedAt,
    int? syncStatus,
  }) => CachedObligation(
    remoteId: remoteId ?? this.remoteId,
    mineId: mineId ?? this.mineId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    frequency: frequency ?? this.frequency,
    ownerRole: ownerRole ?? this.ownerRole,
    dueDate: dueDate ?? this.dueDate,
    status: status ?? this.status,
    category: category ?? this.category,
    evidenceRequired: evidenceRequired ?? this.evidenceRequired,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  CachedObligation copyWithCompanion(CachedObligationsCompanion data) {
    return CachedObligation(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      mineId: data.mineId.present ? data.mineId.value : this.mineId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      ownerRole: data.ownerRole.present ? data.ownerRole.value : this.ownerRole,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      category: data.category.present ? data.category.value : this.category,
      evidenceRequired: data.evidenceRequired.present
          ? data.evidenceRequired.value
          : this.evidenceRequired,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedObligation(')
          ..write('remoteId: $remoteId, ')
          ..write('mineId: $mineId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('frequency: $frequency, ')
          ..write('ownerRole: $ownerRole, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('category: $category, ')
          ..write('evidenceRequired: $evidenceRequired, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    mineId,
    title,
    description,
    frequency,
    ownerRole,
    dueDate,
    status,
    category,
    evidenceRequired,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedObligation &&
          other.remoteId == this.remoteId &&
          other.mineId == this.mineId &&
          other.title == this.title &&
          other.description == this.description &&
          other.frequency == this.frequency &&
          other.ownerRole == this.ownerRole &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.category == this.category &&
          other.evidenceRequired == this.evidenceRequired &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class CachedObligationsCompanion extends UpdateCompanion<CachedObligation> {
  final Value<String> remoteId;
  final Value<String> mineId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> frequency;
  final Value<String> ownerRole;
  final Value<DateTime> dueDate;
  final Value<String> status;
  final Value<String> category;
  final Value<String> evidenceRequired;
  final Value<DateTime> updatedAt;
  final Value<int> syncStatus;
  final Value<int> rowid;
  const CachedObligationsCompanion({
    this.remoteId = const Value.absent(),
    this.mineId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.frequency = const Value.absent(),
    this.ownerRole = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.category = const Value.absent(),
    this.evidenceRequired = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedObligationsCompanion.insert({
    required String remoteId,
    required String mineId,
    required String title,
    this.description = const Value.absent(),
    required String frequency,
    required String ownerRole,
    required DateTime dueDate,
    required String status,
    this.category = const Value.absent(),
    this.evidenceRequired = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : remoteId = Value(remoteId),
       mineId = Value(mineId),
       title = Value(title),
       frequency = Value(frequency),
       ownerRole = Value(ownerRole),
       dueDate = Value(dueDate),
       status = Value(status);
  static Insertable<CachedObligation> custom({
    Expression<String>? remoteId,
    Expression<String>? mineId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? frequency,
    Expression<String>? ownerRole,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<String>? category,
    Expression<String>? evidenceRequired,
    Expression<DateTime>? updatedAt,
    Expression<int>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (mineId != null) 'mine_id': mineId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (frequency != null) 'frequency': frequency,
      if (ownerRole != null) 'owner_role': ownerRole,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (category != null) 'category': category,
      if (evidenceRequired != null) 'evidence_required': evidenceRequired,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedObligationsCompanion copyWith({
    Value<String>? remoteId,
    Value<String>? mineId,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? frequency,
    Value<String>? ownerRole,
    Value<DateTime>? dueDate,
    Value<String>? status,
    Value<String>? category,
    Value<String>? evidenceRequired,
    Value<DateTime>? updatedAt,
    Value<int>? syncStatus,
    Value<int>? rowid,
  }) {
    return CachedObligationsCompanion(
      remoteId: remoteId ?? this.remoteId,
      mineId: mineId ?? this.mineId,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      ownerRole: ownerRole ?? this.ownerRole,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      category: category ?? this.category,
      evidenceRequired: evidenceRequired ?? this.evidenceRequired,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (mineId.present) {
      map['mine_id'] = Variable<String>(mineId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (ownerRole.present) {
      map['owner_role'] = Variable<String>(ownerRole.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (evidenceRequired.present) {
      map['evidence_required'] = Variable<String>(evidenceRequired.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedObligationsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('mineId: $mineId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('frequency: $frequency, ')
          ..write('ownerRole: $ownerRole, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('category: $category, ')
          ..write('evidenceRequired: $evidenceRequired, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SosSignalsTable extends SosSignals
    with TableInfo<$SosSignalsTable, SosSignal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SosSignalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientUuid,
    userName,
    role,
    latitude,
    longitude,
    status,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sos_signals';
  @override
  VerificationContext validateIntegrity(
    Insertable<SosSignal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    } else if (isInserting) {
      context.missing(_userNameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientUuid};
  @override
  SosSignal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SosSignal(
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $SosSignalsTable createAlias(String alias) {
    return $SosSignalsTable(attachedDatabase, alias);
  }
}

class SosSignal extends DataClass implements Insertable<SosSignal> {
  final String clientUuid;
  final String userName;
  final String role;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int syncStatus;
  const SosSignal({
    required this.clientUuid,
    required this.userName,
    required this.role,
    this.latitude,
    this.longitude,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_uuid'] = Variable<String>(clientUuid);
    map['user_name'] = Variable<String>(userName);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<int>(syncStatus);
    return map;
  }

  SosSignalsCompanion toCompanion(bool nullToAbsent) {
    return SosSignalsCompanion(
      clientUuid: Value(clientUuid),
      userName: Value(userName),
      role: Value(role),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory SosSignal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SosSignal(
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      userName: serializer.fromJson<String>(json['userName']),
      role: serializer.fromJson<String>(json['role']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientUuid': serializer.toJson<String>(clientUuid),
      'userName': serializer.toJson<String>(userName),
      'role': serializer.toJson<String>(role),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<int>(syncStatus),
    };
  }

  SosSignal copyWith({
    String? clientUuid,
    String? userName,
    String? role,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) => SosSignal(
    clientUuid: clientUuid ?? this.clientUuid,
    userName: userName ?? this.userName,
    role: role ?? this.role,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  SosSignal copyWithCompanion(SosSignalsCompanion data) {
    return SosSignal(
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      userName: data.userName.present ? data.userName.value : this.userName,
      role: data.role.present ? data.role.value : this.role,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SosSignal(')
          ..write('clientUuid: $clientUuid, ')
          ..write('userName: $userName, ')
          ..write('role: $role, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientUuid,
    userName,
    role,
    latitude,
    longitude,
    status,
    createdAt,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SosSignal &&
          other.clientUuid == this.clientUuid &&
          other.userName == this.userName &&
          other.role == this.role &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class SosSignalsCompanion extends UpdateCompanion<SosSignal> {
  final Value<String> clientUuid;
  final Value<String> userName;
  final Value<String> role;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> syncStatus;
  final Value<int> rowid;
  const SosSignalsCompanion({
    this.clientUuid = const Value.absent(),
    this.userName = const Value.absent(),
    this.role = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SosSignalsCompanion.insert({
    required String clientUuid,
    required String userName,
    required String role,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientUuid = Value(clientUuid),
       userName = Value(userName),
       role = Value(role),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SosSignal> custom({
    Expression<String>? clientUuid,
    Expression<String>? userName,
    Expression<String>? role,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (userName != null) 'user_name': userName,
      if (role != null) 'role': role,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SosSignalsCompanion copyWith({
    Value<String>? clientUuid,
    Value<String>? userName,
    Value<String>? role,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? syncStatus,
    Value<int>? rowid,
  }) {
    return SosSignalsCompanion(
      clientUuid: clientUuid ?? this.clientUuid,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SosSignalsCompanion(')
          ..write('clientUuid: $clientUuid, ')
          ..write('userName: $userName, ')
          ..write('role: $role, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ObservationsTable observations = $ObservationsTable(this);
  late final $EvidencesTable evidences = $EvidencesTable(this);
  late final $GrievancesTable grievances = $GrievancesTable(this);
  late final $CachedObligationsTable cachedObligations =
      $CachedObligationsTable(this);
  late final $SosSignalsTable sosSignals = $SosSignalsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    observations,
    evidences,
    grievances,
    cachedObligations,
    sosSignals,
  ];
}

typedef $$ObservationsTableCreateCompanionBuilder =
    ObservationsCompanion Function({
      Value<int> id,
      required String orgId,
      required String reportedBy,
      required String category,
      required String location,
      Value<String> severity,
      Value<String> description,
      Value<DateTime> createdAt,
      required String clientUuid,
      Value<double?> trustScore,
      Value<int> syncStatus,
    });
typedef $$ObservationsTableUpdateCompanionBuilder =
    ObservationsCompanion Function({
      Value<int> id,
      Value<String> orgId,
      Value<String> reportedBy,
      Value<String> category,
      Value<String> location,
      Value<String> severity,
      Value<String> description,
      Value<DateTime> createdAt,
      Value<String> clientUuid,
      Value<double?> trustScore,
      Value<int> syncStatus,
    });

class $$ObservationsTableFilterComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportedBy => $composableBuilder(
    column: $table.reportedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get trustScore => $composableBuilder(
    column: $table.trustScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ObservationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedBy => $composableBuilder(
    column: $table.reportedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get trustScore => $composableBuilder(
    column: $table.trustScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ObservationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get reportedBy => $composableBuilder(
    column: $table.reportedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get trustScore => $composableBuilder(
    column: $table.trustScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$ObservationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObservationsTable,
          Observation,
          $$ObservationsTableFilterComposer,
          $$ObservationsTableOrderingComposer,
          $$ObservationsTableAnnotationComposer,
          $$ObservationsTableCreateCompanionBuilder,
          $$ObservationsTableUpdateCompanionBuilder,
          (
            Observation,
            BaseReferences<_$AppDatabase, $ObservationsTable, Observation>,
          ),
          Observation,
          PrefetchHooks Function()
        > {
  $$ObservationsTableTableManager(_$AppDatabase db, $ObservationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObservationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObservationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> orgId = const Value.absent(),
                Value<String> reportedBy = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<double?> trustScore = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
              }) => ObservationsCompanion(
                id: id,
                orgId: orgId,
                reportedBy: reportedBy,
                category: category,
                location: location,
                severity: severity,
                description: description,
                createdAt: createdAt,
                clientUuid: clientUuid,
                trustScore: trustScore,
                syncStatus: syncStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String orgId,
                required String reportedBy,
                required String category,
                required String location,
                Value<String> severity = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String clientUuid,
                Value<double?> trustScore = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
              }) => ObservationsCompanion.insert(
                id: id,
                orgId: orgId,
                reportedBy: reportedBy,
                category: category,
                location: location,
                severity: severity,
                description: description,
                createdAt: createdAt,
                clientUuid: clientUuid,
                trustScore: trustScore,
                syncStatus: syncStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ObservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObservationsTable,
      Observation,
      $$ObservationsTableFilterComposer,
      $$ObservationsTableOrderingComposer,
      $$ObservationsTableAnnotationComposer,
      $$ObservationsTableCreateCompanionBuilder,
      $$ObservationsTableUpdateCompanionBuilder,
      (
        Observation,
        BaseReferences<_$AppDatabase, $ObservationsTable, Observation>,
      ),
      Observation,
      PrefetchHooks Function()
    >;
typedef $$EvidencesTableCreateCompanionBuilder =
    EvidencesCompanion Function({
      Value<int> id,
      required String entityType,
      required String entityId,
      required DateTime capturedAt,
      required String location,
      required String filePath,
      Value<double?> trustScore,
      Value<String?> phash,
    });
typedef $$EvidencesTableUpdateCompanionBuilder =
    EvidencesCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<DateTime> capturedAt,
      Value<String> location,
      Value<String> filePath,
      Value<double?> trustScore,
      Value<String?> phash,
    });

class $$EvidencesTableFilterComposer
    extends Composer<_$AppDatabase, $EvidencesTable> {
  $$EvidencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get trustScore => $composableBuilder(
    column: $table.trustScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phash => $composableBuilder(
    column: $table.phash,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EvidencesTableOrderingComposer
    extends Composer<_$AppDatabase, $EvidencesTable> {
  $$EvidencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get trustScore => $composableBuilder(
    column: $table.trustScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phash => $composableBuilder(
    column: $table.phash,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EvidencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvidencesTable> {
  $$EvidencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<double> get trustScore => $composableBuilder(
    column: $table.trustScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phash =>
      $composableBuilder(column: $table.phash, builder: (column) => column);
}

class $$EvidencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EvidencesTable,
          Evidence,
          $$EvidencesTableFilterComposer,
          $$EvidencesTableOrderingComposer,
          $$EvidencesTableAnnotationComposer,
          $$EvidencesTableCreateCompanionBuilder,
          $$EvidencesTableUpdateCompanionBuilder,
          (Evidence, BaseReferences<_$AppDatabase, $EvidencesTable, Evidence>),
          Evidence,
          PrefetchHooks Function()
        > {
  $$EvidencesTableTableManager(_$AppDatabase db, $EvidencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<double?> trustScore = const Value.absent(),
                Value<String?> phash = const Value.absent(),
              }) => EvidencesCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                capturedAt: capturedAt,
                location: location,
                filePath: filePath,
                trustScore: trustScore,
                phash: phash,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityId,
                required DateTime capturedAt,
                required String location,
                required String filePath,
                Value<double?> trustScore = const Value.absent(),
                Value<String?> phash = const Value.absent(),
              }) => EvidencesCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                capturedAt: capturedAt,
                location: location,
                filePath: filePath,
                trustScore: trustScore,
                phash: phash,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EvidencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EvidencesTable,
      Evidence,
      $$EvidencesTableFilterComposer,
      $$EvidencesTableOrderingComposer,
      $$EvidencesTableAnnotationComposer,
      $$EvidencesTableCreateCompanionBuilder,
      $$EvidencesTableUpdateCompanionBuilder,
      (Evidence, BaseReferences<_$AppDatabase, $EvidencesTable, Evidence>),
      Evidence,
      PrefetchHooks Function()
    >;
typedef $$GrievancesTableCreateCompanionBuilder =
    GrievancesCompanion Function({
      Value<int> id,
      required String clientUuid,
      required String orgId,
      Value<String?> raisedBy,
      Value<bool> isAnonymous,
      required String lang,
      required String rawText,
      Value<DateTime> createdAt,
      Value<int> syncStatus,
    });
typedef $$GrievancesTableUpdateCompanionBuilder =
    GrievancesCompanion Function({
      Value<int> id,
      Value<String> clientUuid,
      Value<String> orgId,
      Value<String?> raisedBy,
      Value<bool> isAnonymous,
      Value<String> lang,
      Value<String> rawText,
      Value<DateTime> createdAt,
      Value<int> syncStatus,
    });

class $$GrievancesTableFilterComposer
    extends Composer<_$AppDatabase, $GrievancesTable> {
  $$GrievancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get raisedBy => $composableBuilder(
    column: $table.raisedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAnonymous => $composableBuilder(
    column: $table.isAnonymous,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GrievancesTableOrderingComposer
    extends Composer<_$AppDatabase, $GrievancesTable> {
  $$GrievancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get raisedBy => $composableBuilder(
    column: $table.raisedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAnonymous => $composableBuilder(
    column: $table.isAnonymous,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GrievancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrievancesTable> {
  $$GrievancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get raisedBy =>
      $composableBuilder(column: $table.raisedBy, builder: (column) => column);

  GeneratedColumn<bool> get isAnonymous => $composableBuilder(
    column: $table.isAnonymous,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$GrievancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrievancesTable,
          Grievance,
          $$GrievancesTableFilterComposer,
          $$GrievancesTableOrderingComposer,
          $$GrievancesTableAnnotationComposer,
          $$GrievancesTableCreateCompanionBuilder,
          $$GrievancesTableUpdateCompanionBuilder,
          (
            Grievance,
            BaseReferences<_$AppDatabase, $GrievancesTable, Grievance>,
          ),
          Grievance,
          PrefetchHooks Function()
        > {
  $$GrievancesTableTableManager(_$AppDatabase db, $GrievancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrievancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrievancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrievancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<String> orgId = const Value.absent(),
                Value<String?> raisedBy = const Value.absent(),
                Value<bool> isAnonymous = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
              }) => GrievancesCompanion(
                id: id,
                clientUuid: clientUuid,
                orgId: orgId,
                raisedBy: raisedBy,
                isAnonymous: isAnonymous,
                lang: lang,
                rawText: rawText,
                createdAt: createdAt,
                syncStatus: syncStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clientUuid,
                required String orgId,
                Value<String?> raisedBy = const Value.absent(),
                Value<bool> isAnonymous = const Value.absent(),
                required String lang,
                required String rawText,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
              }) => GrievancesCompanion.insert(
                id: id,
                clientUuid: clientUuid,
                orgId: orgId,
                raisedBy: raisedBy,
                isAnonymous: isAnonymous,
                lang: lang,
                rawText: rawText,
                createdAt: createdAt,
                syncStatus: syncStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GrievancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrievancesTable,
      Grievance,
      $$GrievancesTableFilterComposer,
      $$GrievancesTableOrderingComposer,
      $$GrievancesTableAnnotationComposer,
      $$GrievancesTableCreateCompanionBuilder,
      $$GrievancesTableUpdateCompanionBuilder,
      (Grievance, BaseReferences<_$AppDatabase, $GrievancesTable, Grievance>),
      Grievance,
      PrefetchHooks Function()
    >;
typedef $$CachedObligationsTableCreateCompanionBuilder =
    CachedObligationsCompanion Function({
      required String remoteId,
      required String mineId,
      required String title,
      Value<String?> description,
      required String frequency,
      required String ownerRole,
      required DateTime dueDate,
      required String status,
      Value<String> category,
      Value<String> evidenceRequired,
      Value<DateTime> updatedAt,
      Value<int> syncStatus,
      Value<int> rowid,
    });
typedef $$CachedObligationsTableUpdateCompanionBuilder =
    CachedObligationsCompanion Function({
      Value<String> remoteId,
      Value<String> mineId,
      Value<String> title,
      Value<String?> description,
      Value<String> frequency,
      Value<String> ownerRole,
      Value<DateTime> dueDate,
      Value<String> status,
      Value<String> category,
      Value<String> evidenceRequired,
      Value<DateTime> updatedAt,
      Value<int> syncStatus,
      Value<int> rowid,
    });

class $$CachedObligationsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedObligationsTable> {
  $$CachedObligationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mineId => $composableBuilder(
    column: $table.mineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerRole => $composableBuilder(
    column: $table.ownerRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceRequired => $composableBuilder(
    column: $table.evidenceRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedObligationsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedObligationsTable> {
  $$CachedObligationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mineId => $composableBuilder(
    column: $table.mineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerRole => $composableBuilder(
    column: $table.ownerRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceRequired => $composableBuilder(
    column: $table.evidenceRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedObligationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedObligationsTable> {
  $$CachedObligationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get mineId =>
      $composableBuilder(column: $table.mineId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get ownerRole =>
      $composableBuilder(column: $table.ownerRole, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get evidenceRequired => $composableBuilder(
    column: $table.evidenceRequired,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$CachedObligationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedObligationsTable,
          CachedObligation,
          $$CachedObligationsTableFilterComposer,
          $$CachedObligationsTableOrderingComposer,
          $$CachedObligationsTableAnnotationComposer,
          $$CachedObligationsTableCreateCompanionBuilder,
          $$CachedObligationsTableUpdateCompanionBuilder,
          (
            CachedObligation,
            BaseReferences<
              _$AppDatabase,
              $CachedObligationsTable,
              CachedObligation
            >,
          ),
          CachedObligation,
          PrefetchHooks Function()
        > {
  $$CachedObligationsTableTableManager(
    _$AppDatabase db,
    $CachedObligationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedObligationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedObligationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedObligationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> remoteId = const Value.absent(),
                Value<String> mineId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String> ownerRole = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> evidenceRequired = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedObligationsCompanion(
                remoteId: remoteId,
                mineId: mineId,
                title: title,
                description: description,
                frequency: frequency,
                ownerRole: ownerRole,
                dueDate: dueDate,
                status: status,
                category: category,
                evidenceRequired: evidenceRequired,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String remoteId,
                required String mineId,
                required String title,
                Value<String?> description = const Value.absent(),
                required String frequency,
                required String ownerRole,
                required DateTime dueDate,
                required String status,
                Value<String> category = const Value.absent(),
                Value<String> evidenceRequired = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedObligationsCompanion.insert(
                remoteId: remoteId,
                mineId: mineId,
                title: title,
                description: description,
                frequency: frequency,
                ownerRole: ownerRole,
                dueDate: dueDate,
                status: status,
                category: category,
                evidenceRequired: evidenceRequired,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedObligationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedObligationsTable,
      CachedObligation,
      $$CachedObligationsTableFilterComposer,
      $$CachedObligationsTableOrderingComposer,
      $$CachedObligationsTableAnnotationComposer,
      $$CachedObligationsTableCreateCompanionBuilder,
      $$CachedObligationsTableUpdateCompanionBuilder,
      (
        CachedObligation,
        BaseReferences<
          _$AppDatabase,
          $CachedObligationsTable,
          CachedObligation
        >,
      ),
      CachedObligation,
      PrefetchHooks Function()
    >;
typedef $$SosSignalsTableCreateCompanionBuilder =
    SosSignalsCompanion Function({
      required String clientUuid,
      required String userName,
      required String role,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String> status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> syncStatus,
      Value<int> rowid,
    });
typedef $$SosSignalsTableUpdateCompanionBuilder =
    SosSignalsCompanion Function({
      Value<String> clientUuid,
      Value<String> userName,
      Value<String> role,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> syncStatus,
      Value<int> rowid,
    });

class $$SosSignalsTableFilterComposer
    extends Composer<_$AppDatabase, $SosSignalsTable> {
  $$SosSignalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SosSignalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SosSignalsTable> {
  $$SosSignalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SosSignalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SosSignalsTable> {
  $$SosSignalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$SosSignalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SosSignalsTable,
          SosSignal,
          $$SosSignalsTableFilterComposer,
          $$SosSignalsTableOrderingComposer,
          $$SosSignalsTableAnnotationComposer,
          $$SosSignalsTableCreateCompanionBuilder,
          $$SosSignalsTableUpdateCompanionBuilder,
          (
            SosSignal,
            BaseReferences<_$AppDatabase, $SosSignalsTable, SosSignal>,
          ),
          SosSignal,
          PrefetchHooks Function()
        > {
  $$SosSignalsTableTableManager(_$AppDatabase db, $SosSignalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SosSignalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SosSignalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SosSignalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientUuid = const Value.absent(),
                Value<String> userName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SosSignalsCompanion(
                clientUuid: clientUuid,
                userName: userName,
                role: role,
                latitude: latitude,
                longitude: longitude,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientUuid,
                required String userName,
                required String role,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SosSignalsCompanion.insert(
                clientUuid: clientUuid,
                userName: userName,
                role: role,
                latitude: latitude,
                longitude: longitude,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SosSignalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SosSignalsTable,
      SosSignal,
      $$SosSignalsTableFilterComposer,
      $$SosSignalsTableOrderingComposer,
      $$SosSignalsTableAnnotationComposer,
      $$SosSignalsTableCreateCompanionBuilder,
      $$SosSignalsTableUpdateCompanionBuilder,
      (SosSignal, BaseReferences<_$AppDatabase, $SosSignalsTable, SosSignal>),
      SosSignal,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ObservationsTableTableManager get observations =>
      $$ObservationsTableTableManager(_db, _db.observations);
  $$EvidencesTableTableManager get evidences =>
      $$EvidencesTableTableManager(_db, _db.evidences);
  $$GrievancesTableTableManager get grievances =>
      $$GrievancesTableTableManager(_db, _db.grievances);
  $$CachedObligationsTableTableManager get cachedObligations =>
      $$CachedObligationsTableTableManager(_db, _db.cachedObligations);
  $$SosSignalsTableTableManager get sosSignals =>
      $$SosSignalsTableTableManager(_db, _db.sosSignals);
}
