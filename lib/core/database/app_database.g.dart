// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FaceEmbeddingsTable extends FaceEmbeddings
    with TableInfo<$FaceEmbeddingsTable, FaceEmbeddingEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FaceEmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
      'student_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _embeddingMeta =
      const VerificationMeta('embedding');
  @override
  late final GeneratedColumn<Uint8List> embedding = GeneratedColumn<Uint8List>(
      'embedding', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _enrollmentDateMeta =
      const VerificationMeta('enrollmentDate');
  @override
  late final GeneratedColumn<int> enrollmentDate = GeneratedColumn<int>(
      'enrollment_date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _syncedToSupabaseMeta =
      const VerificationMeta('syncedToSupabase');
  @override
  late final GeneratedColumn<bool> syncedToSupabase = GeneratedColumn<bool>(
      'synced_to_supabase', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("synced_to_supabase" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        studentId,
        embedding,
        enrollmentDate,
        updatedAt,
        isActive,
        syncedToSupabase
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'face_embeddings';
  @override
  VerificationContext validateIntegrity(
      Insertable<FaceEmbeddingEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('embedding')) {
      context.handle(_embeddingMeta,
          embedding.isAcceptableOrUnknown(data['embedding']!, _embeddingMeta));
    } else if (isInserting) {
      context.missing(_embeddingMeta);
    }
    if (data.containsKey('enrollment_date')) {
      context.handle(
          _enrollmentDateMeta,
          enrollmentDate.isAcceptableOrUnknown(
              data['enrollment_date']!, _enrollmentDateMeta));
    } else if (isInserting) {
      context.missing(_enrollmentDateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('synced_to_supabase')) {
      context.handle(
          _syncedToSupabaseMeta,
          syncedToSupabase.isAcceptableOrUnknown(
              data['synced_to_supabase']!, _syncedToSupabaseMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FaceEmbeddingEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FaceEmbeddingEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}student_id'])!,
      embedding: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}embedding'])!,
      enrollmentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}enrollment_date'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      syncedToSupabase: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}synced_to_supabase'])!,
    );
  }

  @override
  $FaceEmbeddingsTable createAlias(String alias) {
    return $FaceEmbeddingsTable(attachedDatabase, alias);
  }
}

