// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nisnMeta = const VerificationMeta('nisn');
  @override
  late final GeneratedColumn<String> nisn = GeneratedColumn<String>(
      'nisn', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      check: () => role.isIn(const ['siswa', 'admin', 'ortu']),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _fullnameMeta =
      const VerificationMeta('fullname');
  @override
  late final GeneratedColumn<String> fullname = GeneratedColumn<String>(
      'fullname', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nisn,
        passwordHash,
        role,
        fullname,
        email,
        phone,
        avatarUrl,
        isActive,
        createdAt,
        updatedAt,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nisn')) {
      context.handle(
          _nisnMeta, nisn.isAcceptableOrUnknown(data['nisn']!, _nisnMeta));
    } else if (isInserting) {
      context.missing(_nisnMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('fullname')) {
      context.handle(_fullnameMeta,
          fullname.isAcceptableOrUnknown(data['fullname']!, _fullnameMeta));
    } else if (isInserting) {
      context.missing(_fullnameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      nisn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nisn'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      fullname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fullname'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserEntity extends DataClass implements Insertable<UserEntity> {
  final String id;
  final String nisn;
  final String passwordHash;
  final String role;
  final String fullname;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final bool isActive;
  final int createdAt;
  final int updatedAt;
  final int? syncedAt;
  const UserEntity(
      {required this.id,
      required this.nisn,
      required this.passwordHash,
      required this.role,
      required this.fullname,
      this.email,
      this.phone,
      this.avatarUrl,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nisn'] = Variable<String>(nisn);
    map['password_hash'] = Variable<String>(passwordHash);
    map['role'] = Variable<String>(role);
    map['fullname'] = Variable<String>(fullname);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      nisn: Value(nisn),
      passwordHash: Value(passwordHash),
      role: Value(role),
      fullname: Value(fullname),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntity(
      id: serializer.fromJson<String>(json['id']),
      nisn: serializer.fromJson<String>(json['nisn']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      role: serializer.fromJson<String>(json['role']),
      fullname: serializer.fromJson<String>(json['fullname']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nisn': serializer.toJson<String>(nisn),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'role': serializer.toJson<String>(role),
      'fullname': serializer.toJson<String>(fullname),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
    };
  }

  UserEntity copyWith(
          {String? id,
          String? nisn,
          String? passwordHash,
          String? role,
          String? fullname,
          Value<String?> email = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> avatarUrl = const Value.absent(),
          bool? isActive,
          int? createdAt,
          int? updatedAt,
          Value<int?> syncedAt = const Value.absent()}) =>
      UserEntity(
        id: id ?? this.id,
        nisn: nisn ?? this.nisn,
        passwordHash: passwordHash ?? this.passwordHash,
        role: role ?? this.role,
        fullname: fullname ?? this.fullname,
        email: email.present ? email.value : this.email,
        phone: phone.present ? phone.value : this.phone,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  UserEntity copyWithCompanion(UsersCompanion data) {
    return UserEntity(
      id: data.id.present ? data.id.value : this.id,
      nisn: data.nisn.present ? data.nisn.value : this.nisn,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      role: data.role.present ? data.role.value : this.role,
      fullname: data.fullname.present ? data.fullname.value : this.fullname,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntity(')
          ..write('id: $id, ')
          ..write('nisn: $nisn, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('role: $role, ')
          ..write('fullname: $fullname, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nisn, passwordHash, role, fullname, email,
      phone, avatarUrl, isActive, createdAt, updatedAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntity &&
          other.id == this.id &&
          other.nisn == this.nisn &&
          other.passwordHash == this.passwordHash &&
          other.role == this.role &&
          other.fullname == this.fullname &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.avatarUrl == this.avatarUrl &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class UsersCompanion extends UpdateCompanion<UserEntity> {
  final Value<String> id;
  final Value<String> nisn;
  final Value<String> passwordHash;
  final Value<String> role;
  final Value<String> fullname;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> avatarUrl;
  final Value<bool> isActive;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> syncedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.nisn = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.role = const Value.absent(),
    this.fullname = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String nisn,
    required String passwordHash,
    required String role,
    required String fullname,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.isActive = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nisn = Value(nisn),
        passwordHash = Value(passwordHash),
        role = Value(role),
        fullname = Value(fullname),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<UserEntity> custom({
    Expression<String>? id,
    Expression<String>? nisn,
    Expression<String>? passwordHash,
    Expression<String>? role,
    Expression<String>? fullname,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? avatarUrl,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nisn != null) 'nisn': nisn,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (role != null) 'role': role,
      if (fullname != null) 'fullname': fullname,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? nisn,
      Value<String>? passwordHash,
      Value<String>? role,
      Value<String>? fullname,
      Value<String?>? email,
      Value<String?>? phone,
      Value<String?>? avatarUrl,
      Value<bool>? isActive,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? syncedAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      nisn: nisn ?? this.nisn,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nisn.present) {
      map['nisn'] = Variable<String>(nisn.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (fullname.present) {
      map['fullname'] = Variable<String>(fullname.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('nisn: $nisn, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('role: $role, ')
          ..write('fullname: $fullname, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudentsTable extends Students
    with TableInfo<$StudentsTable, StudentEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _nisnMeta = const VerificationMeta('nisn');
  @override
  late final GeneratedColumn<String> nisn = GeneratedColumn<String>(
      'nisn', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _classNameMeta =
      const VerificationMeta('className');
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
      'class', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<String> dateOfBirth = GeneratedColumn<String>(
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      check: () => gender.isIn(const ['M', 'F']),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneParentMeta =
      const VerificationMeta('phoneParent');
  @override
  late final GeneratedColumn<String> phoneParent = GeneratedColumn<String>(
      'phone_parent', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nisn,
        className,
        parentId,
        dateOfBirth,
        gender,
        address,
        phoneParent,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(Insertable<StudentEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nisn')) {
      context.handle(
          _nisnMeta, nisn.isAcceptableOrUnknown(data['nisn']!, _nisnMeta));
    } else if (isInserting) {
      context.missing(_nisnMeta);
    }
    if (data.containsKey('class')) {
      context.handle(_classNameMeta,
          className.isAcceptableOrUnknown(data['class']!, _classNameMeta));
    } else if (isInserting) {
      context.missing(_classNameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('phone_parent')) {
      context.handle(
          _phoneParentMeta,
          phoneParent.isAcceptableOrUnknown(
              data['phone_parent']!, _phoneParentMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudentEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      nisn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nisn'])!,
      className: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}class'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_of_birth']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      phoneParent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_parent']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class StudentEntity extends DataClass implements Insertable<StudentEntity> {
  final String id;
  final String nisn;
  final String className;
  final String? parentId;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? phoneParent;
  final int createdAt;
  final int updatedAt;
  const StudentEntity(
      {required this.id,
      required this.nisn,
      required this.className,
      this.parentId,
      this.dateOfBirth,
      this.gender,
      this.address,
      this.phoneParent,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nisn'] = Variable<String>(nisn);
    map['class'] = Variable<String>(className);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<String>(dateOfBirth);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phoneParent != null) {
      map['phone_parent'] = Variable<String>(phoneParent);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      nisn: Value(nisn),
      className: Value(className),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phoneParent: phoneParent == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneParent),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StudentEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentEntity(
      id: serializer.fromJson<String>(json['id']),
      nisn: serializer.fromJson<String>(json['nisn']),
      className: serializer.fromJson<String>(json['className']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      dateOfBirth: serializer.fromJson<String?>(json['dateOfBirth']),
      gender: serializer.fromJson<String?>(json['gender']),
      address: serializer.fromJson<String?>(json['address']),
      phoneParent: serializer.fromJson<String?>(json['phoneParent']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nisn': serializer.toJson<String>(nisn),
      'className': serializer.toJson<String>(className),
      'parentId': serializer.toJson<String?>(parentId),
      'dateOfBirth': serializer.toJson<String?>(dateOfBirth),
      'gender': serializer.toJson<String?>(gender),
      'address': serializer.toJson<String?>(address),
      'phoneParent': serializer.toJson<String?>(phoneParent),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  StudentEntity copyWith(
          {String? id,
          String? nisn,
          String? className,
          Value<String?> parentId = const Value.absent(),
          Value<String?> dateOfBirth = const Value.absent(),
          Value<String?> gender = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<String?> phoneParent = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      StudentEntity(
        id: id ?? this.id,
        nisn: nisn ?? this.nisn,
        className: className ?? this.className,
        parentId: parentId.present ? parentId.value : this.parentId,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
        gender: gender.present ? gender.value : this.gender,
        address: address.present ? address.value : this.address,
        phoneParent: phoneParent.present ? phoneParent.value : this.phoneParent,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  StudentEntity copyWithCompanion(StudentsCompanion data) {
    return StudentEntity(
      id: data.id.present ? data.id.value : this.id,
      nisn: data.nisn.present ? data.nisn.value : this.nisn,
      className: data.className.present ? data.className.value : this.className,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      gender: data.gender.present ? data.gender.value : this.gender,
      address: data.address.present ? data.address.value : this.address,
      phoneParent:
          data.phoneParent.present ? data.phoneParent.value : this.phoneParent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentEntity(')
          ..write('id: $id, ')
          ..write('nisn: $nisn, ')
          ..write('className: $className, ')
          ..write('parentId: $parentId, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('address: $address, ')
          ..write('phoneParent: $phoneParent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nisn, className, parentId, dateOfBirth,
      gender, address, phoneParent, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentEntity &&
          other.id == this.id &&
          other.nisn == this.nisn &&
          other.className == this.className &&
          other.parentId == this.parentId &&
          other.dateOfBirth == this.dateOfBirth &&
          other.gender == this.gender &&
          other.address == this.address &&
          other.phoneParent == this.phoneParent &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StudentsCompanion extends UpdateCompanion<StudentEntity> {
  final Value<String> id;
  final Value<String> nisn;
  final Value<String> className;
  final Value<String?> parentId;
  final Value<String?> dateOfBirth;
  final Value<String?> gender;
  final Value<String?> address;
  final Value<String?> phoneParent;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.nisn = const Value.absent(),
    this.className = const Value.absent(),
    this.parentId = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.address = const Value.absent(),
    this.phoneParent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentsCompanion.insert({
    required String id,
    required String nisn,
    required String className,
    this.parentId = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.address = const Value.absent(),
    this.phoneParent = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nisn = Value(nisn),
        className = Value(className),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<StudentEntity> custom({
    Expression<String>? id,
    Expression<String>? nisn,
    Expression<String>? className,
    Expression<String>? parentId,
    Expression<String>? dateOfBirth,
    Expression<String>? gender,
    Expression<String>? address,
    Expression<String>? phoneParent,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nisn != null) 'nisn': nisn,
      if (className != null) 'class': className,
      if (parentId != null) 'parent_id': parentId,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (address != null) 'address': address,
      if (phoneParent != null) 'phone_parent': phoneParent,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? nisn,
      Value<String>? className,
      Value<String?>? parentId,
      Value<String?>? dateOfBirth,
      Value<String?>? gender,
      Value<String?>? address,
      Value<String?>? phoneParent,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return StudentsCompanion(
      id: id ?? this.id,
      nisn: nisn ?? this.nisn,
      className: className ?? this.className,
      parentId: parentId ?? this.parentId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      phoneParent: phoneParent ?? this.phoneParent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nisn.present) {
      map['nisn'] = Variable<String>(nisn.value);
    }
    if (className.present) {
      map['class'] = Variable<String>(className.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<String>(dateOfBirth.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phoneParent.present) {
      map['phone_parent'] = Variable<String>(phoneParent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('nisn: $nisn, ')
          ..write('className: $className, ')
          ..write('parentId: $parentId, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('address: $address, ')
          ..write('phoneParent: $phoneParent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'UNIQUE REFERENCES students (id)'));
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

class $AttendanceTable extends Attendance
    with TableInfo<$AttendanceTable, AttendanceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceTable(this.attachedDatabase, [this._alias]);
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
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES students (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeInMeta = const VerificationMeta('timeIn');
  @override
  late final GeneratedColumn<String> timeIn = GeneratedColumn<String>(
      'time_in', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timeOutMeta =
      const VerificationMeta('timeOut');
  @override
  late final GeneratedColumn<String> timeOut = GeneratedColumn<String>(
      'time_out', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      check: () =>
          status.isIn(const ['present', 'absent', 'late', 'leave', 'sick']),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _isWithinGeofenceMeta =
      const VerificationMeta('isWithinGeofence');
  @override
  late final GeneratedColumn<bool> isWithinGeofence = GeneratedColumn<bool>(
      'is_within_geofence', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_within_geofence" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _livenessVerifiedMeta =
      const VerificationMeta('livenessVerified');
  @override
  late final GeneratedColumn<bool> livenessVerified = GeneratedColumn<bool>(
      'liveness_verified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("liveness_verified" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _faceMatchScoreMeta =
      const VerificationMeta('faceMatchScore');
  @override
  late final GeneratedColumn<double> faceMatchScore = GeneratedColumn<double>(
      'face_match_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _locationLatMeta =
      const VerificationMeta('locationLat');
  @override
  late final GeneratedColumn<double> locationLat = GeneratedColumn<double>(
      'location_lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _locationLngMeta =
      const VerificationMeta('locationLng');
  @override
  late final GeneratedColumn<double> locationLng = GeneratedColumn<double>(
      'location_lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        studentId,
        date,
        timeIn,
        timeOut,
        status,
        isWithinGeofence,
        livenessVerified,
        faceMatchScore,
        locationLat,
        locationLng,
        deviceId,
        notes,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance';
  @override
  VerificationContext validateIntegrity(Insertable<AttendanceEntity> instance,
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
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time_in')) {
      context.handle(_timeInMeta,
          timeIn.isAcceptableOrUnknown(data['time_in']!, _timeInMeta));
    }
    if (data.containsKey('time_out')) {
      context.handle(_timeOutMeta,
          timeOut.isAcceptableOrUnknown(data['time_out']!, _timeOutMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('is_within_geofence')) {
      context.handle(
          _isWithinGeofenceMeta,
          isWithinGeofence.isAcceptableOrUnknown(
              data['is_within_geofence']!, _isWithinGeofenceMeta));
    }
    if (data.containsKey('liveness_verified')) {
      context.handle(
          _livenessVerifiedMeta,
          livenessVerified.isAcceptableOrUnknown(
              data['liveness_verified']!, _livenessVerifiedMeta));
    }
    if (data.containsKey('face_match_score')) {
      context.handle(
          _faceMatchScoreMeta,
          faceMatchScore.isAcceptableOrUnknown(
              data['face_match_score']!, _faceMatchScoreMeta));
    }
    if (data.containsKey('location_lat')) {
      context.handle(
          _locationLatMeta,
          locationLat.isAcceptableOrUnknown(
              data['location_lat']!, _locationLatMeta));
    }
    if (data.containsKey('location_lng')) {
      context.handle(
          _locationLngMeta,
          locationLng.isAcceptableOrUnknown(
              data['location_lng']!, _locationLngMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {studentId, date},
      ];
  @override
  AttendanceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}student_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      timeIn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_in']),
      timeOut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_out']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      isWithinGeofence: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_within_geofence'])!,
      livenessVerified: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}liveness_verified'])!,
      faceMatchScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}face_match_score']),
      locationLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}location_lat']),
      locationLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}location_lng']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AttendanceTable createAlias(String alias) {
    return $AttendanceTable(attachedDatabase, alias);
  }
}

class AttendanceEntity extends DataClass
    implements Insertable<AttendanceEntity> {
  final String id;
  final String studentId;
  final String date;
  final String? timeIn;
  final String? timeOut;
  final String status;
  final bool isWithinGeofence;
  final bool livenessVerified;
  final double? faceMatchScore;
  final double? locationLat;
  final double? locationLng;
  final String? deviceId;
  final String? notes;
  final int? syncedAt;
  final int createdAt;
  final int updatedAt;
  const AttendanceEntity(
      {required this.id,
      required this.studentId,
      required this.date,
      this.timeIn,
      this.timeOut,
      required this.status,
      required this.isWithinGeofence,
      required this.livenessVerified,
      this.faceMatchScore,
      this.locationLat,
      this.locationLng,
      this.deviceId,
      this.notes,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || timeIn != null) {
      map['time_in'] = Variable<String>(timeIn);
    }
    if (!nullToAbsent || timeOut != null) {
      map['time_out'] = Variable<String>(timeOut);
    }
    map['status'] = Variable<String>(status);
    map['is_within_geofence'] = Variable<bool>(isWithinGeofence);
    map['liveness_verified'] = Variable<bool>(livenessVerified);
    if (!nullToAbsent || faceMatchScore != null) {
      map['face_match_score'] = Variable<double>(faceMatchScore);
    }
    if (!nullToAbsent || locationLat != null) {
      map['location_lat'] = Variable<double>(locationLat);
    }
    if (!nullToAbsent || locationLng != null) {
      map['location_lng'] = Variable<double>(locationLng);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AttendanceCompanion toCompanion(bool nullToAbsent) {
    return AttendanceCompanion(
      id: Value(id),
      studentId: Value(studentId),
      date: Value(date),
      timeIn:
          timeIn == null && nullToAbsent ? const Value.absent() : Value(timeIn),
      timeOut: timeOut == null && nullToAbsent
          ? const Value.absent()
          : Value(timeOut),
      status: Value(status),
      isWithinGeofence: Value(isWithinGeofence),
      livenessVerified: Value(livenessVerified),
      faceMatchScore: faceMatchScore == null && nullToAbsent
          ? const Value.absent()
          : Value(faceMatchScore),
      locationLat: locationLat == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLat),
      locationLng: locationLng == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLng),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AttendanceEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceEntity(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      date: serializer.fromJson<String>(json['date']),
      timeIn: serializer.fromJson<String?>(json['timeIn']),
      timeOut: serializer.fromJson<String?>(json['timeOut']),
      status: serializer.fromJson<String>(json['status']),
      isWithinGeofence: serializer.fromJson<bool>(json['isWithinGeofence']),
      livenessVerified: serializer.fromJson<bool>(json['livenessVerified']),
      faceMatchScore: serializer.fromJson<double?>(json['faceMatchScore']),
      locationLat: serializer.fromJson<double?>(json['locationLat']),
      locationLng: serializer.fromJson<double?>(json['locationLng']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'date': serializer.toJson<String>(date),
      'timeIn': serializer.toJson<String?>(timeIn),
      'timeOut': serializer.toJson<String?>(timeOut),
      'status': serializer.toJson<String>(status),
      'isWithinGeofence': serializer.toJson<bool>(isWithinGeofence),
      'livenessVerified': serializer.toJson<bool>(livenessVerified),
      'faceMatchScore': serializer.toJson<double?>(faceMatchScore),
      'locationLat': serializer.toJson<double?>(locationLat),
      'locationLng': serializer.toJson<double?>(locationLng),
      'deviceId': serializer.toJson<String?>(deviceId),
      'notes': serializer.toJson<String?>(notes),
      'syncedAt': serializer.toJson<int?>(syncedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AttendanceEntity copyWith(
          {String? id,
          String? studentId,
          String? date,
          Value<String?> timeIn = const Value.absent(),
          Value<String?> timeOut = const Value.absent(),
          String? status,
          bool? isWithinGeofence,
          bool? livenessVerified,
          Value<double?> faceMatchScore = const Value.absent(),
          Value<double?> locationLat = const Value.absent(),
          Value<double?> locationLng = const Value.absent(),
          Value<String?> deviceId = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<int?> syncedAt = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      AttendanceEntity(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        date: date ?? this.date,
        timeIn: timeIn.present ? timeIn.value : this.timeIn,
        timeOut: timeOut.present ? timeOut.value : this.timeOut,
        status: status ?? this.status,
        isWithinGeofence: isWithinGeofence ?? this.isWithinGeofence,
        livenessVerified: livenessVerified ?? this.livenessVerified,
        faceMatchScore:
            faceMatchScore.present ? faceMatchScore.value : this.faceMatchScore,
        locationLat: locationLat.present ? locationLat.value : this.locationLat,
        locationLng: locationLng.present ? locationLng.value : this.locationLng,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        notes: notes.present ? notes.value : this.notes,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AttendanceEntity copyWithCompanion(AttendanceCompanion data) {
    return AttendanceEntity(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      date: data.date.present ? data.date.value : this.date,
      timeIn: data.timeIn.present ? data.timeIn.value : this.timeIn,
      timeOut: data.timeOut.present ? data.timeOut.value : this.timeOut,
      status: data.status.present ? data.status.value : this.status,
      isWithinGeofence: data.isWithinGeofence.present
          ? data.isWithinGeofence.value
          : this.isWithinGeofence,
      livenessVerified: data.livenessVerified.present
          ? data.livenessVerified.value
          : this.livenessVerified,
      faceMatchScore: data.faceMatchScore.present
          ? data.faceMatchScore.value
          : this.faceMatchScore,
      locationLat:
          data.locationLat.present ? data.locationLat.value : this.locationLat,
      locationLng:
          data.locationLng.present ? data.locationLng.value : this.locationLng,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceEntity(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('timeIn: $timeIn, ')
          ..write('timeOut: $timeOut, ')
          ..write('status: $status, ')
          ..write('isWithinGeofence: $isWithinGeofence, ')
          ..write('livenessVerified: $livenessVerified, ')
          ..write('faceMatchScore: $faceMatchScore, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('deviceId: $deviceId, ')
          ..write('notes: $notes, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      studentId,
      date,
      timeIn,
      timeOut,
      status,
      isWithinGeofence,
      livenessVerified,
      faceMatchScore,
      locationLat,
      locationLng,
      deviceId,
      notes,
      syncedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceEntity &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.date == this.date &&
          other.timeIn == this.timeIn &&
          other.timeOut == this.timeOut &&
          other.status == this.status &&
          other.isWithinGeofence == this.isWithinGeofence &&
          other.livenessVerified == this.livenessVerified &&
          other.faceMatchScore == this.faceMatchScore &&
          other.locationLat == this.locationLat &&
          other.locationLng == this.locationLng &&
          other.deviceId == this.deviceId &&
          other.notes == this.notes &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AttendanceCompanion extends UpdateCompanion<AttendanceEntity> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> date;
  final Value<String?> timeIn;
  final Value<String?> timeOut;
  final Value<String> status;
  final Value<bool> isWithinGeofence;
  final Value<bool> livenessVerified;
  final Value<double?> faceMatchScore;
  final Value<double?> locationLat;
  final Value<double?> locationLng;
  final Value<String?> deviceId;
  final Value<String?> notes;
  final Value<int?> syncedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AttendanceCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.date = const Value.absent(),
    this.timeIn = const Value.absent(),
    this.timeOut = const Value.absent(),
    this.status = const Value.absent(),
    this.isWithinGeofence = const Value.absent(),
    this.livenessVerified = const Value.absent(),
    this.faceMatchScore = const Value.absent(),
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceCompanion.insert({
    required String id,
    required String studentId,
    required String date,
    this.timeIn = const Value.absent(),
    this.timeOut = const Value.absent(),
    required String status,
    this.isWithinGeofence = const Value.absent(),
    this.livenessVerified = const Value.absent(),
    this.faceMatchScore = const Value.absent(),
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        studentId = Value(studentId),
        date = Value(date),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AttendanceEntity> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? date,
    Expression<String>? timeIn,
    Expression<String>? timeOut,
    Expression<String>? status,
    Expression<bool>? isWithinGeofence,
    Expression<bool>? livenessVerified,
    Expression<double>? faceMatchScore,
    Expression<double>? locationLat,
    Expression<double>? locationLng,
    Expression<String>? deviceId,
    Expression<String>? notes,
    Expression<int>? syncedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (date != null) 'date': date,
      if (timeIn != null) 'time_in': timeIn,
      if (timeOut != null) 'time_out': timeOut,
      if (status != null) 'status': status,
      if (isWithinGeofence != null) 'is_within_geofence': isWithinGeofence,
      if (livenessVerified != null) 'liveness_verified': livenessVerified,
      if (faceMatchScore != null) 'face_match_score': faceMatchScore,
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
      if (deviceId != null) 'device_id': deviceId,
      if (notes != null) 'notes': notes,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceCompanion copyWith(
      {Value<String>? id,
      Value<String>? studentId,
      Value<String>? date,
      Value<String?>? timeIn,
      Value<String?>? timeOut,
      Value<String>? status,
      Value<bool>? isWithinGeofence,
      Value<bool>? livenessVerified,
      Value<double?>? faceMatchScore,
      Value<double?>? locationLat,
      Value<double?>? locationLng,
      Value<String?>? deviceId,
      Value<String?>? notes,
      Value<int?>? syncedAt,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return AttendanceCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      status: status ?? this.status,
      isWithinGeofence: isWithinGeofence ?? this.isWithinGeofence,
      livenessVerified: livenessVerified ?? this.livenessVerified,
      faceMatchScore: faceMatchScore ?? this.faceMatchScore,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      deviceId: deviceId ?? this.deviceId,
      notes: notes ?? this.notes,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (timeIn.present) {
      map['time_in'] = Variable<String>(timeIn.value);
    }
    if (timeOut.present) {
      map['time_out'] = Variable<String>(timeOut.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isWithinGeofence.present) {
      map['is_within_geofence'] = Variable<bool>(isWithinGeofence.value);
    }
    if (livenessVerified.present) {
      map['liveness_verified'] = Variable<bool>(livenessVerified.value);
    }
    if (faceMatchScore.present) {
      map['face_match_score'] = Variable<double>(faceMatchScore.value);
    }
    if (locationLat.present) {
      map['location_lat'] = Variable<double>(locationLat.value);
    }
    if (locationLng.present) {
      map['location_lng'] = Variable<double>(locationLng.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('timeIn: $timeIn, ')
          ..write('timeOut: $timeOut, ')
          ..write('status: $status, ')
          ..write('isWithinGeofence: $isWithinGeofence, ')
          ..write('livenessVerified: $livenessVerified, ')
          ..write('faceMatchScore: $faceMatchScore, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('deviceId: $deviceId, ')
          ..write('notes: $notes, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceQueueTable extends AttendanceQueue
    with TableInfo<$AttendanceQueueTable, AttendanceQueueEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attendanceIdMeta =
      const VerificationMeta('attendanceId');
  @override
  late final GeneratedColumn<String> attendanceId = GeneratedColumn<String>(
      'attendance_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES attendance (id)'));
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
      'student_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES students (id)'));
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      check: () => action.isIn(const ['create', 'update', 'delete']),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      check: () => status.isIn(const ['pending', 'synced', 'failed']),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        attendanceId,
        studentId,
        action,
        payload,
        status,
        retryCount,
        errorMessage,
        createdAt,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_queue';
  @override
  VerificationContext validateIntegrity(
      Insertable<AttendanceQueueEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('attendance_id')) {
      context.handle(
          _attendanceIdMeta,
          attendanceId.isAcceptableOrUnknown(
              data['attendance_id']!, _attendanceIdMeta));
    } else if (isInserting) {
      context.missing(_attendanceIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceQueueEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceQueueEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      attendanceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attendance_id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}student_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $AttendanceQueueTable createAlias(String alias) {
    return $AttendanceQueueTable(attachedDatabase, alias);
  }
}

class AttendanceQueueEntity extends DataClass
    implements Insertable<AttendanceQueueEntity> {
  final String id;
  final String attendanceId;
  final String studentId;
  final String action;
  final String payload;
  final String status;
  final int retryCount;
  final String? errorMessage;
  final int createdAt;
  final int? syncedAt;
  const AttendanceQueueEntity(
      {required this.id,
      required this.attendanceId,
      required this.studentId,
      required this.action,
      required this.payload,
      required this.status,
      required this.retryCount,
      this.errorMessage,
      required this.createdAt,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['attendance_id'] = Variable<String>(attendanceId);
    map['student_id'] = Variable<String>(studentId);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    return map;
  }

  AttendanceQueueCompanion toCompanion(bool nullToAbsent) {
    return AttendanceQueueCompanion(
      id: Value(id),
      attendanceId: Value(attendanceId),
      studentId: Value(studentId),
      action: Value(action),
      payload: Value(payload),
      status: Value(status),
      retryCount: Value(retryCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory AttendanceQueueEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceQueueEntity(
      id: serializer.fromJson<String>(json['id']),
      attendanceId: serializer.fromJson<String>(json['attendanceId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'attendanceId': serializer.toJson<String>(attendanceId),
      'studentId': serializer.toJson<String>(studentId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<int>(createdAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
    };
  }

  AttendanceQueueEntity copyWith(
          {String? id,
          String? attendanceId,
          String? studentId,
          String? action,
          String? payload,
          String? status,
          int? retryCount,
          Value<String?> errorMessage = const Value.absent(),
          int? createdAt,
          Value<int?> syncedAt = const Value.absent()}) =>
      AttendanceQueueEntity(
        id: id ?? this.id,
        attendanceId: attendanceId ?? this.attendanceId,
        studentId: studentId ?? this.studentId,
        action: action ?? this.action,
        payload: payload ?? this.payload,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        createdAt: createdAt ?? this.createdAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  AttendanceQueueEntity copyWithCompanion(AttendanceQueueCompanion data) {
    return AttendanceQueueEntity(
      id: data.id.present ? data.id.value : this.id,
      attendanceId: data.attendanceId.present
          ? data.attendanceId.value
          : this.attendanceId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceQueueEntity(')
          ..write('id: $id, ')
          ..write('attendanceId: $attendanceId, ')
          ..write('studentId: $studentId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, attendanceId, studentId, action, payload,
      status, retryCount, errorMessage, createdAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceQueueEntity &&
          other.id == this.id &&
          other.attendanceId == this.attendanceId &&
          other.studentId == this.studentId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class AttendanceQueueCompanion extends UpdateCompanion<AttendanceQueueEntity> {
  final Value<String> id;
  final Value<String> attendanceId;
  final Value<String> studentId;
  final Value<String> action;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> errorMessage;
  final Value<int> createdAt;
  final Value<int?> syncedAt;
  final Value<int> rowid;
  const AttendanceQueueCompanion({
    this.id = const Value.absent(),
    this.attendanceId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceQueueCompanion.insert({
    required String id,
    required String attendanceId,
    required String studentId,
    required String action,
    required String payload,
    required String status,
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required int createdAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        attendanceId = Value(attendanceId),
        studentId = Value(studentId),
        action = Value(action),
        payload = Value(payload),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<AttendanceQueueEntity> custom({
    Expression<String>? id,
    Expression<String>? attendanceId,
    Expression<String>? studentId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? errorMessage,
    Expression<int>? createdAt,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attendanceId != null) 'attendance_id': attendanceId,
      if (studentId != null) 'student_id': studentId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceQueueCompanion copyWith(
      {Value<String>? id,
      Value<String>? attendanceId,
      Value<String>? studentId,
      Value<String>? action,
      Value<String>? payload,
      Value<String>? status,
      Value<int>? retryCount,
      Value<String?>? errorMessage,
      Value<int>? createdAt,
      Value<int?>? syncedAt,
      Value<int>? rowid}) {
    return AttendanceQueueCompanion(
      id: id ?? this.id,
      attendanceId: attendanceId ?? this.attendanceId,
      studentId: studentId ?? this.studentId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (attendanceId.present) {
      map['attendance_id'] = Variable<String>(attendanceId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceQueueCompanion(')
          ..write('id: $id, ')
          ..write('attendanceId: $attendanceId, ')
          ..write('studentId: $studentId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GradesTable extends Grades with TableInfo<$GradesTable, GradeEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GradesTable(this.attachedDatabase, [this._alias]);
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
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES students (id)'));
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      check: () => type.isIn(const ['UTS', 'UAS', 'tugas']),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      check: () => ComparableExpr(score).isBetweenValues(0, 100),
      type: DriftSqlType.double,
      requiredDuringInsert: true);
  static const VerificationMeta _semesterMeta =
      const VerificationMeta('semester');
  @override
  late final GeneratedColumn<int> semester = GeneratedColumn<int>(
      'semester', aliasedName, true,
      check: () => semester.isIn(const [1, 2]),
      type: DriftSqlType.int,
      requiredDuringInsert: false);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _inputtedByMeta =
      const VerificationMeta('inputtedBy');
  @override
  late final GeneratedColumn<String> inputtedBy = GeneratedColumn<String>(
      'inputted_by', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        studentId,
        subject,
        type,
        score,
        semester,
        year,
        inputtedBy,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grades';
  @override
  VerificationContext validateIntegrity(Insertable<GradeEntity> instance,
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
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('semester')) {
      context.handle(_semesterMeta,
          semester.isAcceptableOrUnknown(data['semester']!, _semesterMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('inputted_by')) {
      context.handle(
          _inputtedByMeta,
          inputtedBy.isAcceptableOrUnknown(
              data['inputted_by']!, _inputtedByMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GradeEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GradeEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}student_id'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
      semester: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}semester']),
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year']),
      inputtedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}inputted_by']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GradesTable createAlias(String alias) {
    return $GradesTable(attachedDatabase, alias);
  }
}

class GradeEntity extends DataClass implements Insertable<GradeEntity> {
  final String id;
  final String studentId;
  final String subject;
  final String type;
  final double score;
  final int? semester;
  final int? year;
  final String? inputtedBy;
  final int? syncedAt;
  final int createdAt;
  final int updatedAt;
  const GradeEntity(
      {required this.id,
      required this.studentId,
      required this.subject,
      required this.type,
      required this.score,
      this.semester,
      this.year,
      this.inputtedBy,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['subject'] = Variable<String>(subject);
    map['type'] = Variable<String>(type);
    map['score'] = Variable<double>(score);
    if (!nullToAbsent || semester != null) {
      map['semester'] = Variable<int>(semester);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || inputtedBy != null) {
      map['inputted_by'] = Variable<String>(inputtedBy);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  GradesCompanion toCompanion(bool nullToAbsent) {
    return GradesCompanion(
      id: Value(id),
      studentId: Value(studentId),
      subject: Value(subject),
      type: Value(type),
      score: Value(score),
      semester: semester == null && nullToAbsent
          ? const Value.absent()
          : Value(semester),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      inputtedBy: inputtedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(inputtedBy),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GradeEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GradeEntity(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      subject: serializer.fromJson<String>(json['subject']),
      type: serializer.fromJson<String>(json['type']),
      score: serializer.fromJson<double>(json['score']),
      semester: serializer.fromJson<int?>(json['semester']),
      year: serializer.fromJson<int?>(json['year']),
      inputtedBy: serializer.fromJson<String?>(json['inputtedBy']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'subject': serializer.toJson<String>(subject),
      'type': serializer.toJson<String>(type),
      'score': serializer.toJson<double>(score),
      'semester': serializer.toJson<int?>(semester),
      'year': serializer.toJson<int?>(year),
      'inputtedBy': serializer.toJson<String?>(inputtedBy),
      'syncedAt': serializer.toJson<int?>(syncedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  GradeEntity copyWith(
          {String? id,
          String? studentId,
          String? subject,
          String? type,
          double? score,
          Value<int?> semester = const Value.absent(),
          Value<int?> year = const Value.absent(),
          Value<String?> inputtedBy = const Value.absent(),
          Value<int?> syncedAt = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      GradeEntity(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        subject: subject ?? this.subject,
        type: type ?? this.type,
        score: score ?? this.score,
        semester: semester.present ? semester.value : this.semester,
        year: year.present ? year.value : this.year,
        inputtedBy: inputtedBy.present ? inputtedBy.value : this.inputtedBy,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GradeEntity copyWithCompanion(GradesCompanion data) {
    return GradeEntity(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      subject: data.subject.present ? data.subject.value : this.subject,
      type: data.type.present ? data.type.value : this.type,
      score: data.score.present ? data.score.value : this.score,
      semester: data.semester.present ? data.semester.value : this.semester,
      year: data.year.present ? data.year.value : this.year,
      inputtedBy:
          data.inputtedBy.present ? data.inputtedBy.value : this.inputtedBy,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GradeEntity(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('subject: $subject, ')
          ..write('type: $type, ')
          ..write('score: $score, ')
          ..write('semester: $semester, ')
          ..write('year: $year, ')
          ..write('inputtedBy: $inputtedBy, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, subject, type, score, semester,
      year, inputtedBy, syncedAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GradeEntity &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.subject == this.subject &&
          other.type == this.type &&
          other.score == this.score &&
          other.semester == this.semester &&
          other.year == this.year &&
          other.inputtedBy == this.inputtedBy &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GradesCompanion extends UpdateCompanion<GradeEntity> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> subject;
  final Value<String> type;
  final Value<double> score;
  final Value<int?> semester;
  final Value<int?> year;
  final Value<String?> inputtedBy;
  final Value<int?> syncedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const GradesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.subject = const Value.absent(),
    this.type = const Value.absent(),
    this.score = const Value.absent(),
    this.semester = const Value.absent(),
    this.year = const Value.absent(),
    this.inputtedBy = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GradesCompanion.insert({
    required String id,
    required String studentId,
    required String subject,
    required String type,
    required double score,
    this.semester = const Value.absent(),
    this.year = const Value.absent(),
    this.inputtedBy = const Value.absent(),
    this.syncedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        studentId = Value(studentId),
        subject = Value(subject),
        type = Value(type),
        score = Value(score),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<GradeEntity> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? subject,
    Expression<String>? type,
    Expression<double>? score,
    Expression<int>? semester,
    Expression<int>? year,
    Expression<String>? inputtedBy,
    Expression<int>? syncedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (subject != null) 'subject': subject,
      if (type != null) 'type': type,
      if (score != null) 'score': score,
      if (semester != null) 'semester': semester,
      if (year != null) 'year': year,
      if (inputtedBy != null) 'inputted_by': inputtedBy,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GradesCompanion copyWith(
      {Value<String>? id,
      Value<String>? studentId,
      Value<String>? subject,
      Value<String>? type,
      Value<double>? score,
      Value<int?>? semester,
      Value<int?>? year,
      Value<String?>? inputtedBy,
      Value<int?>? syncedAt,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return GradesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subject: subject ?? this.subject,
      type: type ?? this.type,
      score: score ?? this.score,
      semester: semester ?? this.semester,
      year: year ?? this.year,
      inputtedBy: inputtedBy ?? this.inputtedBy,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (semester.present) {
      map['semester'] = Variable<int>(semester.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (inputtedBy.present) {
      map['inputted_by'] = Variable<String>(inputtedBy.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GradesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('subject: $subject, ')
          ..write('type: $type, ')
          ..write('score: $score, ')
          ..write('semester: $semester, ')
          ..write('year: $year, ')
          ..write('inputtedBy: $inputtedBy, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeaveRequestsTable extends LeaveRequests
    with TableInfo<$LeaveRequestsTable, LeaveRequestEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeaveRequestsTable(this.attachedDatabase, [this._alias]);
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
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES students (id)'));
  static const VerificationMeta _attendanceIdMeta =
      const VerificationMeta('attendanceId');
  @override
  late final GeneratedColumn<String> attendanceId = GeneratedColumn<String>(
      'attendance_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES attendance (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      check: () => type.isIn(const ['izin', 'sakit']),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _attachmentUrlMeta =
      const VerificationMeta('attachmentUrl');
  @override
  late final GeneratedColumn<String> attachmentUrl = GeneratedColumn<String>(
      'attachment_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _attachmentLocalPathMeta =
      const VerificationMeta('attachmentLocalPath');
  @override
  late final GeneratedColumn<String> attachmentLocalPath =
      GeneratedColumn<String>('attachment_local_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      check: () => status.isIn(const ['pending', 'approved', 'rejected']),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _rejectedReasonMeta =
      const VerificationMeta('rejectedReason');
  @override
  late final GeneratedColumn<String> rejectedReason = GeneratedColumn<String>(
      'rejected_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reviewedByMeta =
      const VerificationMeta('reviewedBy');
  @override
  late final GeneratedColumn<String> reviewedBy = GeneratedColumn<String>(
      'reviewed_by', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _reviewedAtMeta =
      const VerificationMeta('reviewedAt');
  @override
  late final GeneratedColumn<int> reviewedAt = GeneratedColumn<int>(
      'reviewed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dateFromMeta =
      const VerificationMeta('dateFrom');
  @override
  late final GeneratedColumn<String> dateFrom = GeneratedColumn<String>(
      'date_from', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateToMeta = const VerificationMeta('dateTo');
  @override
  late final GeneratedColumn<String> dateTo = GeneratedColumn<String>(
      'date_to', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        studentId,
        attendanceId,
        type,
        reason,
        attachmentUrl,
        attachmentLocalPath,
        status,
        rejectedReason,
        reviewedBy,
        reviewedAt,
        dateFrom,
        dateTo,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leave_requests';
  @override
  VerificationContext validateIntegrity(Insertable<LeaveRequestEntity> instance,
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
    if (data.containsKey('attendance_id')) {
      context.handle(
          _attendanceIdMeta,
          attendanceId.isAcceptableOrUnknown(
              data['attendance_id']!, _attendanceIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('attachment_url')) {
      context.handle(
          _attachmentUrlMeta,
          attachmentUrl.isAcceptableOrUnknown(
              data['attachment_url']!, _attachmentUrlMeta));
    }
    if (data.containsKey('attachment_local_path')) {
      context.handle(
          _attachmentLocalPathMeta,
          attachmentLocalPath.isAcceptableOrUnknown(
              data['attachment_local_path']!, _attachmentLocalPathMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('rejected_reason')) {
      context.handle(
          _rejectedReasonMeta,
          rejectedReason.isAcceptableOrUnknown(
              data['rejected_reason']!, _rejectedReasonMeta));
    }
    if (data.containsKey('reviewed_by')) {
      context.handle(
          _reviewedByMeta,
          reviewedBy.isAcceptableOrUnknown(
              data['reviewed_by']!, _reviewedByMeta));
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
          _reviewedAtMeta,
          reviewedAt.isAcceptableOrUnknown(
              data['reviewed_at']!, _reviewedAtMeta));
    }
    if (data.containsKey('date_from')) {
      context.handle(_dateFromMeta,
          dateFrom.isAcceptableOrUnknown(data['date_from']!, _dateFromMeta));
    }
    if (data.containsKey('date_to')) {
      context.handle(_dateToMeta,
          dateTo.isAcceptableOrUnknown(data['date_to']!, _dateToMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LeaveRequestEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeaveRequestEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}student_id'])!,
      attendanceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attendance_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      attachmentUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attachment_url']),
      attachmentLocalPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}attachment_local_path']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      rejectedReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rejected_reason']),
      reviewedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reviewed_by']),
      reviewedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reviewed_at']),
      dateFrom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_from']),
      dateTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_to']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LeaveRequestsTable createAlias(String alias) {
    return $LeaveRequestsTable(attachedDatabase, alias);
  }
}

class LeaveRequestEntity extends DataClass
    implements Insertable<LeaveRequestEntity> {
  final String id;
  final String studentId;
  final String? attendanceId;
  final String type;
  final String? reason;
  final String? attachmentUrl;
  final String? attachmentLocalPath;
  final String status;
  final String? rejectedReason;
  final String? reviewedBy;
  final int? reviewedAt;
  final String? dateFrom;
  final String? dateTo;
  final int? syncedAt;
  final int createdAt;
  final int updatedAt;
  const LeaveRequestEntity(
      {required this.id,
      required this.studentId,
      this.attendanceId,
      required this.type,
      this.reason,
      this.attachmentUrl,
      this.attachmentLocalPath,
      required this.status,
      this.rejectedReason,
      this.reviewedBy,
      this.reviewedAt,
      this.dateFrom,
      this.dateTo,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    if (!nullToAbsent || attendanceId != null) {
      map['attendance_id'] = Variable<String>(attendanceId);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || attachmentUrl != null) {
      map['attachment_url'] = Variable<String>(attachmentUrl);
    }
    if (!nullToAbsent || attachmentLocalPath != null) {
      map['attachment_local_path'] = Variable<String>(attachmentLocalPath);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || rejectedReason != null) {
      map['rejected_reason'] = Variable<String>(rejectedReason);
    }
    if (!nullToAbsent || reviewedBy != null) {
      map['reviewed_by'] = Variable<String>(reviewedBy);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<int>(reviewedAt);
    }
    if (!nullToAbsent || dateFrom != null) {
      map['date_from'] = Variable<String>(dateFrom);
    }
    if (!nullToAbsent || dateTo != null) {
      map['date_to'] = Variable<String>(dateTo);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  LeaveRequestsCompanion toCompanion(bool nullToAbsent) {
    return LeaveRequestsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      attendanceId: attendanceId == null && nullToAbsent
          ? const Value.absent()
          : Value(attendanceId),
      type: Value(type),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      attachmentUrl: attachmentUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentUrl),
      attachmentLocalPath: attachmentLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentLocalPath),
      status: Value(status),
      rejectedReason: rejectedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectedReason),
      reviewedBy: reviewedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedBy),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
      dateFrom: dateFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFrom),
      dateTo:
          dateTo == null && nullToAbsent ? const Value.absent() : Value(dateTo),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LeaveRequestEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeaveRequestEntity(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      attendanceId: serializer.fromJson<String?>(json['attendanceId']),
      type: serializer.fromJson<String>(json['type']),
      reason: serializer.fromJson<String?>(json['reason']),
      attachmentUrl: serializer.fromJson<String?>(json['attachmentUrl']),
      attachmentLocalPath:
          serializer.fromJson<String?>(json['attachmentLocalPath']),
      status: serializer.fromJson<String>(json['status']),
      rejectedReason: serializer.fromJson<String?>(json['rejectedReason']),
      reviewedBy: serializer.fromJson<String?>(json['reviewedBy']),
      reviewedAt: serializer.fromJson<int?>(json['reviewedAt']),
      dateFrom: serializer.fromJson<String?>(json['dateFrom']),
      dateTo: serializer.fromJson<String?>(json['dateTo']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'attendanceId': serializer.toJson<String?>(attendanceId),
      'type': serializer.toJson<String>(type),
      'reason': serializer.toJson<String?>(reason),
      'attachmentUrl': serializer.toJson<String?>(attachmentUrl),
      'attachmentLocalPath': serializer.toJson<String?>(attachmentLocalPath),
      'status': serializer.toJson<String>(status),
      'rejectedReason': serializer.toJson<String?>(rejectedReason),
      'reviewedBy': serializer.toJson<String?>(reviewedBy),
      'reviewedAt': serializer.toJson<int?>(reviewedAt),
      'dateFrom': serializer.toJson<String?>(dateFrom),
      'dateTo': serializer.toJson<String?>(dateTo),
      'syncedAt': serializer.toJson<int?>(syncedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  LeaveRequestEntity copyWith(
          {String? id,
          String? studentId,
          Value<String?> attendanceId = const Value.absent(),
          String? type,
          Value<String?> reason = const Value.absent(),
          Value<String?> attachmentUrl = const Value.absent(),
          Value<String?> attachmentLocalPath = const Value.absent(),
          String? status,
          Value<String?> rejectedReason = const Value.absent(),
          Value<String?> reviewedBy = const Value.absent(),
          Value<int?> reviewedAt = const Value.absent(),
          Value<String?> dateFrom = const Value.absent(),
          Value<String?> dateTo = const Value.absent(),
          Value<int?> syncedAt = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      LeaveRequestEntity(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        attendanceId:
            attendanceId.present ? attendanceId.value : this.attendanceId,
        type: type ?? this.type,
        reason: reason.present ? reason.value : this.reason,
        attachmentUrl:
            attachmentUrl.present ? attachmentUrl.value : this.attachmentUrl,
        attachmentLocalPath: attachmentLocalPath.present
            ? attachmentLocalPath.value
            : this.attachmentLocalPath,
        status: status ?? this.status,
        rejectedReason:
            rejectedReason.present ? rejectedReason.value : this.rejectedReason,
        reviewedBy: reviewedBy.present ? reviewedBy.value : this.reviewedBy,
        reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
        dateFrom: dateFrom.present ? dateFrom.value : this.dateFrom,
        dateTo: dateTo.present ? dateTo.value : this.dateTo,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LeaveRequestEntity copyWithCompanion(LeaveRequestsCompanion data) {
    return LeaveRequestEntity(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      attendanceId: data.attendanceId.present
          ? data.attendanceId.value
          : this.attendanceId,
      type: data.type.present ? data.type.value : this.type,
      reason: data.reason.present ? data.reason.value : this.reason,
      attachmentUrl: data.attachmentUrl.present
          ? data.attachmentUrl.value
          : this.attachmentUrl,
      attachmentLocalPath: data.attachmentLocalPath.present
          ? data.attachmentLocalPath.value
          : this.attachmentLocalPath,
      status: data.status.present ? data.status.value : this.status,
      rejectedReason: data.rejectedReason.present
          ? data.rejectedReason.value
          : this.rejectedReason,
      reviewedBy:
          data.reviewedBy.present ? data.reviewedBy.value : this.reviewedBy,
      reviewedAt:
          data.reviewedAt.present ? data.reviewedAt.value : this.reviewedAt,
      dateFrom: data.dateFrom.present ? data.dateFrom.value : this.dateFrom,
      dateTo: data.dateTo.present ? data.dateTo.value : this.dateTo,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeaveRequestEntity(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('attendanceId: $attendanceId, ')
          ..write('type: $type, ')
          ..write('reason: $reason, ')
          ..write('attachmentUrl: $attachmentUrl, ')
          ..write('attachmentLocalPath: $attachmentLocalPath, ')
          ..write('status: $status, ')
          ..write('rejectedReason: $rejectedReason, ')
          ..write('reviewedBy: $reviewedBy, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('dateFrom: $dateFrom, ')
          ..write('dateTo: $dateTo, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      studentId,
      attendanceId,
      type,
      reason,
      attachmentUrl,
      attachmentLocalPath,
      status,
      rejectedReason,
      reviewedBy,
      reviewedAt,
      dateFrom,
      dateTo,
      syncedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaveRequestEntity &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.attendanceId == this.attendanceId &&
          other.type == this.type &&
          other.reason == this.reason &&
          other.attachmentUrl == this.attachmentUrl &&
          other.attachmentLocalPath == this.attachmentLocalPath &&
          other.status == this.status &&
          other.rejectedReason == this.rejectedReason &&
          other.reviewedBy == this.reviewedBy &&
          other.reviewedAt == this.reviewedAt &&
          other.dateFrom == this.dateFrom &&
          other.dateTo == this.dateTo &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LeaveRequestsCompanion extends UpdateCompanion<LeaveRequestEntity> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String?> attendanceId;
  final Value<String> type;
  final Value<String?> reason;
  final Value<String?> attachmentUrl;
  final Value<String?> attachmentLocalPath;
  final Value<String> status;
  final Value<String?> rejectedReason;
  final Value<String?> reviewedBy;
  final Value<int?> reviewedAt;
  final Value<String?> dateFrom;
  final Value<String?> dateTo;
  final Value<int?> syncedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const LeaveRequestsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.attendanceId = const Value.absent(),
    this.type = const Value.absent(),
    this.reason = const Value.absent(),
    this.attachmentUrl = const Value.absent(),
    this.attachmentLocalPath = const Value.absent(),
    this.status = const Value.absent(),
    this.rejectedReason = const Value.absent(),
    this.reviewedBy = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.dateFrom = const Value.absent(),
    this.dateTo = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeaveRequestsCompanion.insert({
    required String id,
    required String studentId,
    this.attendanceId = const Value.absent(),
    required String type,
    this.reason = const Value.absent(),
    this.attachmentUrl = const Value.absent(),
    this.attachmentLocalPath = const Value.absent(),
    required String status,
    this.rejectedReason = const Value.absent(),
    this.reviewedBy = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.dateFrom = const Value.absent(),
    this.dateTo = const Value.absent(),
    this.syncedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        studentId = Value(studentId),
        type = Value(type),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LeaveRequestEntity> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? attendanceId,
    Expression<String>? type,
    Expression<String>? reason,
    Expression<String>? attachmentUrl,
    Expression<String>? attachmentLocalPath,
    Expression<String>? status,
    Expression<String>? rejectedReason,
    Expression<String>? reviewedBy,
    Expression<int>? reviewedAt,
    Expression<String>? dateFrom,
    Expression<String>? dateTo,
    Expression<int>? syncedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (attendanceId != null) 'attendance_id': attendanceId,
      if (type != null) 'type': type,
      if (reason != null) 'reason': reason,
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      if (attachmentLocalPath != null)
        'attachment_local_path': attachmentLocalPath,
      if (status != null) 'status': status,
      if (rejectedReason != null) 'rejected_reason': rejectedReason,
      if (reviewedBy != null) 'reviewed_by': reviewedBy,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeaveRequestsCompanion copyWith(
      {Value<String>? id,
      Value<String>? studentId,
      Value<String?>? attendanceId,
      Value<String>? type,
      Value<String?>? reason,
      Value<String?>? attachmentUrl,
      Value<String?>? attachmentLocalPath,
      Value<String>? status,
      Value<String?>? rejectedReason,
      Value<String?>? reviewedBy,
      Value<int?>? reviewedAt,
      Value<String?>? dateFrom,
      Value<String?>? dateTo,
      Value<int?>? syncedAt,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return LeaveRequestsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      attendanceId: attendanceId ?? this.attendanceId,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentLocalPath: attachmentLocalPath ?? this.attachmentLocalPath,
      status: status ?? this.status,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (attendanceId.present) {
      map['attendance_id'] = Variable<String>(attendanceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (attachmentUrl.present) {
      map['attachment_url'] = Variable<String>(attachmentUrl.value);
    }
    if (attachmentLocalPath.present) {
      map['attachment_local_path'] =
          Variable<String>(attachmentLocalPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rejectedReason.present) {
      map['rejected_reason'] = Variable<String>(rejectedReason.value);
    }
    if (reviewedBy.present) {
      map['reviewed_by'] = Variable<String>(reviewedBy.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<int>(reviewedAt.value);
    }
    if (dateFrom.present) {
      map['date_from'] = Variable<String>(dateFrom.value);
    }
    if (dateTo.present) {
      map['date_to'] = Variable<String>(dateTo.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeaveRequestsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('attendanceId: $attendanceId, ')
          ..write('type: $type, ')
          ..write('reason: $reason, ')
          ..write('attachmentUrl: $attachmentUrl, ')
          ..write('attachmentLocalPath: $attachmentLocalPath, ')
          ..write('status: $status, ')
          ..write('rejectedReason: $rejectedReason, ')
          ..write('reviewedBy: $reviewedBy, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('dateFrom: $dateFrom, ')
          ..write('dateTo: $dateTo, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogTable extends AuditLog
    with TableInfo<$AuditLogTable, AuditLogEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _adminIdMeta =
      const VerificationMeta('adminId');
  @override
  late final GeneratedColumn<String> adminId = GeneratedColumn<String>(
      'admin_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      check: () =>
          entityType.isIn(const ['leave', 'grade', 'student', 'attendance']),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _oldValueMeta =
      const VerificationMeta('oldValue');
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
      'old_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _newValueMeta =
      const VerificationMeta('newValue');
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
      'new_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ipAddressMeta =
      const VerificationMeta('ipAddress');
  @override
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
      'ip_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        adminId,
        action,
        entityType,
        entityId,
        oldValue,
        newValue,
        ipAddress,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(Insertable<AuditLogEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('admin_id')) {
      context.handle(_adminIdMeta,
          adminId.isAcceptableOrUnknown(data['admin_id']!, _adminIdMeta));
    } else if (isInserting) {
      context.missing(_adminIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('old_value')) {
      context.handle(_oldValueMeta,
          oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta));
    }
    if (data.containsKey('new_value')) {
      context.handle(_newValueMeta,
          newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta));
    }
    if (data.containsKey('ip_address')) {
      context.handle(_ipAddressMeta,
          ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      adminId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}admin_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      oldValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}old_value']),
      newValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}new_value']),
      ipAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ip_address']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AuditLogTable createAlias(String alias) {
    return $AuditLogTable(attachedDatabase, alias);
  }
}

class AuditLogEntity extends DataClass implements Insertable<AuditLogEntity> {
  final String id;
  final String adminId;
  final String action;
  final String entityType;
  final String entityId;
  final String? oldValue;
  final String? newValue;
  final String? ipAddress;
  final int createdAt;
  const AuditLogEntity(
      {required this.id,
      required this.adminId,
      required this.action,
      required this.entityType,
      required this.entityId,
      this.oldValue,
      this.newValue,
      this.ipAddress,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['admin_id'] = Variable<String>(adminId);
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    if (!nullToAbsent || ipAddress != null) {
      map['ip_address'] = Variable<String>(ipAddress);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      adminId: Value(adminId),
      action: Value(action),
      entityType: Value(entityType),
      entityId: Value(entityId),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      ipAddress: ipAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(ipAddress),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLogEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogEntity(
      id: serializer.fromJson<String>(json['id']),
      adminId: serializer.fromJson<String>(json['adminId']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      ipAddress: serializer.fromJson<String?>(json['ipAddress']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'adminId': serializer.toJson<String>(adminId),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'ipAddress': serializer.toJson<String?>(ipAddress),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AuditLogEntity copyWith(
          {String? id,
          String? adminId,
          String? action,
          String? entityType,
          String? entityId,
          Value<String?> oldValue = const Value.absent(),
          Value<String?> newValue = const Value.absent(),
          Value<String?> ipAddress = const Value.absent(),
          int? createdAt}) =>
      AuditLogEntity(
        id: id ?? this.id,
        adminId: adminId ?? this.adminId,
        action: action ?? this.action,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        oldValue: oldValue.present ? oldValue.value : this.oldValue,
        newValue: newValue.present ? newValue.value : this.newValue,
        ipAddress: ipAddress.present ? ipAddress.value : this.ipAddress,
        createdAt: createdAt ?? this.createdAt,
      );
  AuditLogEntity copyWithCompanion(AuditLogCompanion data) {
    return AuditLogEntity(
      id: data.id.present ? data.id.value : this.id,
      adminId: data.adminId.present ? data.adminId.value : this.adminId,
      action: data.action.present ? data.action.value : this.action,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogEntity(')
          ..write('id: $id, ')
          ..write('adminId: $adminId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, adminId, action, entityType, entityId,
      oldValue, newValue, ipAddress, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogEntity &&
          other.id == this.id &&
          other.adminId == this.adminId &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.ipAddress == this.ipAddress &&
          other.createdAt == this.createdAt);
}

class AuditLogCompanion extends UpdateCompanion<AuditLogEntity> {
  final Value<String> id;
  final Value<String> adminId;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<String?> ipAddress;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.adminId = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogCompanion.insert({
    required String id,
    required String adminId,
    required String action,
    required String entityType,
    required String entityId,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.ipAddress = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        adminId = Value(adminId),
        action = Value(action),
        entityType = Value(entityType),
        entityId = Value(entityId),
        createdAt = Value(createdAt);
  static Insertable<AuditLogEntity> custom({
    Expression<String>? id,
    Expression<String>? adminId,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<String>? ipAddress,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (adminId != null) 'admin_id': adminId,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogCompanion copyWith(
      {Value<String>? id,
      Value<String>? adminId,
      Value<String>? action,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String?>? oldValue,
      Value<String?>? newValue,
      Value<String?>? ipAddress,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return AuditLogCompanion(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      ipAddress: ipAddress ?? this.ipAddress,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (adminId.present) {
      map['admin_id'] = Variable<String>(adminId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogCompanion(')
          ..write('id: $id, ')
          ..write('adminId: $adminId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      check: () => type.isIn(const ['string', 'int', 'bool', 'double']),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value, type, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<SettingEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntity(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingEntity extends DataClass implements Insertable<SettingEntity> {
  final String key;
  final String value;
  final String type;
  final int updatedAt;
  const SettingEntity(
      {required this.key,
      required this.value,
      required this.type,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['type'] = Variable<String>(type);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      type: Value(type),
      updatedAt: Value(updatedAt),
    );
  }

  factory SettingEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntity(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      type: serializer.fromJson<String>(json['type']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'type': serializer.toJson<String>(type),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SettingEntity copyWith(
          {String? key, String? value, String? type, int? updatedAt}) =>
      SettingEntity(
        key: key ?? this.key,
        value: value ?? this.value,
        type: type ?? this.type,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SettingEntity copyWithCompanion(SettingsCompanion data) {
    return SettingEntity(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      type: data.type.present ? data.type.value : this.type,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntity(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('type: $type, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, type, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingEntity &&
          other.key == this.key &&
          other.value == this.value &&
          other.type == this.type &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<SettingEntity> {
  final Value<String> key;
  final Value<String> value;
  final Value<String> type;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.type = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    required String type,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value),
        type = Value(type),
        updatedAt = Value(updatedAt);
  static Insertable<SettingEntity> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? type,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (type != null) 'type': type,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<String>? type,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('type: $type, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $FaceEmbeddingsTable faceEmbeddings = $FaceEmbeddingsTable(this);
  late final $AttendanceTable attendance = $AttendanceTable(this);
  late final $AttendanceQueueTable attendanceQueue =
      $AttendanceQueueTable(this);
  late final $GradesTable grades = $GradesTable(this);
  late final $LeaveRequestsTable leaveRequests = $LeaveRequestsTable(this);
  late final $AuditLogTable auditLog = $AuditLogTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        students,
        faceEmbeddings,
        attendance,
        attendanceQueue,
        grades,
        leaveRequests,
        auditLog,
        settings
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String nisn,
  required String passwordHash,
  required String role,
  required String fullname,
  Value<String?> email,
  Value<String?> phone,
  Value<String?> avatarUrl,
  Value<bool> isActive,
  required int createdAt,
  required int updatedAt,
  Value<int?> syncedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> nisn,
  Value<String> passwordHash,
  Value<String> role,
  Value<String> fullname,
  Value<String?> email,
  Value<String?> phone,
  Value<String?> avatarUrl,
  Value<bool> isActive,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> syncedAt,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, UserEntity> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GradesTable, List<GradeEntity>> _gradesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.grades,
          aliasName: $_aliasNameGenerator(db.users.id, db.grades.inputtedBy));

  $$GradesTableProcessedTableManager get gradesRefs {
    final manager = $$GradesTableTableManager($_db, $_db.grades)
        .filter((f) => f.inputtedBy.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_gradesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LeaveRequestsTable, List<LeaveRequestEntity>>
      _leaveRequestsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.leaveRequests,
              aliasName: $_aliasNameGenerator(
                  db.users.id, db.leaveRequests.reviewedBy));

  $$LeaveRequestsTableProcessedTableManager get leaveRequestsRefs {
    final manager = $$LeaveRequestsTableTableManager($_db, $_db.leaveRequests)
        .filter((f) => f.reviewedBy.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_leaveRequestsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AuditLogTable, List<AuditLogEntity>>
      _auditLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.auditLog,
          aliasName: $_aliasNameGenerator(db.users.id, db.auditLog.adminId));

  $$AuditLogTableProcessedTableManager get auditLogRefs {
    final manager = $$AuditLogTableTableManager($_db, $_db.auditLog)
        .filter((f) => f.adminId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_auditLogRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nisn => $composableBuilder(
      column: $table.nisn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullname => $composableBuilder(
      column: $table.fullname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> gradesRefs(
      Expression<bool> Function($$GradesTableFilterComposer f) f) {
    final $$GradesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.grades,
        getReferencedColumn: (t) => t.inputtedBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GradesTableFilterComposer(
              $db: $db,
              $table: $db.grades,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> leaveRequestsRefs(
      Expression<bool> Function($$LeaveRequestsTableFilterComposer f) f) {
    final $$LeaveRequestsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.leaveRequests,
        getReferencedColumn: (t) => t.reviewedBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LeaveRequestsTableFilterComposer(
              $db: $db,
              $table: $db.leaveRequests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> auditLogRefs(
      Expression<bool> Function($$AuditLogTableFilterComposer f) f) {
    final $$AuditLogTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.auditLog,
        getReferencedColumn: (t) => t.adminId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AuditLogTableFilterComposer(
              $db: $db,
              $table: $db.auditLog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nisn => $composableBuilder(
      column: $table.nisn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullname => $composableBuilder(
      column: $table.fullname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nisn =>
      $composableBuilder(column: $table.nisn, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get fullname =>
      $composableBuilder(column: $table.fullname, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  Expression<T> gradesRefs<T extends Object>(
      Expression<T> Function($$GradesTableAnnotationComposer a) f) {
    final $$GradesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.grades,
        getReferencedColumn: (t) => t.inputtedBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GradesTableAnnotationComposer(
              $db: $db,
              $table: $db.grades,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> leaveRequestsRefs<T extends Object>(
      Expression<T> Function($$LeaveRequestsTableAnnotationComposer a) f) {
    final $$LeaveRequestsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.leaveRequests,
        getReferencedColumn: (t) => t.reviewedBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LeaveRequestsTableAnnotationComposer(
              $db: $db,
              $table: $db.leaveRequests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> auditLogRefs<T extends Object>(
      Expression<T> Function($$AuditLogTableAnnotationComposer a) f) {
    final $$AuditLogTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.auditLog,
        getReferencedColumn: (t) => t.adminId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AuditLogTableAnnotationComposer(
              $db: $db,
              $table: $db.auditLog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    UserEntity,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserEntity, $$UsersTableReferences),
    UserEntity,
    PrefetchHooks Function(
        {bool gradesRefs, bool leaveRequestsRefs, bool auditLogRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> nisn = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> fullname = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            nisn: nisn,
            passwordHash: passwordHash,
            role: role,
            fullname: fullname,
            email: email,
            phone: phone,
            avatarUrl: avatarUrl,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String nisn,
            required String passwordHash,
            required String role,
            required String fullname,
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            nisn: nisn,
            passwordHash: passwordHash,
            role: role,
            fullname: fullname,
            email: email,
            phone: phone,
            avatarUrl: avatarUrl,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {gradesRefs = false,
              leaveRequestsRefs = false,
              auditLogRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (gradesRefs) db.grades,
                if (leaveRequestsRefs) db.leaveRequests,
                if (auditLogRefs) db.auditLog
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gradesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._gradesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).gradesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.inputtedBy == item.id),
                        typedResults: items),
                  if (leaveRequestsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._leaveRequestsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .leaveRequestsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.reviewedBy == item.id),
                        typedResults: items),
                  if (auditLogRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._auditLogRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).auditLogRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.adminId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    UserEntity,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserEntity, $$UsersTableReferences),
    UserEntity,
    PrefetchHooks Function(
        {bool gradesRefs, bool leaveRequestsRefs, bool auditLogRefs})>;
typedef $$StudentsTableCreateCompanionBuilder = StudentsCompanion Function({
  required String id,
  required String nisn,
  required String className,
  Value<String?> parentId,
  Value<String?> dateOfBirth,
  Value<String?> gender,
  Value<String?> address,
  Value<String?> phoneParent,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$StudentsTableUpdateCompanionBuilder = StudentsCompanion Function({
  Value<String> id,
  Value<String> nisn,
  Value<String> className,
  Value<String?> parentId,
  Value<String?> dateOfBirth,
  Value<String?> gender,
  Value<String?> address,
  Value<String?> phoneParent,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$StudentsTableReferences
    extends BaseReferences<_$AppDatabase, $StudentsTable, StudentEntity> {
  $$StudentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _idTable(_$AppDatabase db) =>
      db.users.createAlias($_aliasNameGenerator(db.students.id, db.users.id));

  $$UsersTableProcessedTableManager? get id {
    if ($_item.id == null) return null;
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id($_item.id!));
    final item = $_typedResult.readTableOrNull(_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _parentIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.students.parentId, db.users.id));

  $$UsersTableProcessedTableManager? get parentId {
    if ($_item.parentId == null) return null;
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id($_item.parentId!));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get nisn => $composableBuilder(
      column: $table.nisn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneParent => $composableBuilder(
      column: $table.phoneParent, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get id {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get parentId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get nisn => $composableBuilder(
      column: $table.nisn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneParent => $composableBuilder(
      column: $table.phoneParent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get id {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get parentId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get nisn =>
      $composableBuilder(column: $table.nisn, builder: (column) => column);

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumn<String> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phoneParent => $composableBuilder(
      column: $table.phoneParent, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get id {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get parentId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudentsTable,
    StudentEntity,
    $$StudentsTableFilterComposer,
    $$StudentsTableOrderingComposer,
    $$StudentsTableAnnotationComposer,
    $$StudentsTableCreateCompanionBuilder,
    $$StudentsTableUpdateCompanionBuilder,
    (StudentEntity, $$StudentsTableReferences),
    StudentEntity,
    PrefetchHooks Function({bool id, bool parentId})> {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> nisn = const Value.absent(),
            Value<String> className = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String?> dateOfBirth = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> phoneParent = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudentsCompanion(
            id: id,
            nisn: nisn,
            className: className,
            parentId: parentId,
            dateOfBirth: dateOfBirth,
            gender: gender,
            address: address,
            phoneParent: phoneParent,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String nisn,
            required String className,
            Value<String?> parentId = const Value.absent(),
            Value<String?> dateOfBirth = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> phoneParent = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StudentsCompanion.insert(
            id: id,
            nisn: nisn,
            className: className,
            parentId: parentId,
            dateOfBirth: dateOfBirth,
            gender: gender,
            address: address,
            phoneParent: phoneParent,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$StudentsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({id = false, parentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (id) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.id,
                    referencedTable: $$StudentsTableReferences._idTable(db),
                    referencedColumn: $$StudentsTableReferences._idTable(db).id,
                  ) as T;
                }
                if (parentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentId,
                    referencedTable:
                        $$StudentsTableReferences._parentIdTable(db),
                    referencedColumn:
                        $$StudentsTableReferences._parentIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StudentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudentsTable,
    StudentEntity,
    $$StudentsTableFilterComposer,
    $$StudentsTableOrderingComposer,
    $$StudentsTableAnnotationComposer,
    $$StudentsTableCreateCompanionBuilder,
    $$StudentsTableUpdateCompanionBuilder,
    (StudentEntity, $$StudentsTableReferences),
    StudentEntity,
    PrefetchHooks Function({bool id, bool parentId})>;
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
typedef $$AttendanceTableCreateCompanionBuilder = AttendanceCompanion Function({
  required String id,
  required String studentId,
  required String date,
  Value<String?> timeIn,
  Value<String?> timeOut,
  required String status,
  Value<bool> isWithinGeofence,
  Value<bool> livenessVerified,
  Value<double?> faceMatchScore,
  Value<double?> locationLat,
  Value<double?> locationLng,
  Value<String?> deviceId,
  Value<String?> notes,
  Value<int?> syncedAt,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$AttendanceTableUpdateCompanionBuilder = AttendanceCompanion Function({
  Value<String> id,
  Value<String> studentId,
  Value<String> date,
  Value<String?> timeIn,
  Value<String?> timeOut,
  Value<String> status,
  Value<bool> isWithinGeofence,
  Value<bool> livenessVerified,
  Value<double?> faceMatchScore,
  Value<double?> locationLat,
  Value<double?> locationLng,
  Value<String?> deviceId,
  Value<String?> notes,
  Value<int?> syncedAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$AttendanceTableReferences
    extends BaseReferences<_$AppDatabase, $AttendanceTable, AttendanceEntity> {
  $$AttendanceTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AttendanceQueueTable, List<AttendanceQueueEntity>>
      _attendanceQueueRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.attendanceQueue,
              aliasName: $_aliasNameGenerator(
                  db.attendance.id, db.attendanceQueue.attendanceId));

  $$AttendanceQueueTableProcessedTableManager get attendanceQueueRefs {
    final manager =
        $$AttendanceQueueTableTableManager($_db, $_db.attendanceQueue)
            .filter((f) => f.attendanceId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_attendanceQueueRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LeaveRequestsTable, List<LeaveRequestEntity>>
      _leaveRequestsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.leaveRequests,
              aliasName: $_aliasNameGenerator(
                  db.attendance.id, db.leaveRequests.attendanceId));

  $$LeaveRequestsTableProcessedTableManager get leaveRequestsRefs {
    final manager = $$LeaveRequestsTableTableManager($_db, $_db.leaveRequests)
        .filter((f) => f.attendanceId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_leaveRequestsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeIn => $composableBuilder(
      column: $table.timeIn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeOut => $composableBuilder(
      column: $table.timeOut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isWithinGeofence => $composableBuilder(
      column: $table.isWithinGeofence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get livenessVerified => $composableBuilder(
      column: $table.livenessVerified,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get faceMatchScore => $composableBuilder(
      column: $table.faceMatchScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> attendanceQueueRefs(
      Expression<bool> Function($$AttendanceQueueTableFilterComposer f) f) {
    final $$AttendanceQueueTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendanceQueue,
        getReferencedColumn: (t) => t.attendanceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceQueueTableFilterComposer(
              $db: $db,
              $table: $db.attendanceQueue,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> leaveRequestsRefs(
      Expression<bool> Function($$LeaveRequestsTableFilterComposer f) f) {
    final $$LeaveRequestsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.leaveRequests,
        getReferencedColumn: (t) => t.attendanceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LeaveRequestsTableFilterComposer(
              $db: $db,
              $table: $db.leaveRequests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeIn => $composableBuilder(
      column: $table.timeIn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeOut => $composableBuilder(
      column: $table.timeOut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isWithinGeofence => $composableBuilder(
      column: $table.isWithinGeofence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get livenessVerified => $composableBuilder(
      column: $table.livenessVerified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get faceMatchScore => $composableBuilder(
      column: $table.faceMatchScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get timeIn =>
      $composableBuilder(column: $table.timeIn, builder: (column) => column);

  GeneratedColumn<String> get timeOut =>
      $composableBuilder(column: $table.timeOut, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isWithinGeofence => $composableBuilder(
      column: $table.isWithinGeofence, builder: (column) => column);

  GeneratedColumn<bool> get livenessVerified => $composableBuilder(
      column: $table.livenessVerified, builder: (column) => column);

  GeneratedColumn<double> get faceMatchScore => $composableBuilder(
      column: $table.faceMatchScore, builder: (column) => column);

  GeneratedColumn<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => column);

  GeneratedColumn<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> attendanceQueueRefs<T extends Object>(
      Expression<T> Function($$AttendanceQueueTableAnnotationComposer a) f) {
    final $$AttendanceQueueTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendanceQueue,
        getReferencedColumn: (t) => t.attendanceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceQueueTableAnnotationComposer(
              $db: $db,
              $table: $db.attendanceQueue,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> leaveRequestsRefs<T extends Object>(
      Expression<T> Function($$LeaveRequestsTableAnnotationComposer a) f) {
    final $$LeaveRequestsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.leaveRequests,
        getReferencedColumn: (t) => t.attendanceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LeaveRequestsTableAnnotationComposer(
              $db: $db,
              $table: $db.leaveRequests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AttendanceTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttendanceTable,
    AttendanceEntity,
    $$AttendanceTableFilterComposer,
    $$AttendanceTableOrderingComposer,
    $$AttendanceTableAnnotationComposer,
    $$AttendanceTableCreateCompanionBuilder,
    $$AttendanceTableUpdateCompanionBuilder,
    (AttendanceEntity, $$AttendanceTableReferences),
    AttendanceEntity,
    PrefetchHooks Function(
        {bool attendanceQueueRefs, bool leaveRequestsRefs})> {
  $$AttendanceTableTableManager(_$AppDatabase db, $AttendanceTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> studentId = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String?> timeIn = const Value.absent(),
            Value<String?> timeOut = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isWithinGeofence = const Value.absent(),
            Value<bool> livenessVerified = const Value.absent(),
            Value<double?> faceMatchScore = const Value.absent(),
            Value<double?> locationLat = const Value.absent(),
            Value<double?> locationLng = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> syncedAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttendanceCompanion(
            id: id,
            studentId: studentId,
            date: date,
            timeIn: timeIn,
            timeOut: timeOut,
            status: status,
            isWithinGeofence: isWithinGeofence,
            livenessVerified: livenessVerified,
            faceMatchScore: faceMatchScore,
            locationLat: locationLat,
            locationLng: locationLng,
            deviceId: deviceId,
            notes: notes,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String studentId,
            required String date,
            Value<String?> timeIn = const Value.absent(),
            Value<String?> timeOut = const Value.absent(),
            required String status,
            Value<bool> isWithinGeofence = const Value.absent(),
            Value<bool> livenessVerified = const Value.absent(),
            Value<double?> faceMatchScore = const Value.absent(),
            Value<double?> locationLat = const Value.absent(),
            Value<double?> locationLng = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> syncedAt = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AttendanceCompanion.insert(
            id: id,
            studentId: studentId,
            date: date,
            timeIn: timeIn,
            timeOut: timeOut,
            status: status,
            isWithinGeofence: isWithinGeofence,
            livenessVerified: livenessVerified,
            faceMatchScore: faceMatchScore,
            locationLat: locationLat,
            locationLng: locationLng,
            deviceId: deviceId,
            notes: notes,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AttendanceTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {attendanceQueueRefs = false, leaveRequestsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (attendanceQueueRefs) db.attendanceQueue,
                if (leaveRequestsRefs) db.leaveRequests
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attendanceQueueRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$AttendanceTableReferences
                            ._attendanceQueueRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AttendanceTableReferences(db, table, p0)
                                .attendanceQueueRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.attendanceId == item.id),
                        typedResults: items),
                  if (leaveRequestsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$AttendanceTableReferences
                            ._leaveRequestsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AttendanceTableReferences(db, table, p0)
                                .leaveRequestsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.attendanceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AttendanceTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttendanceTable,
    AttendanceEntity,
    $$AttendanceTableFilterComposer,
    $$AttendanceTableOrderingComposer,
    $$AttendanceTableAnnotationComposer,
    $$AttendanceTableCreateCompanionBuilder,
    $$AttendanceTableUpdateCompanionBuilder,
    (AttendanceEntity, $$AttendanceTableReferences),
    AttendanceEntity,
    PrefetchHooks Function({bool attendanceQueueRefs, bool leaveRequestsRefs})>;
typedef $$AttendanceQueueTableCreateCompanionBuilder = AttendanceQueueCompanion
    Function({
  required String id,
  required String attendanceId,
  required String studentId,
  required String action,
  required String payload,
  required String status,
  Value<int> retryCount,
  Value<String?> errorMessage,
  required int createdAt,
  Value<int?> syncedAt,
  Value<int> rowid,
});
typedef $$AttendanceQueueTableUpdateCompanionBuilder = AttendanceQueueCompanion
    Function({
  Value<String> id,
  Value<String> attendanceId,
  Value<String> studentId,
  Value<String> action,
  Value<String> payload,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> errorMessage,
  Value<int> createdAt,
  Value<int?> syncedAt,
  Value<int> rowid,
});

final class $$AttendanceQueueTableReferences extends BaseReferences<
    _$AppDatabase, $AttendanceQueueTable, AttendanceQueueEntity> {
  $$AttendanceQueueTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AttendanceTable _attendanceIdTable(_$AppDatabase db) =>
      db.attendance.createAlias($_aliasNameGenerator(
          db.attendanceQueue.attendanceId, db.attendance.id));

  $$AttendanceTableProcessedTableManager? get attendanceId {
    if ($_item.attendanceId == null) return null;
    final manager = $$AttendanceTableTableManager($_db, $_db.attendance)
        .filter((f) => f.id($_item.attendanceId!));
    final item = $_typedResult.readTableOrNull(_attendanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AttendanceQueueTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceQueueTable> {
  $$AttendanceQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  $$AttendanceTableFilterComposer get attendanceId {
    final $$AttendanceTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attendanceId,
        referencedTable: $db.attendance,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceTableFilterComposer(
              $db: $db,
              $table: $db.attendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttendanceQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceQueueTable> {
  $$AttendanceQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  $$AttendanceTableOrderingComposer get attendanceId {
    final $$AttendanceTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attendanceId,
        referencedTable: $db.attendance,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceTableOrderingComposer(
              $db: $db,
              $table: $db.attendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttendanceQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceQueueTable> {
  $$AttendanceQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  $$AttendanceTableAnnotationComposer get attendanceId {
    final $$AttendanceTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attendanceId,
        referencedTable: $db.attendance,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceTableAnnotationComposer(
              $db: $db,
              $table: $db.attendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttendanceQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttendanceQueueTable,
    AttendanceQueueEntity,
    $$AttendanceQueueTableFilterComposer,
    $$AttendanceQueueTableOrderingComposer,
    $$AttendanceQueueTableAnnotationComposer,
    $$AttendanceQueueTableCreateCompanionBuilder,
    $$AttendanceQueueTableUpdateCompanionBuilder,
    (AttendanceQueueEntity, $$AttendanceQueueTableReferences),
    AttendanceQueueEntity,
    PrefetchHooks Function({bool attendanceId})> {
  $$AttendanceQueueTableTableManager(
      _$AppDatabase db, $AttendanceQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> attendanceId = const Value.absent(),
            Value<String> studentId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttendanceQueueCompanion(
            id: id,
            attendanceId: attendanceId,
            studentId: studentId,
            action: action,
            payload: payload,
            status: status,
            retryCount: retryCount,
            errorMessage: errorMessage,
            createdAt: createdAt,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String attendanceId,
            required String studentId,
            required String action,
            required String payload,
            required String status,
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            required int createdAt,
            Value<int?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttendanceQueueCompanion.insert(
            id: id,
            attendanceId: attendanceId,
            studentId: studentId,
            action: action,
            payload: payload,
            status: status,
            retryCount: retryCount,
            errorMessage: errorMessage,
            createdAt: createdAt,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AttendanceQueueTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({attendanceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (attendanceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.attendanceId,
                    referencedTable:
                        $$AttendanceQueueTableReferences._attendanceIdTable(db),
                    referencedColumn: $$AttendanceQueueTableReferences
                        ._attendanceIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AttendanceQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttendanceQueueTable,
    AttendanceQueueEntity,
    $$AttendanceQueueTableFilterComposer,
    $$AttendanceQueueTableOrderingComposer,
    $$AttendanceQueueTableAnnotationComposer,
    $$AttendanceQueueTableCreateCompanionBuilder,
    $$AttendanceQueueTableUpdateCompanionBuilder,
    (AttendanceQueueEntity, $$AttendanceQueueTableReferences),
    AttendanceQueueEntity,
    PrefetchHooks Function({bool attendanceId})>;
typedef $$GradesTableCreateCompanionBuilder = GradesCompanion Function({
  required String id,
  required String studentId,
  required String subject,
  required String type,
  required double score,
  Value<int?> semester,
  Value<int?> year,
  Value<String?> inputtedBy,
  Value<int?> syncedAt,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$GradesTableUpdateCompanionBuilder = GradesCompanion Function({
  Value<String> id,
  Value<String> studentId,
  Value<String> subject,
  Value<String> type,
  Value<double> score,
  Value<int?> semester,
  Value<int?> year,
  Value<String?> inputtedBy,
  Value<int?> syncedAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$GradesTableReferences
    extends BaseReferences<_$AppDatabase, $GradesTable, GradeEntity> {
  $$GradesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _inputtedByTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.grades.inputtedBy, db.users.id));

  $$UsersTableProcessedTableManager? get inputtedBy {
    if ($_item.inputtedBy == null) return null;
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id($_item.inputtedBy!));
    final item = $_typedResult.readTableOrNull(_inputtedByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GradesTableFilterComposer
    extends Composer<_$AppDatabase, $GradesTable> {
  $$GradesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get semester => $composableBuilder(
      column: $table.semester, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get inputtedBy {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.inputtedBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GradesTableOrderingComposer
    extends Composer<_$AppDatabase, $GradesTable> {
  $$GradesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get semester => $composableBuilder(
      column: $table.semester, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get inputtedBy {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.inputtedBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GradesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GradesTable> {
  $$GradesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get semester =>
      $composableBuilder(column: $table.semester, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get inputtedBy {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.inputtedBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GradesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GradesTable,
    GradeEntity,
    $$GradesTableFilterComposer,
    $$GradesTableOrderingComposer,
    $$GradesTableAnnotationComposer,
    $$GradesTableCreateCompanionBuilder,
    $$GradesTableUpdateCompanionBuilder,
    (GradeEntity, $$GradesTableReferences),
    GradeEntity,
    PrefetchHooks Function({bool inputtedBy})> {
  $$GradesTableTableManager(_$AppDatabase db, $GradesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GradesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GradesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GradesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> studentId = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> score = const Value.absent(),
            Value<int?> semester = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<String?> inputtedBy = const Value.absent(),
            Value<int?> syncedAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GradesCompanion(
            id: id,
            studentId: studentId,
            subject: subject,
            type: type,
            score: score,
            semester: semester,
            year: year,
            inputtedBy: inputtedBy,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String studentId,
            required String subject,
            required String type,
            required double score,
            Value<int?> semester = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<String?> inputtedBy = const Value.absent(),
            Value<int?> syncedAt = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GradesCompanion.insert(
            id: id,
            studentId: studentId,
            subject: subject,
            type: type,
            score: score,
            semester: semester,
            year: year,
            inputtedBy: inputtedBy,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GradesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({inputtedBy = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (inputtedBy) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.inputtedBy,
                    referencedTable:
                        $$GradesTableReferences._inputtedByTable(db),
                    referencedColumn:
                        $$GradesTableReferences._inputtedByTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GradesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GradesTable,
    GradeEntity,
    $$GradesTableFilterComposer,
    $$GradesTableOrderingComposer,
    $$GradesTableAnnotationComposer,
    $$GradesTableCreateCompanionBuilder,
    $$GradesTableUpdateCompanionBuilder,
    (GradeEntity, $$GradesTableReferences),
    GradeEntity,
    PrefetchHooks Function({bool inputtedBy})>;
typedef $$LeaveRequestsTableCreateCompanionBuilder = LeaveRequestsCompanion
    Function({
  required String id,
  required String studentId,
  Value<String?> attendanceId,
  required String type,
  Value<String?> reason,
  Value<String?> attachmentUrl,
  Value<String?> attachmentLocalPath,
  required String status,
  Value<String?> rejectedReason,
  Value<String?> reviewedBy,
  Value<int?> reviewedAt,
  Value<String?> dateFrom,
  Value<String?> dateTo,
  Value<int?> syncedAt,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$LeaveRequestsTableUpdateCompanionBuilder = LeaveRequestsCompanion
    Function({
  Value<String> id,
  Value<String> studentId,
  Value<String?> attendanceId,
  Value<String> type,
  Value<String?> reason,
  Value<String?> attachmentUrl,
  Value<String?> attachmentLocalPath,
  Value<String> status,
  Value<String?> rejectedReason,
  Value<String?> reviewedBy,
  Value<int?> reviewedAt,
  Value<String?> dateFrom,
  Value<String?> dateTo,
  Value<int?> syncedAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$LeaveRequestsTableReferences extends BaseReferences<_$AppDatabase,
    $LeaveRequestsTable, LeaveRequestEntity> {
  $$LeaveRequestsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AttendanceTable _attendanceIdTable(_$AppDatabase db) =>
      db.attendance.createAlias($_aliasNameGenerator(
          db.leaveRequests.attendanceId, db.attendance.id));

  $$AttendanceTableProcessedTableManager? get attendanceId {
    if ($_item.attendanceId == null) return null;
    final manager = $$AttendanceTableTableManager($_db, $_db.attendance)
        .filter((f) => f.id($_item.attendanceId!));
    final item = $_typedResult.readTableOrNull(_attendanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _reviewedByTable(_$AppDatabase db) => db.users.createAlias(
      $_aliasNameGenerator(db.leaveRequests.reviewedBy, db.users.id));

  $$UsersTableProcessedTableManager? get reviewedBy {
    if ($_item.reviewedBy == null) return null;
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id($_item.reviewedBy!));
    final item = $_typedResult.readTableOrNull(_reviewedByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LeaveRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $LeaveRequestsTable> {
  $$LeaveRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attachmentUrl => $composableBuilder(
      column: $table.attachmentUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attachmentLocalPath => $composableBuilder(
      column: $table.attachmentLocalPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rejectedReason => $composableBuilder(
      column: $table.rejectedReason,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateFrom => $composableBuilder(
      column: $table.dateFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateTo => $composableBuilder(
      column: $table.dateTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$AttendanceTableFilterComposer get attendanceId {
    final $$AttendanceTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attendanceId,
        referencedTable: $db.attendance,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceTableFilterComposer(
              $db: $db,
              $table: $db.attendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get reviewedBy {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reviewedBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LeaveRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $LeaveRequestsTable> {
  $$LeaveRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attachmentUrl => $composableBuilder(
      column: $table.attachmentUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attachmentLocalPath => $composableBuilder(
      column: $table.attachmentLocalPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rejectedReason => $composableBuilder(
      column: $table.rejectedReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateFrom => $composableBuilder(
      column: $table.dateFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateTo => $composableBuilder(
      column: $table.dateTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$AttendanceTableOrderingComposer get attendanceId {
    final $$AttendanceTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attendanceId,
        referencedTable: $db.attendance,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceTableOrderingComposer(
              $db: $db,
              $table: $db.attendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get reviewedBy {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reviewedBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LeaveRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeaveRequestsTable> {
  $$LeaveRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get attachmentUrl => $composableBuilder(
      column: $table.attachmentUrl, builder: (column) => column);

  GeneratedColumn<String> get attachmentLocalPath => $composableBuilder(
      column: $table.attachmentLocalPath, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get rejectedReason => $composableBuilder(
      column: $table.rejectedReason, builder: (column) => column);

  GeneratedColumn<int> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => column);

  GeneratedColumn<String> get dateFrom =>
      $composableBuilder(column: $table.dateFrom, builder: (column) => column);

  GeneratedColumn<String> get dateTo =>
      $composableBuilder(column: $table.dateTo, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AttendanceTableAnnotationComposer get attendanceId {
    final $$AttendanceTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attendanceId,
        referencedTable: $db.attendance,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceTableAnnotationComposer(
              $db: $db,
              $table: $db.attendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get reviewedBy {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reviewedBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LeaveRequestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LeaveRequestsTable,
    LeaveRequestEntity,
    $$LeaveRequestsTableFilterComposer,
    $$LeaveRequestsTableOrderingComposer,
    $$LeaveRequestsTableAnnotationComposer,
    $$LeaveRequestsTableCreateCompanionBuilder,
    $$LeaveRequestsTableUpdateCompanionBuilder,
    (LeaveRequestEntity, $$LeaveRequestsTableReferences),
    LeaveRequestEntity,
    PrefetchHooks Function({bool attendanceId, bool reviewedBy})> {
  $$LeaveRequestsTableTableManager(_$AppDatabase db, $LeaveRequestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeaveRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeaveRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeaveRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> studentId = const Value.absent(),
            Value<String?> attendanceId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<String?> attachmentUrl = const Value.absent(),
            Value<String?> attachmentLocalPath = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> rejectedReason = const Value.absent(),
            Value<String?> reviewedBy = const Value.absent(),
            Value<int?> reviewedAt = const Value.absent(),
            Value<String?> dateFrom = const Value.absent(),
            Value<String?> dateTo = const Value.absent(),
            Value<int?> syncedAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LeaveRequestsCompanion(
            id: id,
            studentId: studentId,
            attendanceId: attendanceId,
            type: type,
            reason: reason,
            attachmentUrl: attachmentUrl,
            attachmentLocalPath: attachmentLocalPath,
            status: status,
            rejectedReason: rejectedReason,
            reviewedBy: reviewedBy,
            reviewedAt: reviewedAt,
            dateFrom: dateFrom,
            dateTo: dateTo,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String studentId,
            Value<String?> attendanceId = const Value.absent(),
            required String type,
            Value<String?> reason = const Value.absent(),
            Value<String?> attachmentUrl = const Value.absent(),
            Value<String?> attachmentLocalPath = const Value.absent(),
            required String status,
            Value<String?> rejectedReason = const Value.absent(),
            Value<String?> reviewedBy = const Value.absent(),
            Value<int?> reviewedAt = const Value.absent(),
            Value<String?> dateFrom = const Value.absent(),
            Value<String?> dateTo = const Value.absent(),
            Value<int?> syncedAt = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LeaveRequestsCompanion.insert(
            id: id,
            studentId: studentId,
            attendanceId: attendanceId,
            type: type,
            reason: reason,
            attachmentUrl: attachmentUrl,
            attachmentLocalPath: attachmentLocalPath,
            status: status,
            rejectedReason: rejectedReason,
            reviewedBy: reviewedBy,
            reviewedAt: reviewedAt,
            dateFrom: dateFrom,
            dateTo: dateTo,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LeaveRequestsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({attendanceId = false, reviewedBy = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (attendanceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.attendanceId,
                    referencedTable:
                        $$LeaveRequestsTableReferences._attendanceIdTable(db),
                    referencedColumn: $$LeaveRequestsTableReferences
                        ._attendanceIdTable(db)
                        .id,
                  ) as T;
                }
                if (reviewedBy) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.reviewedBy,
                    referencedTable:
                        $$LeaveRequestsTableReferences._reviewedByTable(db),
                    referencedColumn:
                        $$LeaveRequestsTableReferences._reviewedByTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LeaveRequestsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LeaveRequestsTable,
    LeaveRequestEntity,
    $$LeaveRequestsTableFilterComposer,
    $$LeaveRequestsTableOrderingComposer,
    $$LeaveRequestsTableAnnotationComposer,
    $$LeaveRequestsTableCreateCompanionBuilder,
    $$LeaveRequestsTableUpdateCompanionBuilder,
    (LeaveRequestEntity, $$LeaveRequestsTableReferences),
    LeaveRequestEntity,
    PrefetchHooks Function({bool attendanceId, bool reviewedBy})>;
typedef $$AuditLogTableCreateCompanionBuilder = AuditLogCompanion Function({
  required String id,
  required String adminId,
  required String action,
  required String entityType,
  required String entityId,
  Value<String?> oldValue,
  Value<String?> newValue,
  Value<String?> ipAddress,
  required int createdAt,
  Value<int> rowid,
});
typedef $$AuditLogTableUpdateCompanionBuilder = AuditLogCompanion Function({
  Value<String> id,
  Value<String> adminId,
  Value<String> action,
  Value<String> entityType,
  Value<String> entityId,
  Value<String?> oldValue,
  Value<String?> newValue,
  Value<String?> ipAddress,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$AuditLogTableReferences
    extends BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogEntity> {
  $$AuditLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _adminIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.auditLog.adminId, db.users.id));

  $$UsersTableProcessedTableManager? get adminId {
    if ($_item.adminId == null) return null;
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id($_item.adminId!));
    final item = $_typedResult.readTableOrNull(_adminIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AuditLogTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get oldValue => $composableBuilder(
      column: $table.oldValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get newValue => $composableBuilder(
      column: $table.newValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ipAddress => $composableBuilder(
      column: $table.ipAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get adminId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.adminId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AuditLogTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get oldValue => $composableBuilder(
      column: $table.oldValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get newValue => $composableBuilder(
      column: $table.newValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ipAddress => $composableBuilder(
      column: $table.ipAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get adminId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.adminId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AuditLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get adminId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.adminId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AuditLogTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditLogTable,
    AuditLogEntity,
    $$AuditLogTableFilterComposer,
    $$AuditLogTableOrderingComposer,
    $$AuditLogTableAnnotationComposer,
    $$AuditLogTableCreateCompanionBuilder,
    $$AuditLogTableUpdateCompanionBuilder,
    (AuditLogEntity, $$AuditLogTableReferences),
    AuditLogEntity,
    PrefetchHooks Function({bool adminId})> {
  $$AuditLogTableTableManager(_$AppDatabase db, $AuditLogTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> adminId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String?> oldValue = const Value.absent(),
            Value<String?> newValue = const Value.absent(),
            Value<String?> ipAddress = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogCompanion(
            id: id,
            adminId: adminId,
            action: action,
            entityType: entityType,
            entityId: entityId,
            oldValue: oldValue,
            newValue: newValue,
            ipAddress: ipAddress,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String adminId,
            required String action,
            required String entityType,
            required String entityId,
            Value<String?> oldValue = const Value.absent(),
            Value<String?> newValue = const Value.absent(),
            Value<String?> ipAddress = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogCompanion.insert(
            id: id,
            adminId: adminId,
            action: action,
            entityType: entityType,
            entityId: entityId,
            oldValue: oldValue,
            newValue: newValue,
            ipAddress: ipAddress,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AuditLogTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({adminId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (adminId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.adminId,
                    referencedTable:
                        $$AuditLogTableReferences._adminIdTable(db),
                    referencedColumn:
                        $$AuditLogTableReferences._adminIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AuditLogTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditLogTable,
    AuditLogEntity,
    $$AuditLogTableFilterComposer,
    $$AuditLogTableOrderingComposer,
    $$AuditLogTableAnnotationComposer,
    $$AuditLogTableCreateCompanionBuilder,
    $$AuditLogTableUpdateCompanionBuilder,
    (AuditLogEntity, $$AuditLogTableReferences),
    AuditLogEntity,
    PrefetchHooks Function({bool adminId})>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  required String type,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<String> type,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    SettingEntity,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (
      SettingEntity,
      BaseReferences<_$AppDatabase, $SettingsTable, SettingEntity>
    ),
    SettingEntity,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            type: type,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            required String type,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            type: type,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    SettingEntity,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (
      SettingEntity,
      BaseReferences<_$AppDatabase, $SettingsTable, SettingEntity>
    ),
    SettingEntity,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$FaceEmbeddingsTableTableManager get faceEmbeddings =>
      $$FaceEmbeddingsTableTableManager(_db, _db.faceEmbeddings);
  $$AttendanceTableTableManager get attendance =>
      $$AttendanceTableTableManager(_db, _db.attendance);
  $$AttendanceQueueTableTableManager get attendanceQueue =>
      $$AttendanceQueueTableTableManager(_db, _db.attendanceQueue);
  $$GradesTableTableManager get grades =>
      $$GradesTableTableManager(_db, _db.grades);
  $$LeaveRequestsTableTableManager get leaveRequests =>
      $$LeaveRequestsTableTableManager(_db, _db.leaveRequests);
  $$AuditLogTableTableManager get auditLog =>
      $$AuditLogTableTableManager(_db, _db.auditLog);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