class FaceEmbeddingEntity extends DataClass
    implements Insertable<FaceEmbeddingEntity> {
  final String id;
  final String studentId;
  final Uint8List embedding;
  final int enrollmentDate;
  final int updatedAt;
  final bool isActive;
  final bool syncedToSupabase;
  const FaceEmbeddingEntity(
      {required this.id,
      required this.studentId,
      required this.embedding,
      required this.enrollmentDate,
      required this.updatedAt,
      required this.isActive,
      required this.syncedToSupabase});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['embedding'] = Variable<Uint8List>(embedding);
    map['enrollment_date'] = Variable<int>(enrollmentDate);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    map['synced_to_supabase'] = Variable<bool>(syncedToSupabase);
    return map;
  }

  FaceEmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return FaceEmbeddingsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      embedding: Value(embedding),
      enrollmentDate: Value(enrollmentDate),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
      syncedToSupabase: Value(syncedToSupabase),
    );
  }

  factory FaceEmbeddingEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FaceEmbeddingEntity(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      embedding: serializer.fromJson<Uint8List>(json['embedding']),
      enrollmentDate: serializer.fromJson<int>(json['enrollmentDate']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncedToSupabase: serializer.fromJson<bool>(json['syncedToSupabase']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'embedding': serializer.toJson<Uint8List>(embedding),
      'enrollmentDate': serializer.toJson<int>(enrollmentDate),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'syncedToSupabase': serializer.toJson<bool>(syncedToSupabase),
    };
  }

  FaceEmbeddingEntity copyWith(
          {String? id,
          String? studentId,
          Uint8List? embedding,
          int? enrollmentDate,
          int? updatedAt,
          bool? isActive,
          bool? syncedToSupabase}) =>
      FaceEmbeddingEntity(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        embedding: embedding ?? this.embedding,
        enrollmentDate: enrollmentDate ?? this.enrollmentDate,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
        syncedToSupabase: syncedToSupabase ?? this.syncedToSupabase,
      );
  FaceEmbeddingEntity copyWithCompanion(FaceEmbeddingsCompanion data) {
    return FaceEmbeddingEntity(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
      enrollmentDate: data.enrollmentDate.present
          ? data.enrollmentDate.value
          : this.enrollmentDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncedToSupabase: data.syncedToSupabase.present
          ? data.syncedToSupabase.value
          : this.syncedToSupabase,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FaceEmbeddingEntity(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('embedding: $embedding, ')
          ..write('enrollmentDate: $enrollmentDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('syncedToSupabase: $syncedToSupabase')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      studentId,
      $driftBlobEquality.hash(embedding),
      enrollmentDate,
      updatedAt,
      isActive,
      syncedToSupabase);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FaceEmbeddingEntity &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          $driftBlobEquality.equals(other.embedding, this.embedding) &&
          other.enrollmentDate == this.enrollmentDate &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive &&
          other.syncedToSupabase == this.syncedToSupabase);
}

class FaceEmbeddingsCompanion extends UpdateCompanion<FaceEmbeddingEntity> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<Uint8List> embedding;
  final Value<int> enrollmentDate;
  final Value<int> updatedAt;
  final Value<bool> isActive;
  final Value<bool> syncedToSupabase;
  final Value<int> rowid;
  const FaceEmbeddingsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.embedding = const Value.absent(),
    this.enrollmentDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncedToSupabase = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FaceEmbeddingsCompanion.insert({
    required String id,
    required String studentId,
    required Uint8List embedding,
    required int enrollmentDate,
    required int updatedAt,
    this.isActive = const Value.absent(),
    this.syncedToSupabase = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        studentId = Value(studentId),
        embedding = Value(embedding),
        enrollmentDate = Value(enrollmentDate),
        updatedAt = Value(updatedAt);
  static Insertable<FaceEmbeddingEntity> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<Uint8List>? embedding,
    Expression<int>? enrollmentDate,
    Expression<int>? updatedAt,
    Expression<bool>? isActive,
    Expression<bool>? syncedToSupabase,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (embedding != null) 'embedding': embedding,
      if (enrollmentDate != null) 'enrollment_date': enrollmentDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (syncedToSupabase != null) 'synced_to_supabase': syncedToSupabase,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FaceEmbeddingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? studentId,
      Value<Uint8List>? embedding,
      Value<int>? enrollmentDate,
      Value<int>? updatedAt,
      Value<bool>? isActive,
      Value<bool>? syncedToSupabase,
      Value<int>? rowid}) {
    return FaceEmbeddingsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      embedding: embedding ?? this.embedding,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      syncedToSupabase: syncedToSupabase ?? this.syncedToSupabase,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (embedding.present) {
      map['embedding'] = Variable<Uint8List>(embedding.value);
    }
    if (enrollmentDate.present) {
      map['enrollment_date'] = Variable<int>(enrollmentDate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncedToSupabase.present) {
      map['synced_to_supabase'] = Variable<bool>(syncedToSupabase.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FaceEmbeddingsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('embedding: $embedding, ')
          ..write('enrollmentDate: $enrollmentDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('syncedToSupabase: $syncedToSupabase, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FaceEmbeddingsTable faceEmbeddings = $FaceEmbeddingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [faceEmbeddings];
}

typedef $$FaceEmbeddingsTableCreateCompanionBuilder = FaceEmbeddingsCompanion
    Function({
  required String id,
  required String studentId,
  required Uint8List embedding,
  required int enrollmentDate,
  required int updatedAt,
  Value<bool> isActive,
  Value<bool> syncedToSupabase,
  Value<int> rowid,
});
typedef $$FaceEmbeddingsTableUpdateCompanionBuilder = FaceEmbeddingsCompanion
    Function({
  Value<String> id,
  Value<String> studentId,
  Value<Uint8List> embedding,
  Value<int> enrollmentDate,
  Value<int> updatedAt,
  Value<bool> isActive,
  Value<bool> syncedToSupabase,
  Value<int> rowid,
});

class $$FaceEmbeddingsTableFilterComposer
    extends Composer<_$AppDatabase, $FaceEmbeddingsTable> {
  $$FaceEmbeddingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get embedding => $composableBuilder(
      column: $table.embedding, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get enrollmentDate => $composableBuilder(
      column: $table.enrollmentDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get syncedToSupabase => $composableBuilder(
      column: $table.syncedToSupabase,
      builder: (column) => ColumnFilters(column));
}

class $$FaceEmbeddingsTableOrderingComposer
    extends Composer<_$AppDatabase, $FaceEmbeddingsTable> {
  $$FaceEmbeddingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get embedding => $composableBuilder(
      column: $table.embedding, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get enrollmentDate => $composableBuilder(
      column: $table.enrollmentDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get syncedToSupabase => $composableBuilder(
      column: $table.syncedToSupabase,
      builder: (column) => ColumnOrderings(column));
}

class $$FaceEmbeddingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FaceEmbeddingsTable> {
  $$FaceEmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<Uint8List> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);

  GeneratedColumn<int> get enrollmentDate => $composableBuilder(
      column: $table.enrollmentDate, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get syncedToSupabase => $composableBuilder(
      column: $table.syncedToSupabase, builder: (column) => column);
}

class $$FaceEmbeddingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FaceEmbeddingsTable,
    FaceEmbeddingEntity,
    $$FaceEmbeddingsTableFilterComposer,
    $$FaceEmbeddingsTableOrderingComposer,
    $$FaceEmbeddingsTableAnnotationComposer,
    $$FaceEmbeddingsTableCreateCompanionBuilder,
    $$FaceEmbeddingsTableUpdateCompanionBuilder,
    (
      FaceEmbeddingEntity,
      BaseReferences<_$AppDatabase, $FaceEmbeddingsTable, FaceEmbeddingEntity>
    ),
    FaceEmbeddingEntity,
    PrefetchHooks Function()> {
  $$FaceEmbeddingsTableTableManager(
      _$AppDatabase db, $FaceEmbeddingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FaceEmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FaceEmbeddingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FaceEmbeddingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> studentId = const Value.absent(),
            Value<Uint8List> embedding = const Value.absent(),
            Value<int> enrollmentDate = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> syncedToSupabase = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FaceEmbeddingsCompanion(
            id: id,
            studentId: studentId,
            embedding: embedding,
            enrollmentDate: enrollmentDate,
            updatedAt: updatedAt,
            isActive: isActive,
            syncedToSupabase: syncedToSupabase,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String studentId,
            required Uint8List embedding,
            required int enrollmentDate,
            required int updatedAt,
            Value<bool> isActive = const Value.absent(),
            Value<bool> syncedToSupabase = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FaceEmbeddingsCompanion.insert(
            id: id,
            studentId: studentId,
            embedding: embedding,
            enrollmentDate: enrollmentDate,
            updatedAt: updatedAt,
            isActive: isActive,
            syncedToSupabase: syncedToSupabase,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FaceEmbeddingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FaceEmbeddingsTable,
    FaceEmbeddingEntity,
    $$FaceEmbeddingsTableFilterComposer,
    $$FaceEmbeddingsTableOrderingComposer,
    $$FaceEmbeddingsTableAnnotationComposer,
    $$FaceEmbeddingsTableCreateCompanionBuilder,
    $$FaceEmbeddingsTableUpdateCompanionBuilder,
    (
      FaceEmbeddingEntity,
      BaseReferences<_$AppDatabase, $FaceEmbeddingsTable, FaceEmbeddingEntity>
    ),
    FaceEmbeddingEntity,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FaceEmbeddingsTableTableManager get faceEmbeddings =>
      $$FaceEmbeddingsTableTableManager(_db, _db.faceEmbeddings);
}
