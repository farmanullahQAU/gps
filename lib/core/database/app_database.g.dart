// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SchoolsTable extends Schools with TableInfo<$SchoolsTable, School> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchoolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _academicYearStartMeta = const VerificationMeta(
    'academicYearStart',
  );
  @override
  late final GeneratedColumn<String> academicYearStart =
      GeneratedColumn<String>(
        'academic_year_start',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _academicYearEndMeta = const VerificationMeta(
    'academicYearEnd',
  );
  @override
  late final GeneratedColumn<String> academicYearEnd = GeneratedColumn<String>(
    'academic_year_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    code,
    address,
    phone,
    logoUrl,
    academicYearStart,
    academicYearEnd,
    createdAt,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schools';
  @override
  VerificationContext validateIntegrity(
    Insertable<School> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('academic_year_start')) {
      context.handle(
        _academicYearStartMeta,
        academicYearStart.isAcceptableOrUnknown(
          data['academic_year_start']!,
          _academicYearStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_academicYearStartMeta);
    }
    if (data.containsKey('academic_year_end')) {
      context.handle(
        _academicYearEndMeta,
        academicYearEnd.isAcceptableOrUnknown(
          data['academic_year_end']!,
          _academicYearEndMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_academicYearEndMeta);
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
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  School map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return School(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      academicYearStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}academic_year_start'],
      )!,
      academicYearEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}academic_year_end'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $SchoolsTable createAlias(String alias) {
    return $SchoolsTable(attachedDatabase, alias);
  }
}

class School extends DataClass implements Insertable<School> {
  final String id;
  final String name;
  final String code;
  final String? address;
  final String? phone;
  final String? logoUrl;
  final String academicYearStart;
  final String academicYearEnd;
  final int createdAt;
  final int updatedAt;
  final int revision;
  const School({
    required this.id,
    required this.name,
    required this.code,
    this.address,
    this.phone,
    this.logoUrl,
    required this.academicYearStart,
    required this.academicYearEnd,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    map['academic_year_start'] = Variable<String>(academicYearStart);
    map['academic_year_end'] = Variable<String>(academicYearEnd);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  SchoolsCompanion toCompanion(bool nullToAbsent) {
    return SchoolsCompanion(
      id: Value(id),
      name: Value(name),
      code: Value(code),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      academicYearStart: Value(academicYearStart),
      academicYearEnd: Value(academicYearEnd),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory School.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return School(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      academicYearStart: serializer.fromJson<String>(json['academicYearStart']),
      academicYearEnd: serializer.fromJson<String>(json['academicYearEnd']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'academicYearStart': serializer.toJson<String>(academicYearStart),
      'academicYearEnd': serializer.toJson<String>(academicYearEnd),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  School copyWith({
    String? id,
    String? name,
    String? code,
    Value<String?> address = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> logoUrl = const Value.absent(),
    String? academicYearStart,
    String? academicYearEnd,
    int? createdAt,
    int? updatedAt,
    int? revision,
  }) => School(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
    address: address.present ? address.value : this.address,
    phone: phone.present ? phone.value : this.phone,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    academicYearStart: academicYearStart ?? this.academicYearStart,
    academicYearEnd: academicYearEnd ?? this.academicYearEnd,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  School copyWithCompanion(SchoolsCompanion data) {
    return School(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      academicYearStart: data.academicYearStart.present
          ? data.academicYearStart.value
          : this.academicYearStart,
      academicYearEnd: data.academicYearEnd.present
          ? data.academicYearEnd.value
          : this.academicYearEnd,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('School(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('academicYearStart: $academicYearStart, ')
          ..write('academicYearEnd: $academicYearEnd, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    code,
    address,
    phone,
    logoUrl,
    academicYearStart,
    academicYearEnd,
    createdAt,
    updatedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is School &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.logoUrl == this.logoUrl &&
          other.academicYearStart == this.academicYearStart &&
          other.academicYearEnd == this.academicYearEnd &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class SchoolsCompanion extends UpdateCompanion<School> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> code;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<String?> logoUrl;
  final Value<String> academicYearStart;
  final Value<String> academicYearEnd;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const SchoolsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.academicYearStart = const Value.absent(),
    this.academicYearEnd = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchoolsCompanion.insert({
    required String id,
    required String name,
    required String code,
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.logoUrl = const Value.absent(),
    required String academicYearStart,
    required String academicYearEnd,
    required int createdAt,
    required int updatedAt,
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       code = Value(code),
       academicYearStart = Value(academicYearStart),
       academicYearEnd = Value(academicYearEnd),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<School> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? logoUrl,
    Expression<String>? academicYearStart,
    Expression<String>? academicYearEnd,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (academicYearStart != null) 'academic_year_start': academicYearStart,
      if (academicYearEnd != null) 'academic_year_end': academicYearEnd,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchoolsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? code,
    Value<String?>? address,
    Value<String?>? phone,
    Value<String?>? logoUrl,
    Value<String>? academicYearStart,
    Value<String>? academicYearEnd,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return SchoolsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      logoUrl: logoUrl ?? this.logoUrl,
      academicYearStart: academicYearStart ?? this.academicYearStart,
      academicYearEnd: academicYearEnd ?? this.academicYearEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (academicYearStart.present) {
      map['academic_year_start'] = Variable<String>(academicYearStart.value);
    }
    if (academicYearEnd.present) {
      map['academic_year_end'] = Variable<String>(academicYearEnd.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('academicYearStart: $academicYearStart, ')
          ..write('academicYearEnd: $academicYearEnd, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _pinCodeHashMeta = const VerificationMeta(
    'pinCodeHash',
  );
  @override
  late final GeneratedColumn<String> pinCodeHash = GeneratedColumn<String>(
    'pin_code_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cnicMeta = const VerificationMeta('cnic');
  @override
  late final GeneratedColumn<String> cnic = GeneratedColumn<String>(
    'cnic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _designationMeta = const VerificationMeta(
    'designation',
  );
  @override
  late final GeneratedColumn<String> designation = GeneratedColumn<String>(
    'designation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    name,
    email,
    phone,
    role,
    pinCodeHash,
    avatarUrl,
    cnic,
    designation,
    isActive,
    createdAt,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('pin_code_hash')) {
      context.handle(
        _pinCodeHashMeta,
        pinCodeHash.isAcceptableOrUnknown(
          data['pin_code_hash']!,
          _pinCodeHashMeta,
        ),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('cnic')) {
      context.handle(
        _cnicMeta,
        cnic.isAcceptableOrUnknown(data['cnic']!, _cnicMeta),
      );
    }
    if (data.containsKey('designation')) {
      context.handle(
        _designationMeta,
        designation.isAcceptableOrUnknown(
          data['designation']!,
          _designationMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      pinCodeHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_code_hash'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      cnic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cnic'],
      ),
      designation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}designation'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String schoolId;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final String? pinCodeHash;
  final String? avatarUrl;
  final String? cnic;
  final String? designation;
  final bool isActive;
  final int createdAt;
  final int updatedAt;
  final int revision;
  const User({
    required this.id,
    required this.schoolId,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    this.pinCodeHash,
    this.avatarUrl,
    this.cnic,
    this.designation,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || pinCodeHash != null) {
      map['pin_code_hash'] = Variable<String>(pinCodeHash);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || cnic != null) {
      map['cnic'] = Variable<String>(cnic);
    }
    if (!nullToAbsent || designation != null) {
      map['designation'] = Variable<String>(designation);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      name: Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      role: Value(role),
      pinCodeHash: pinCodeHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinCodeHash),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      cnic: cnic == null && nullToAbsent ? const Value.absent() : Value(cnic),
      designation: designation == null && nullToAbsent
          ? const Value.absent()
          : Value(designation),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      role: serializer.fromJson<String>(json['role']),
      pinCodeHash: serializer.fromJson<String?>(json['pinCodeHash']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      cnic: serializer.fromJson<String?>(json['cnic']),
      designation: serializer.fromJson<String?>(json['designation']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'role': serializer.toJson<String>(role),
      'pinCodeHash': serializer.toJson<String?>(pinCodeHash),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'cnic': serializer.toJson<String?>(cnic),
      'designation': serializer.toJson<String?>(designation),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  User copyWith({
    String? id,
    String? schoolId,
    String? name,
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? role,
    Value<String?> pinCodeHash = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> cnic = const Value.absent(),
    Value<String?> designation = const Value.absent(),
    bool? isActive,
    int? createdAt,
    int? updatedAt,
    int? revision,
  }) => User(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    name: name ?? this.name,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    role: role ?? this.role,
    pinCodeHash: pinCodeHash.present ? pinCodeHash.value : this.pinCodeHash,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    cnic: cnic.present ? cnic.value : this.cnic,
    designation: designation.present ? designation.value : this.designation,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      role: data.role.present ? data.role.value : this.role,
      pinCodeHash: data.pinCodeHash.present
          ? data.pinCodeHash.value
          : this.pinCodeHash,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      cnic: data.cnic.present ? data.cnic.value : this.cnic,
      designation: data.designation.present
          ? data.designation.value
          : this.designation,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('pinCodeHash: $pinCodeHash, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('cnic: $cnic, ')
          ..write('designation: $designation, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    name,
    email,
    phone,
    role,
    pinCodeHash,
    avatarUrl,
    cnic,
    designation,
    isActive,
    createdAt,
    updatedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.role == this.role &&
          other.pinCodeHash == this.pinCodeHash &&
          other.avatarUrl == this.avatarUrl &&
          other.cnic == this.cnic &&
          other.designation == this.designation &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> name;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String> role;
  final Value<String?> pinCodeHash;
  final Value<String?> avatarUrl;
  final Value<String?> cnic;
  final Value<String?> designation;
  final Value<bool> isActive;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.role = const Value.absent(),
    this.pinCodeHash = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.cnic = const Value.absent(),
    this.designation = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String schoolId,
    required String name,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    required String role,
    this.pinCodeHash = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.cnic = const Value.absent(),
    this.designation = const Value.absent(),
    this.isActive = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       name = Value(name),
       role = Value(role),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? role,
    Expression<String>? pinCodeHash,
    Expression<String>? avatarUrl,
    Expression<String>? cnic,
    Expression<String>? designation,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (pinCodeHash != null) 'pin_code_hash': pinCodeHash,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (cnic != null) 'cnic': cnic,
      if (designation != null) 'designation': designation,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? name,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String>? role,
    Value<String?>? pinCodeHash,
    Value<String?>? avatarUrl,
    Value<String?>? cnic,
    Value<String?>? designation,
    Value<bool>? isActive,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      pinCodeHash: pinCodeHash ?? this.pinCodeHash,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      cnic: cnic ?? this.cnic,
      designation: designation ?? this.designation,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (pinCodeHash.present) {
      map['pin_code_hash'] = Variable<String>(pinCodeHash.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (cnic.present) {
      map['cnic'] = Variable<String>(cnic.value);
    }
    if (designation.present) {
      map['designation'] = Variable<String>(designation.value);
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
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
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
          ..write('schoolId: $schoolId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('pinCodeHash: $pinCodeHash, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('cnic: $cnic, ')
          ..write('designation: $designation, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClassesTable extends Classes with TableInfo<$ClassesTable, ClassesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numericLevelMeta = const VerificationMeta(
    'numericLevel',
  );
  @override
  late final GeneratedColumn<int> numericLevel = GeneratedColumn<int>(
    'numeric_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    name,
    numericLevel,
    createdAt,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('numeric_level')) {
      context.handle(
        _numericLevelMeta,
        numericLevel.isAcceptableOrUnknown(
          data['numeric_level']!,
          _numericLevelMeta,
        ),
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
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      numericLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numeric_level'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $ClassesTable createAlias(String alias) {
    return $ClassesTable(attachedDatabase, alias);
  }
}

class ClassesData extends DataClass implements Insertable<ClassesData> {
  final String id;
  final String schoolId;
  final String name;
  final int numericLevel;
  final int createdAt;
  final int updatedAt;
  final int revision;
  const ClassesData({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.numericLevel,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['name'] = Variable<String>(name);
    map['numeric_level'] = Variable<int>(numericLevel);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  ClassesCompanion toCompanion(bool nullToAbsent) {
    return ClassesCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      name: Value(name),
      numericLevel: Value(numericLevel),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory ClassesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassesData(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      name: serializer.fromJson<String>(json['name']),
      numericLevel: serializer.fromJson<int>(json['numericLevel']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'name': serializer.toJson<String>(name),
      'numericLevel': serializer.toJson<int>(numericLevel),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  ClassesData copyWith({
    String? id,
    String? schoolId,
    String? name,
    int? numericLevel,
    int? createdAt,
    int? updatedAt,
    int? revision,
  }) => ClassesData(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    name: name ?? this.name,
    numericLevel: numericLevel ?? this.numericLevel,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  ClassesData copyWithCompanion(ClassesCompanion data) {
    return ClassesData(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      name: data.name.present ? data.name.value : this.name,
      numericLevel: data.numericLevel.present
          ? data.numericLevel.value
          : this.numericLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassesData(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('name: $name, ')
          ..write('numericLevel: $numericLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    name,
    numericLevel,
    createdAt,
    updatedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassesData &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.name == this.name &&
          other.numericLevel == this.numericLevel &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class ClassesCompanion extends UpdateCompanion<ClassesData> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> name;
  final Value<int> numericLevel;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const ClassesCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.name = const Value.absent(),
    this.numericLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassesCompanion.insert({
    required String id,
    required String schoolId,
    required String name,
    this.numericLevel = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ClassesData> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? name,
    Expression<int>? numericLevel,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (name != null) 'name': name,
      if (numericLevel != null) 'numeric_level': numericLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassesCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? name,
    Value<int>? numericLevel,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return ClassesCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      numericLevel: numericLevel ?? this.numericLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (numericLevel.present) {
      map['numeric_level'] = Variable<int>(numericLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassesCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('name: $name, ')
          ..write('numericLevel: $numericLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SectionsTable extends Sections with TableInfo<$SectionsTable, Section> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  @override
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    classId,
    name,
    teacherId,
    createdAt,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Section> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
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
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Section map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Section(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $SectionsTable createAlias(String alias) {
    return $SectionsTable(attachedDatabase, alias);
  }
}

class Section extends DataClass implements Insertable<Section> {
  final String id;
  final String schoolId;
  final String classId;
  final String name;
  final String? teacherId;
  final int createdAt;
  final int updatedAt;
  final int revision;
  const Section({
    required this.id,
    required this.schoolId,
    required this.classId,
    required this.name,
    this.teacherId,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['class_id'] = Variable<String>(classId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || teacherId != null) {
      map['teacher_id'] = Variable<String>(teacherId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  SectionsCompanion toCompanion(bool nullToAbsent) {
    return SectionsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      classId: Value(classId),
      name: Value(name),
      teacherId: teacherId == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory Section.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Section(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      classId: serializer.fromJson<String>(json['classId']),
      name: serializer.fromJson<String>(json['name']),
      teacherId: serializer.fromJson<String?>(json['teacherId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'classId': serializer.toJson<String>(classId),
      'name': serializer.toJson<String>(name),
      'teacherId': serializer.toJson<String?>(teacherId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  Section copyWith({
    String? id,
    String? schoolId,
    String? classId,
    String? name,
    Value<String?> teacherId = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    int? revision,
  }) => Section(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    classId: classId ?? this.classId,
    name: name ?? this.name,
    teacherId: teacherId.present ? teacherId.value : this.teacherId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  Section copyWithCompanion(SectionsCompanion data) {
    return Section(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      classId: data.classId.present ? data.classId.value : this.classId,
      name: data.name.present ? data.name.value : this.name,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Section(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('classId: $classId, ')
          ..write('name: $name, ')
          ..write('teacherId: $teacherId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    classId,
    name,
    teacherId,
    createdAt,
    updatedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Section &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.classId == this.classId &&
          other.name == this.name &&
          other.teacherId == this.teacherId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class SectionsCompanion extends UpdateCompanion<Section> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> classId;
  final Value<String> name;
  final Value<String?> teacherId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const SectionsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.classId = const Value.absent(),
    this.name = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SectionsCompanion.insert({
    required String id,
    required String schoolId,
    required String classId,
    required String name,
    this.teacherId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       classId = Value(classId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Section> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? classId,
    Expression<String>? name,
    Expression<String>? teacherId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (classId != null) 'class_id': classId,
      if (name != null) 'name': name,
      if (teacherId != null) 'teacher_id': teacherId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? classId,
    Value<String>? name,
    Value<String?>? teacherId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return SectionsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      classId: classId ?? this.classId,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('classId: $classId, ')
          ..write('name: $name, ')
          ..write('teacherId: $teacherId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _admissionNumberMeta = const VerificationMeta(
    'admissionNumber',
  );
  @override
  late final GeneratedColumn<String> admissionNumber = GeneratedColumn<String>(
    'admission_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rollNumberMeta = const VerificationMeta(
    'rollNumber',
  );
  @override
  late final GeneratedColumn<String> rollNumber = GeneratedColumn<String>(
    'roll_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatherOrGuardianNameMeta =
      const VerificationMeta('fatherOrGuardianName');
  @override
  late final GeneratedColumn<String> fatherOrGuardianName =
      GeneratedColumn<String>(
        'father_or_guardian_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<String> dateOfBirth = GeneratedColumn<String>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _admissionDateMeta = const VerificationMeta(
    'admissionDate',
  );
  @override
  late final GeneratedColumn<String> admissionDate = GeneratedColumn<String>(
    'admission_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _qrTokenMeta = const VerificationMeta(
    'qrToken',
  );
  @override
  late final GeneratedColumn<String> qrToken = GeneratedColumn<String>(
    'qr_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentCnicMeta = const VerificationMeta(
    'studentCnic',
  );
  @override
  late final GeneratedColumn<String> studentCnic = GeneratedColumn<String>(
    'student_cnic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatherCnicMeta = const VerificationMeta(
    'fatherCnic',
  );
  @override
  late final GeneratedColumn<String> fatherCnic = GeneratedColumn<String>(
    'father_cnic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVaccinatedMeta = const VerificationMeta(
    'isVaccinated',
  );
  @override
  late final GeneratedColumn<bool> isVaccinated = GeneratedColumn<bool>(
    'is_vaccinated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_vaccinated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _vaccineFirstDoseDateMeta =
      const VerificationMeta('vaccineFirstDoseDate');
  @override
  late final GeneratedColumn<String> vaccineFirstDoseDate =
      GeneratedColumn<String>(
        'vaccine_first_dose_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _vaccineSecondDoseDateMeta =
      const VerificationMeta('vaccineSecondDoseDate');
  @override
  late final GeneratedColumn<String> vaccineSecondDoseDate =
      GeneratedColumn<String>(
        'vaccine_second_dose_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    classId,
    sectionId,
    admissionNumber,
    rollNumber,
    fullName,
    fatherOrGuardianName,
    gender,
    dateOfBirth,
    admissionDate,
    status,
    qrToken,
    photoUrl,
    studentCnic,
    fatherCnic,
    isVaccinated,
    vaccineFirstDoseDate,
    vaccineSecondDoseDate,
    isDeleted,
    createdAt,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('admission_number')) {
      context.handle(
        _admissionNumberMeta,
        admissionNumber.isAcceptableOrUnknown(
          data['admission_number']!,
          _admissionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_admissionNumberMeta);
    }
    if (data.containsKey('roll_number')) {
      context.handle(
        _rollNumberMeta,
        rollNumber.isAcceptableOrUnknown(data['roll_number']!, _rollNumberMeta),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('father_or_guardian_name')) {
      context.handle(
        _fatherOrGuardianNameMeta,
        fatherOrGuardianName.isAcceptableOrUnknown(
          data['father_or_guardian_name']!,
          _fatherOrGuardianNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fatherOrGuardianNameMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('admission_date')) {
      context.handle(
        _admissionDateMeta,
        admissionDate.isAcceptableOrUnknown(
          data['admission_date']!,
          _admissionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_admissionDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('qr_token')) {
      context.handle(
        _qrTokenMeta,
        qrToken.isAcceptableOrUnknown(data['qr_token']!, _qrTokenMeta),
      );
    } else if (isInserting) {
      context.missing(_qrTokenMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('student_cnic')) {
      context.handle(
        _studentCnicMeta,
        studentCnic.isAcceptableOrUnknown(
          data['student_cnic']!,
          _studentCnicMeta,
        ),
      );
    }
    if (data.containsKey('father_cnic')) {
      context.handle(
        _fatherCnicMeta,
        fatherCnic.isAcceptableOrUnknown(data['father_cnic']!, _fatherCnicMeta),
      );
    }
    if (data.containsKey('is_vaccinated')) {
      context.handle(
        _isVaccinatedMeta,
        isVaccinated.isAcceptableOrUnknown(
          data['is_vaccinated']!,
          _isVaccinatedMeta,
        ),
      );
    }
    if (data.containsKey('vaccine_first_dose_date')) {
      context.handle(
        _vaccineFirstDoseDateMeta,
        vaccineFirstDoseDate.isAcceptableOrUnknown(
          data['vaccine_first_dose_date']!,
          _vaccineFirstDoseDateMeta,
        ),
      );
    }
    if (data.containsKey('vaccine_second_dose_date')) {
      context.handle(
        _vaccineSecondDoseDateMeta,
        vaccineSecondDoseDate.isAcceptableOrUnknown(
          data['vaccine_second_dose_date']!,
          _vaccineSecondDoseDateMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
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
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      admissionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}admission_number'],
      )!,
      rollNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}roll_number'],
      ),
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      fatherOrGuardianName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_or_guardian_name'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_of_birth'],
      ),
      admissionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}admission_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      qrToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qr_token'],
      )!,
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      studentCnic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_cnic'],
      ),
      fatherCnic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_cnic'],
      ),
      isVaccinated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_vaccinated'],
      )!,
      vaccineFirstDoseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vaccine_first_dose_date'],
      ),
      vaccineSecondDoseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vaccine_second_dose_date'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final String id;
  final String schoolId;
  final String classId;
  final String sectionId;
  final String admissionNumber;
  final String? rollNumber;
  final String fullName;
  final String fatherOrGuardianName;
  final String gender;
  final String? dateOfBirth;
  final String admissionDate;
  final String status;
  final String qrToken;
  final String? photoUrl;
  final String? studentCnic;
  final String? fatherCnic;
  final bool isVaccinated;
  final String? vaccineFirstDoseDate;
  final String? vaccineSecondDoseDate;
  final bool isDeleted;
  final int createdAt;
  final int updatedAt;
  final int revision;
  const Student({
    required this.id,
    required this.schoolId,
    required this.classId,
    required this.sectionId,
    required this.admissionNumber,
    this.rollNumber,
    required this.fullName,
    required this.fatherOrGuardianName,
    required this.gender,
    this.dateOfBirth,
    required this.admissionDate,
    required this.status,
    required this.qrToken,
    this.photoUrl,
    this.studentCnic,
    this.fatherCnic,
    required this.isVaccinated,
    this.vaccineFirstDoseDate,
    this.vaccineSecondDoseDate,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['class_id'] = Variable<String>(classId);
    map['section_id'] = Variable<String>(sectionId);
    map['admission_number'] = Variable<String>(admissionNumber);
    if (!nullToAbsent || rollNumber != null) {
      map['roll_number'] = Variable<String>(rollNumber);
    }
    map['full_name'] = Variable<String>(fullName);
    map['father_or_guardian_name'] = Variable<String>(fatherOrGuardianName);
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<String>(dateOfBirth);
    }
    map['admission_date'] = Variable<String>(admissionDate);
    map['status'] = Variable<String>(status);
    map['qr_token'] = Variable<String>(qrToken);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || studentCnic != null) {
      map['student_cnic'] = Variable<String>(studentCnic);
    }
    if (!nullToAbsent || fatherCnic != null) {
      map['father_cnic'] = Variable<String>(fatherCnic);
    }
    map['is_vaccinated'] = Variable<bool>(isVaccinated);
    if (!nullToAbsent || vaccineFirstDoseDate != null) {
      map['vaccine_first_dose_date'] = Variable<String>(vaccineFirstDoseDate);
    }
    if (!nullToAbsent || vaccineSecondDoseDate != null) {
      map['vaccine_second_dose_date'] = Variable<String>(vaccineSecondDoseDate);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      classId: Value(classId),
      sectionId: Value(sectionId),
      admissionNumber: Value(admissionNumber),
      rollNumber: rollNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(rollNumber),
      fullName: Value(fullName),
      fatherOrGuardianName: Value(fatherOrGuardianName),
      gender: Value(gender),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      admissionDate: Value(admissionDate),
      status: Value(status),
      qrToken: Value(qrToken),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      studentCnic: studentCnic == null && nullToAbsent
          ? const Value.absent()
          : Value(studentCnic),
      fatherCnic: fatherCnic == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherCnic),
      isVaccinated: Value(isVaccinated),
      vaccineFirstDoseDate: vaccineFirstDoseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(vaccineFirstDoseDate),
      vaccineSecondDoseDate: vaccineSecondDoseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(vaccineSecondDoseDate),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      classId: serializer.fromJson<String>(json['classId']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      admissionNumber: serializer.fromJson<String>(json['admissionNumber']),
      rollNumber: serializer.fromJson<String?>(json['rollNumber']),
      fullName: serializer.fromJson<String>(json['fullName']),
      fatherOrGuardianName: serializer.fromJson<String>(
        json['fatherOrGuardianName'],
      ),
      gender: serializer.fromJson<String>(json['gender']),
      dateOfBirth: serializer.fromJson<String?>(json['dateOfBirth']),
      admissionDate: serializer.fromJson<String>(json['admissionDate']),
      status: serializer.fromJson<String>(json['status']),
      qrToken: serializer.fromJson<String>(json['qrToken']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      studentCnic: serializer.fromJson<String?>(json['studentCnic']),
      fatherCnic: serializer.fromJson<String?>(json['fatherCnic']),
      isVaccinated: serializer.fromJson<bool>(json['isVaccinated']),
      vaccineFirstDoseDate: serializer.fromJson<String?>(
        json['vaccineFirstDoseDate'],
      ),
      vaccineSecondDoseDate: serializer.fromJson<String?>(
        json['vaccineSecondDoseDate'],
      ),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'classId': serializer.toJson<String>(classId),
      'sectionId': serializer.toJson<String>(sectionId),
      'admissionNumber': serializer.toJson<String>(admissionNumber),
      'rollNumber': serializer.toJson<String?>(rollNumber),
      'fullName': serializer.toJson<String>(fullName),
      'fatherOrGuardianName': serializer.toJson<String>(fatherOrGuardianName),
      'gender': serializer.toJson<String>(gender),
      'dateOfBirth': serializer.toJson<String?>(dateOfBirth),
      'admissionDate': serializer.toJson<String>(admissionDate),
      'status': serializer.toJson<String>(status),
      'qrToken': serializer.toJson<String>(qrToken),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'studentCnic': serializer.toJson<String?>(studentCnic),
      'fatherCnic': serializer.toJson<String?>(fatherCnic),
      'isVaccinated': serializer.toJson<bool>(isVaccinated),
      'vaccineFirstDoseDate': serializer.toJson<String?>(vaccineFirstDoseDate),
      'vaccineSecondDoseDate': serializer.toJson<String?>(
        vaccineSecondDoseDate,
      ),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  Student copyWith({
    String? id,
    String? schoolId,
    String? classId,
    String? sectionId,
    String? admissionNumber,
    Value<String?> rollNumber = const Value.absent(),
    String? fullName,
    String? fatherOrGuardianName,
    String? gender,
    Value<String?> dateOfBirth = const Value.absent(),
    String? admissionDate,
    String? status,
    String? qrToken,
    Value<String?> photoUrl = const Value.absent(),
    Value<String?> studentCnic = const Value.absent(),
    Value<String?> fatherCnic = const Value.absent(),
    bool? isVaccinated,
    Value<String?> vaccineFirstDoseDate = const Value.absent(),
    Value<String?> vaccineSecondDoseDate = const Value.absent(),
    bool? isDeleted,
    int? createdAt,
    int? updatedAt,
    int? revision,
  }) => Student(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    classId: classId ?? this.classId,
    sectionId: sectionId ?? this.sectionId,
    admissionNumber: admissionNumber ?? this.admissionNumber,
    rollNumber: rollNumber.present ? rollNumber.value : this.rollNumber,
    fullName: fullName ?? this.fullName,
    fatherOrGuardianName: fatherOrGuardianName ?? this.fatherOrGuardianName,
    gender: gender ?? this.gender,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    admissionDate: admissionDate ?? this.admissionDate,
    status: status ?? this.status,
    qrToken: qrToken ?? this.qrToken,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    studentCnic: studentCnic.present ? studentCnic.value : this.studentCnic,
    fatherCnic: fatherCnic.present ? fatherCnic.value : this.fatherCnic,
    isVaccinated: isVaccinated ?? this.isVaccinated,
    vaccineFirstDoseDate: vaccineFirstDoseDate.present
        ? vaccineFirstDoseDate.value
        : this.vaccineFirstDoseDate,
    vaccineSecondDoseDate: vaccineSecondDoseDate.present
        ? vaccineSecondDoseDate.value
        : this.vaccineSecondDoseDate,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      classId: data.classId.present ? data.classId.value : this.classId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      admissionNumber: data.admissionNumber.present
          ? data.admissionNumber.value
          : this.admissionNumber,
      rollNumber: data.rollNumber.present
          ? data.rollNumber.value
          : this.rollNumber,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      fatherOrGuardianName: data.fatherOrGuardianName.present
          ? data.fatherOrGuardianName.value
          : this.fatherOrGuardianName,
      gender: data.gender.present ? data.gender.value : this.gender,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      admissionDate: data.admissionDate.present
          ? data.admissionDate.value
          : this.admissionDate,
      status: data.status.present ? data.status.value : this.status,
      qrToken: data.qrToken.present ? data.qrToken.value : this.qrToken,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      studentCnic: data.studentCnic.present
          ? data.studentCnic.value
          : this.studentCnic,
      fatherCnic: data.fatherCnic.present
          ? data.fatherCnic.value
          : this.fatherCnic,
      isVaccinated: data.isVaccinated.present
          ? data.isVaccinated.value
          : this.isVaccinated,
      vaccineFirstDoseDate: data.vaccineFirstDoseDate.present
          ? data.vaccineFirstDoseDate.value
          : this.vaccineFirstDoseDate,
      vaccineSecondDoseDate: data.vaccineSecondDoseDate.present
          ? data.vaccineSecondDoseDate.value
          : this.vaccineSecondDoseDate,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('classId: $classId, ')
          ..write('sectionId: $sectionId, ')
          ..write('admissionNumber: $admissionNumber, ')
          ..write('rollNumber: $rollNumber, ')
          ..write('fullName: $fullName, ')
          ..write('fatherOrGuardianName: $fatherOrGuardianName, ')
          ..write('gender: $gender, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('admissionDate: $admissionDate, ')
          ..write('status: $status, ')
          ..write('qrToken: $qrToken, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('studentCnic: $studentCnic, ')
          ..write('fatherCnic: $fatherCnic, ')
          ..write('isVaccinated: $isVaccinated, ')
          ..write('vaccineFirstDoseDate: $vaccineFirstDoseDate, ')
          ..write('vaccineSecondDoseDate: $vaccineSecondDoseDate, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    schoolId,
    classId,
    sectionId,
    admissionNumber,
    rollNumber,
    fullName,
    fatherOrGuardianName,
    gender,
    dateOfBirth,
    admissionDate,
    status,
    qrToken,
    photoUrl,
    studentCnic,
    fatherCnic,
    isVaccinated,
    vaccineFirstDoseDate,
    vaccineSecondDoseDate,
    isDeleted,
    createdAt,
    updatedAt,
    revision,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.classId == this.classId &&
          other.sectionId == this.sectionId &&
          other.admissionNumber == this.admissionNumber &&
          other.rollNumber == this.rollNumber &&
          other.fullName == this.fullName &&
          other.fatherOrGuardianName == this.fatherOrGuardianName &&
          other.gender == this.gender &&
          other.dateOfBirth == this.dateOfBirth &&
          other.admissionDate == this.admissionDate &&
          other.status == this.status &&
          other.qrToken == this.qrToken &&
          other.photoUrl == this.photoUrl &&
          other.studentCnic == this.studentCnic &&
          other.fatherCnic == this.fatherCnic &&
          other.isVaccinated == this.isVaccinated &&
          other.vaccineFirstDoseDate == this.vaccineFirstDoseDate &&
          other.vaccineSecondDoseDate == this.vaccineSecondDoseDate &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> classId;
  final Value<String> sectionId;
  final Value<String> admissionNumber;
  final Value<String?> rollNumber;
  final Value<String> fullName;
  final Value<String> fatherOrGuardianName;
  final Value<String> gender;
  final Value<String?> dateOfBirth;
  final Value<String> admissionDate;
  final Value<String> status;
  final Value<String> qrToken;
  final Value<String?> photoUrl;
  final Value<String?> studentCnic;
  final Value<String?> fatherCnic;
  final Value<bool> isVaccinated;
  final Value<String?> vaccineFirstDoseDate;
  final Value<String?> vaccineSecondDoseDate;
  final Value<bool> isDeleted;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.classId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.admissionNumber = const Value.absent(),
    this.rollNumber = const Value.absent(),
    this.fullName = const Value.absent(),
    this.fatherOrGuardianName = const Value.absent(),
    this.gender = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.admissionDate = const Value.absent(),
    this.status = const Value.absent(),
    this.qrToken = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.studentCnic = const Value.absent(),
    this.fatherCnic = const Value.absent(),
    this.isVaccinated = const Value.absent(),
    this.vaccineFirstDoseDate = const Value.absent(),
    this.vaccineSecondDoseDate = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentsCompanion.insert({
    required String id,
    required String schoolId,
    required String classId,
    required String sectionId,
    required String admissionNumber,
    this.rollNumber = const Value.absent(),
    required String fullName,
    required String fatherOrGuardianName,
    required String gender,
    this.dateOfBirth = const Value.absent(),
    required String admissionDate,
    this.status = const Value.absent(),
    required String qrToken,
    this.photoUrl = const Value.absent(),
    this.studentCnic = const Value.absent(),
    this.fatherCnic = const Value.absent(),
    this.isVaccinated = const Value.absent(),
    this.vaccineFirstDoseDate = const Value.absent(),
    this.vaccineSecondDoseDate = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       classId = Value(classId),
       sectionId = Value(sectionId),
       admissionNumber = Value(admissionNumber),
       fullName = Value(fullName),
       fatherOrGuardianName = Value(fatherOrGuardianName),
       gender = Value(gender),
       admissionDate = Value(admissionDate),
       qrToken = Value(qrToken),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Student> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? classId,
    Expression<String>? sectionId,
    Expression<String>? admissionNumber,
    Expression<String>? rollNumber,
    Expression<String>? fullName,
    Expression<String>? fatherOrGuardianName,
    Expression<String>? gender,
    Expression<String>? dateOfBirth,
    Expression<String>? admissionDate,
    Expression<String>? status,
    Expression<String>? qrToken,
    Expression<String>? photoUrl,
    Expression<String>? studentCnic,
    Expression<String>? fatherCnic,
    Expression<bool>? isVaccinated,
    Expression<String>? vaccineFirstDoseDate,
    Expression<String>? vaccineSecondDoseDate,
    Expression<bool>? isDeleted,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (classId != null) 'class_id': classId,
      if (sectionId != null) 'section_id': sectionId,
      if (admissionNumber != null) 'admission_number': admissionNumber,
      if (rollNumber != null) 'roll_number': rollNumber,
      if (fullName != null) 'full_name': fullName,
      if (fatherOrGuardianName != null)
        'father_or_guardian_name': fatherOrGuardianName,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (admissionDate != null) 'admission_date': admissionDate,
      if (status != null) 'status': status,
      if (qrToken != null) 'qr_token': qrToken,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (studentCnic != null) 'student_cnic': studentCnic,
      if (fatherCnic != null) 'father_cnic': fatherCnic,
      if (isVaccinated != null) 'is_vaccinated': isVaccinated,
      if (vaccineFirstDoseDate != null)
        'vaccine_first_dose_date': vaccineFirstDoseDate,
      if (vaccineSecondDoseDate != null)
        'vaccine_second_dose_date': vaccineSecondDoseDate,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? classId,
    Value<String>? sectionId,
    Value<String>? admissionNumber,
    Value<String?>? rollNumber,
    Value<String>? fullName,
    Value<String>? fatherOrGuardianName,
    Value<String>? gender,
    Value<String?>? dateOfBirth,
    Value<String>? admissionDate,
    Value<String>? status,
    Value<String>? qrToken,
    Value<String?>? photoUrl,
    Value<String?>? studentCnic,
    Value<String?>? fatherCnic,
    Value<bool>? isVaccinated,
    Value<String?>? vaccineFirstDoseDate,
    Value<String?>? vaccineSecondDoseDate,
    Value<bool>? isDeleted,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      classId: classId ?? this.classId,
      sectionId: sectionId ?? this.sectionId,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      rollNumber: rollNumber ?? this.rollNumber,
      fullName: fullName ?? this.fullName,
      fatherOrGuardianName: fatherOrGuardianName ?? this.fatherOrGuardianName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      admissionDate: admissionDate ?? this.admissionDate,
      status: status ?? this.status,
      qrToken: qrToken ?? this.qrToken,
      photoUrl: photoUrl ?? this.photoUrl,
      studentCnic: studentCnic ?? this.studentCnic,
      fatherCnic: fatherCnic ?? this.fatherCnic,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      vaccineFirstDoseDate: vaccineFirstDoseDate ?? this.vaccineFirstDoseDate,
      vaccineSecondDoseDate:
          vaccineSecondDoseDate ?? this.vaccineSecondDoseDate,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (admissionNumber.present) {
      map['admission_number'] = Variable<String>(admissionNumber.value);
    }
    if (rollNumber.present) {
      map['roll_number'] = Variable<String>(rollNumber.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (fatherOrGuardianName.present) {
      map['father_or_guardian_name'] = Variable<String>(
        fatherOrGuardianName.value,
      );
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<String>(dateOfBirth.value);
    }
    if (admissionDate.present) {
      map['admission_date'] = Variable<String>(admissionDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (qrToken.present) {
      map['qr_token'] = Variable<String>(qrToken.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (studentCnic.present) {
      map['student_cnic'] = Variable<String>(studentCnic.value);
    }
    if (fatherCnic.present) {
      map['father_cnic'] = Variable<String>(fatherCnic.value);
    }
    if (isVaccinated.present) {
      map['is_vaccinated'] = Variable<bool>(isVaccinated.value);
    }
    if (vaccineFirstDoseDate.present) {
      map['vaccine_first_dose_date'] = Variable<String>(
        vaccineFirstDoseDate.value,
      );
    }
    if (vaccineSecondDoseDate.present) {
      map['vaccine_second_dose_date'] = Variable<String>(
        vaccineSecondDoseDate.value,
      );
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
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
          ..write('schoolId: $schoolId, ')
          ..write('classId: $classId, ')
          ..write('sectionId: $sectionId, ')
          ..write('admissionNumber: $admissionNumber, ')
          ..write('rollNumber: $rollNumber, ')
          ..write('fullName: $fullName, ')
          ..write('fatherOrGuardianName: $fatherOrGuardianName, ')
          ..write('gender: $gender, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('admissionDate: $admissionDate, ')
          ..write('status: $status, ')
          ..write('qrToken: $qrToken, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('studentCnic: $studentCnic, ')
          ..write('fatherCnic: $fatherCnic, ')
          ..write('isVaccinated: $isVaccinated, ')
          ..write('vaccineFirstDoseDate: $vaccineFirstDoseDate, ')
          ..write('vaccineSecondDoseDate: $vaccineSecondDoseDate, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParentContactsTable extends ParentContacts
    with TableInfo<$ParentContactsTable, ParentContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParentContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  @override
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whatsappEnabledMeta = const VerificationMeta(
    'whatsappEnabled',
  );
  @override
  late final GeneratedColumn<bool> whatsappEnabled = GeneratedColumn<bool>(
    'whatsapp_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("whatsapp_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifyAbsentMeta = const VerificationMeta(
    'notifyAbsent',
  );
  @override
  late final GeneratedColumn<bool> notifyAbsent = GeneratedColumn<bool>(
    'notify_absent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_absent" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifyLateMeta = const VerificationMeta(
    'notifyLate',
  );
  @override
  late final GeneratedColumn<bool> notifyLate = GeneratedColumn<bool>(
    'notify_late',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_late" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifyLeaveMeta = const VerificationMeta(
    'notifyLeave',
  );
  @override
  late final GeneratedColumn<bool> notifyLeave = GeneratedColumn<bool>(
    'notify_leave',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_leave" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    relation,
    phoneNumber,
    whatsappEnabled,
    notifyAbsent,
    notifyLate,
    notifyLeave,
    createdAt,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parent_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParentContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    } else if (isInserting) {
      context.missing(_relationMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('whatsapp_enabled')) {
      context.handle(
        _whatsappEnabledMeta,
        whatsappEnabled.isAcceptableOrUnknown(
          data['whatsapp_enabled']!,
          _whatsappEnabledMeta,
        ),
      );
    }
    if (data.containsKey('notify_absent')) {
      context.handle(
        _notifyAbsentMeta,
        notifyAbsent.isAcceptableOrUnknown(
          data['notify_absent']!,
          _notifyAbsentMeta,
        ),
      );
    }
    if (data.containsKey('notify_late')) {
      context.handle(
        _notifyLateMeta,
        notifyLate.isAcceptableOrUnknown(data['notify_late']!, _notifyLateMeta),
      );
    }
    if (data.containsKey('notify_leave')) {
      context.handle(
        _notifyLeaveMeta,
        notifyLeave.isAcceptableOrUnknown(
          data['notify_leave']!,
          _notifyLeaveMeta,
        ),
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
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParentContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParentContact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      whatsappEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}whatsapp_enabled'],
      )!,
      notifyAbsent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_absent'],
      )!,
      notifyLate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_late'],
      )!,
      notifyLeave: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_leave'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $ParentContactsTable createAlias(String alias) {
    return $ParentContactsTable(attachedDatabase, alias);
  }
}

class ParentContact extends DataClass implements Insertable<ParentContact> {
  final String id;
  final String studentId;
  final String relation;
  final String phoneNumber;
  final bool whatsappEnabled;
  final bool notifyAbsent;
  final bool notifyLate;
  final bool notifyLeave;
  final int createdAt;
  final int updatedAt;
  final int revision;
  const ParentContact({
    required this.id,
    required this.studentId,
    required this.relation,
    required this.phoneNumber,
    required this.whatsappEnabled,
    required this.notifyAbsent,
    required this.notifyLate,
    required this.notifyLeave,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['relation'] = Variable<String>(relation);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['whatsapp_enabled'] = Variable<bool>(whatsappEnabled);
    map['notify_absent'] = Variable<bool>(notifyAbsent);
    map['notify_late'] = Variable<bool>(notifyLate);
    map['notify_leave'] = Variable<bool>(notifyLeave);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  ParentContactsCompanion toCompanion(bool nullToAbsent) {
    return ParentContactsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      relation: Value(relation),
      phoneNumber: Value(phoneNumber),
      whatsappEnabled: Value(whatsappEnabled),
      notifyAbsent: Value(notifyAbsent),
      notifyLate: Value(notifyLate),
      notifyLeave: Value(notifyLeave),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory ParentContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParentContact(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      relation: serializer.fromJson<String>(json['relation']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      whatsappEnabled: serializer.fromJson<bool>(json['whatsappEnabled']),
      notifyAbsent: serializer.fromJson<bool>(json['notifyAbsent']),
      notifyLate: serializer.fromJson<bool>(json['notifyLate']),
      notifyLeave: serializer.fromJson<bool>(json['notifyLeave']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'relation': serializer.toJson<String>(relation),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'whatsappEnabled': serializer.toJson<bool>(whatsappEnabled),
      'notifyAbsent': serializer.toJson<bool>(notifyAbsent),
      'notifyLate': serializer.toJson<bool>(notifyLate),
      'notifyLeave': serializer.toJson<bool>(notifyLeave),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  ParentContact copyWith({
    String? id,
    String? studentId,
    String? relation,
    String? phoneNumber,
    bool? whatsappEnabled,
    bool? notifyAbsent,
    bool? notifyLate,
    bool? notifyLeave,
    int? createdAt,
    int? updatedAt,
    int? revision,
  }) => ParentContact(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    relation: relation ?? this.relation,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
    notifyAbsent: notifyAbsent ?? this.notifyAbsent,
    notifyLate: notifyLate ?? this.notifyLate,
    notifyLeave: notifyLeave ?? this.notifyLeave,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  ParentContact copyWithCompanion(ParentContactsCompanion data) {
    return ParentContact(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      relation: data.relation.present ? data.relation.value : this.relation,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      whatsappEnabled: data.whatsappEnabled.present
          ? data.whatsappEnabled.value
          : this.whatsappEnabled,
      notifyAbsent: data.notifyAbsent.present
          ? data.notifyAbsent.value
          : this.notifyAbsent,
      notifyLate: data.notifyLate.present
          ? data.notifyLate.value
          : this.notifyLate,
      notifyLeave: data.notifyLeave.present
          ? data.notifyLeave.value
          : this.notifyLeave,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParentContact(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('relation: $relation, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('whatsappEnabled: $whatsappEnabled, ')
          ..write('notifyAbsent: $notifyAbsent, ')
          ..write('notifyLate: $notifyLate, ')
          ..write('notifyLeave: $notifyLeave, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    relation,
    phoneNumber,
    whatsappEnabled,
    notifyAbsent,
    notifyLate,
    notifyLeave,
    createdAt,
    updatedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParentContact &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.relation == this.relation &&
          other.phoneNumber == this.phoneNumber &&
          other.whatsappEnabled == this.whatsappEnabled &&
          other.notifyAbsent == this.notifyAbsent &&
          other.notifyLate == this.notifyLate &&
          other.notifyLeave == this.notifyLeave &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class ParentContactsCompanion extends UpdateCompanion<ParentContact> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> relation;
  final Value<String> phoneNumber;
  final Value<bool> whatsappEnabled;
  final Value<bool> notifyAbsent;
  final Value<bool> notifyLate;
  final Value<bool> notifyLeave;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const ParentContactsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.relation = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.whatsappEnabled = const Value.absent(),
    this.notifyAbsent = const Value.absent(),
    this.notifyLate = const Value.absent(),
    this.notifyLeave = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParentContactsCompanion.insert({
    required String id,
    required String studentId,
    required String relation,
    required String phoneNumber,
    this.whatsappEnabled = const Value.absent(),
    this.notifyAbsent = const Value.absent(),
    this.notifyLate = const Value.absent(),
    this.notifyLeave = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       relation = Value(relation),
       phoneNumber = Value(phoneNumber),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ParentContact> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? relation,
    Expression<String>? phoneNumber,
    Expression<bool>? whatsappEnabled,
    Expression<bool>? notifyAbsent,
    Expression<bool>? notifyLate,
    Expression<bool>? notifyLeave,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (relation != null) 'relation': relation,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (whatsappEnabled != null) 'whatsapp_enabled': whatsappEnabled,
      if (notifyAbsent != null) 'notify_absent': notifyAbsent,
      if (notifyLate != null) 'notify_late': notifyLate,
      if (notifyLeave != null) 'notify_leave': notifyLeave,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParentContactsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? relation,
    Value<String>? phoneNumber,
    Value<bool>? whatsappEnabled,
    Value<bool>? notifyAbsent,
    Value<bool>? notifyLate,
    Value<bool>? notifyLeave,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return ParentContactsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      relation: relation ?? this.relation,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      notifyAbsent: notifyAbsent ?? this.notifyAbsent,
      notifyLate: notifyLate ?? this.notifyLate,
      notifyLeave: notifyLeave ?? this.notifyLeave,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
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
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (whatsappEnabled.present) {
      map['whatsapp_enabled'] = Variable<bool>(whatsappEnabled.value);
    }
    if (notifyAbsent.present) {
      map['notify_absent'] = Variable<bool>(notifyAbsent.value);
    }
    if (notifyLate.present) {
      map['notify_late'] = Variable<bool>(notifyLate.value);
    }
    if (notifyLeave.present) {
      map['notify_leave'] = Variable<bool>(notifyLeave.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParentContactsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('relation: $relation, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('whatsappEnabled: $whatsappEnabled, ')
          ..write('notifyAbsent: $notifyAbsent, ')
          ..write('notifyLate: $notifyLate, ')
          ..write('notifyLeave: $notifyLeave, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SchoolCalendarHolidaysTable extends SchoolCalendarHolidays
    with TableInfo<$SchoolCalendarHolidaysTable, SchoolCalendarHoliday> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchoolCalendarHolidaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isInstructionalDayMeta =
      const VerificationMeta('isInstructionalDay');
  @override
  late final GeneratedColumn<bool> isInstructionalDay = GeneratedColumn<bool>(
    'is_instructional_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_instructional_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    date,
    description,
    isInstructionalDay,
    createdAt,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'school_calendar_holidays';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchoolCalendarHoliday> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('is_instructional_day')) {
      context.handle(
        _isInstructionalDayMeta,
        isInstructionalDay.isAcceptableOrUnknown(
          data['is_instructional_day']!,
          _isInstructionalDayMeta,
        ),
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
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SchoolCalendarHoliday map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchoolCalendarHoliday(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      isInstructionalDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_instructional_day'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $SchoolCalendarHolidaysTable createAlias(String alias) {
    return $SchoolCalendarHolidaysTable(attachedDatabase, alias);
  }
}

class SchoolCalendarHoliday extends DataClass
    implements Insertable<SchoolCalendarHoliday> {
  final String id;
  final String schoolId;
  final String date;
  final String description;
  final bool isInstructionalDay;
  final int createdAt;
  final int updatedAt;
  final int revision;
  const SchoolCalendarHoliday({
    required this.id,
    required this.schoolId,
    required this.date,
    required this.description,
    required this.isInstructionalDay,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['date'] = Variable<String>(date);
    map['description'] = Variable<String>(description);
    map['is_instructional_day'] = Variable<bool>(isInstructionalDay);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  SchoolCalendarHolidaysCompanion toCompanion(bool nullToAbsent) {
    return SchoolCalendarHolidaysCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      date: Value(date),
      description: Value(description),
      isInstructionalDay: Value(isInstructionalDay),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory SchoolCalendarHoliday.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchoolCalendarHoliday(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      date: serializer.fromJson<String>(json['date']),
      description: serializer.fromJson<String>(json['description']),
      isInstructionalDay: serializer.fromJson<bool>(json['isInstructionalDay']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'date': serializer.toJson<String>(date),
      'description': serializer.toJson<String>(description),
      'isInstructionalDay': serializer.toJson<bool>(isInstructionalDay),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  SchoolCalendarHoliday copyWith({
    String? id,
    String? schoolId,
    String? date,
    String? description,
    bool? isInstructionalDay,
    int? createdAt,
    int? updatedAt,
    int? revision,
  }) => SchoolCalendarHoliday(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    date: date ?? this.date,
    description: description ?? this.description,
    isInstructionalDay: isInstructionalDay ?? this.isInstructionalDay,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  SchoolCalendarHoliday copyWithCompanion(
    SchoolCalendarHolidaysCompanion data,
  ) {
    return SchoolCalendarHoliday(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      date: data.date.present ? data.date.value : this.date,
      description: data.description.present
          ? data.description.value
          : this.description,
      isInstructionalDay: data.isInstructionalDay.present
          ? data.isInstructionalDay.value
          : this.isInstructionalDay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchoolCalendarHoliday(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('isInstructionalDay: $isInstructionalDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    date,
    description,
    isInstructionalDay,
    createdAt,
    updatedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchoolCalendarHoliday &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.date == this.date &&
          other.description == this.description &&
          other.isInstructionalDay == this.isInstructionalDay &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class SchoolCalendarHolidaysCompanion
    extends UpdateCompanion<SchoolCalendarHoliday> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> date;
  final Value<String> description;
  final Value<bool> isInstructionalDay;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const SchoolCalendarHolidaysCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.isInstructionalDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchoolCalendarHolidaysCompanion.insert({
    required String id,
    required String schoolId,
    required String date,
    required String description,
    this.isInstructionalDay = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       date = Value(date),
       description = Value(description),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SchoolCalendarHoliday> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? date,
    Expression<String>? description,
    Expression<bool>? isInstructionalDay,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (isInstructionalDay != null)
        'is_instructional_day': isInstructionalDay,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchoolCalendarHolidaysCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? date,
    Value<String>? description,
    Value<bool>? isInstructionalDay,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return SchoolCalendarHolidaysCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      date: date ?? this.date,
      description: description ?? this.description,
      isInstructionalDay: isInstructionalDay ?? this.isInstructionalDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isInstructionalDay.present) {
      map['is_instructional_day'] = Variable<bool>(isInstructionalDay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolCalendarHolidaysCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('isInstructionalDay: $isInstructionalDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceRecordsTable extends AttendanceRecords
    with TableInfo<$AttendanceRecordsTable, AttendanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _arrivalTimeMeta = const VerificationMeta(
    'arrivalTime',
  );
  @override
  late final GeneratedColumn<String> arrivalTime = GeneratedColumn<String>(
    'arrival_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _departureTimeMeta = const VerificationMeta(
    'departureTime',
  );
  @override
  late final GeneratedColumn<String> departureTime = GeneratedColumn<String>(
    'departure_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _markedByUserIdMeta = const VerificationMeta(
    'markedByUserId',
  );
  @override
  late final GeneratedColumn<String> markedByUserId = GeneratedColumn<String>(
    'marked_by_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markingMethodMeta = const VerificationMeta(
    'markingMethod',
  );
  @override
  late final GeneratedColumn<String> markingMethod = GeneratedColumn<String>(
    'marking_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    studentId,
    classId,
    sectionId,
    date,
    status,
    arrivalTime,
    departureTime,
    remarks,
    markedByUserId,
    markingMethod,
    idempotencyKey,
    createdAt,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('arrival_time')) {
      context.handle(
        _arrivalTimeMeta,
        arrivalTime.isAcceptableOrUnknown(
          data['arrival_time']!,
          _arrivalTimeMeta,
        ),
      );
    }
    if (data.containsKey('departure_time')) {
      context.handle(
        _departureTimeMeta,
        departureTime.isAcceptableOrUnknown(
          data['departure_time']!,
          _departureTimeMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('marked_by_user_id')) {
      context.handle(
        _markedByUserIdMeta,
        markedByUserId.isAcceptableOrUnknown(
          data['marked_by_user_id']!,
          _markedByUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_markedByUserIdMeta);
    }
    if (data.containsKey('marking_method')) {
      context.handle(
        _markingMethodMeta,
        markingMethod.isAcceptableOrUnknown(
          data['marking_method']!,
          _markingMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_markingMethodMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
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
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {studentId, date},
    {idempotencyKey},
  ];
  @override
  AttendanceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      arrivalTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arrival_time'],
      ),
      departureTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}departure_time'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      markedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marked_by_user_id'],
      )!,
      markingMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marking_method'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $AttendanceRecordsTable createAlias(String alias) {
    return $AttendanceRecordsTable(attachedDatabase, alias);
  }
}

class AttendanceRecord extends DataClass
    implements Insertable<AttendanceRecord> {
  final String id;
  final String schoolId;
  final String studentId;
  final String classId;
  final String sectionId;
  final String date;
  final String status;
  final String? arrivalTime;
  final String? departureTime;
  final String? remarks;
  final String markedByUserId;
  final String markingMethod;
  final String idempotencyKey;
  final int createdAt;
  final int updatedAt;
  final int revision;
  const AttendanceRecord({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.classId,
    required this.sectionId,
    required this.date,
    required this.status,
    this.arrivalTime,
    this.departureTime,
    this.remarks,
    required this.markedByUserId,
    required this.markingMethod,
    required this.idempotencyKey,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    map['class_id'] = Variable<String>(classId);
    map['section_id'] = Variable<String>(sectionId);
    map['date'] = Variable<String>(date);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || arrivalTime != null) {
      map['arrival_time'] = Variable<String>(arrivalTime);
    }
    if (!nullToAbsent || departureTime != null) {
      map['departure_time'] = Variable<String>(departureTime);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['marked_by_user_id'] = Variable<String>(markedByUserId);
    map['marking_method'] = Variable<String>(markingMethod);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  AttendanceRecordsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceRecordsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      classId: Value(classId),
      sectionId: Value(sectionId),
      date: Value(date),
      status: Value(status),
      arrivalTime: arrivalTime == null && nullToAbsent
          ? const Value.absent()
          : Value(arrivalTime),
      departureTime: departureTime == null && nullToAbsent
          ? const Value.absent()
          : Value(departureTime),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      markedByUserId: Value(markedByUserId),
      markingMethod: Value(markingMethod),
      idempotencyKey: Value(idempotencyKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory AttendanceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceRecord(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      classId: serializer.fromJson<String>(json['classId']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      date: serializer.fromJson<String>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      arrivalTime: serializer.fromJson<String?>(json['arrivalTime']),
      departureTime: serializer.fromJson<String?>(json['departureTime']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      markedByUserId: serializer.fromJson<String>(json['markedByUserId']),
      markingMethod: serializer.fromJson<String>(json['markingMethod']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'classId': serializer.toJson<String>(classId),
      'sectionId': serializer.toJson<String>(sectionId),
      'date': serializer.toJson<String>(date),
      'status': serializer.toJson<String>(status),
      'arrivalTime': serializer.toJson<String?>(arrivalTime),
      'departureTime': serializer.toJson<String?>(departureTime),
      'remarks': serializer.toJson<String?>(remarks),
      'markedByUserId': serializer.toJson<String>(markedByUserId),
      'markingMethod': serializer.toJson<String>(markingMethod),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  AttendanceRecord copyWith({
    String? id,
    String? schoolId,
    String? studentId,
    String? classId,
    String? sectionId,
    String? date,
    String? status,
    Value<String?> arrivalTime = const Value.absent(),
    Value<String?> departureTime = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    String? markedByUserId,
    String? markingMethod,
    String? idempotencyKey,
    int? createdAt,
    int? updatedAt,
    int? revision,
  }) => AttendanceRecord(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    classId: classId ?? this.classId,
    sectionId: sectionId ?? this.sectionId,
    date: date ?? this.date,
    status: status ?? this.status,
    arrivalTime: arrivalTime.present ? arrivalTime.value : this.arrivalTime,
    departureTime: departureTime.present
        ? departureTime.value
        : this.departureTime,
    remarks: remarks.present ? remarks.value : this.remarks,
    markedByUserId: markedByUserId ?? this.markedByUserId,
    markingMethod: markingMethod ?? this.markingMethod,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  AttendanceRecord copyWithCompanion(AttendanceRecordsCompanion data) {
    return AttendanceRecord(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      classId: data.classId.present ? data.classId.value : this.classId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      arrivalTime: data.arrivalTime.present
          ? data.arrivalTime.value
          : this.arrivalTime,
      departureTime: data.departureTime.present
          ? data.departureTime.value
          : this.departureTime,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      markedByUserId: data.markedByUserId.present
          ? data.markedByUserId.value
          : this.markedByUserId,
      markingMethod: data.markingMethod.present
          ? data.markingMethod.value
          : this.markingMethod,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecord(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('classId: $classId, ')
          ..write('sectionId: $sectionId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('arrivalTime: $arrivalTime, ')
          ..write('departureTime: $departureTime, ')
          ..write('remarks: $remarks, ')
          ..write('markedByUserId: $markedByUserId, ')
          ..write('markingMethod: $markingMethod, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    studentId,
    classId,
    sectionId,
    date,
    status,
    arrivalTime,
    departureTime,
    remarks,
    markedByUserId,
    markingMethod,
    idempotencyKey,
    createdAt,
    updatedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceRecord &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.classId == this.classId &&
          other.sectionId == this.sectionId &&
          other.date == this.date &&
          other.status == this.status &&
          other.arrivalTime == this.arrivalTime &&
          other.departureTime == this.departureTime &&
          other.remarks == this.remarks &&
          other.markedByUserId == this.markedByUserId &&
          other.markingMethod == this.markingMethod &&
          other.idempotencyKey == this.idempotencyKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class AttendanceRecordsCompanion extends UpdateCompanion<AttendanceRecord> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String> classId;
  final Value<String> sectionId;
  final Value<String> date;
  final Value<String> status;
  final Value<String?> arrivalTime;
  final Value<String?> departureTime;
  final Value<String?> remarks;
  final Value<String> markedByUserId;
  final Value<String> markingMethod;
  final Value<String> idempotencyKey;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const AttendanceRecordsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.classId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.arrivalTime = const Value.absent(),
    this.departureTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.markedByUserId = const Value.absent(),
    this.markingMethod = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceRecordsCompanion.insert({
    required String id,
    required String schoolId,
    required String studentId,
    required String classId,
    required String sectionId,
    required String date,
    required String status,
    this.arrivalTime = const Value.absent(),
    this.departureTime = const Value.absent(),
    this.remarks = const Value.absent(),
    required String markedByUserId,
    required String markingMethod,
    required String idempotencyKey,
    required int createdAt,
    required int updatedAt,
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       studentId = Value(studentId),
       classId = Value(classId),
       sectionId = Value(sectionId),
       date = Value(date),
       status = Value(status),
       markedByUserId = Value(markedByUserId),
       markingMethod = Value(markingMethod),
       idempotencyKey = Value(idempotencyKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AttendanceRecord> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? classId,
    Expression<String>? sectionId,
    Expression<String>? date,
    Expression<String>? status,
    Expression<String>? arrivalTime,
    Expression<String>? departureTime,
    Expression<String>? remarks,
    Expression<String>? markedByUserId,
    Expression<String>? markingMethod,
    Expression<String>? idempotencyKey,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (classId != null) 'class_id': classId,
      if (sectionId != null) 'section_id': sectionId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (arrivalTime != null) 'arrival_time': arrivalTime,
      if (departureTime != null) 'departure_time': departureTime,
      if (remarks != null) 'remarks': remarks,
      if (markedByUserId != null) 'marked_by_user_id': markedByUserId,
      if (markingMethod != null) 'marking_method': markingMethod,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? studentId,
    Value<String>? classId,
    Value<String>? sectionId,
    Value<String>? date,
    Value<String>? status,
    Value<String?>? arrivalTime,
    Value<String?>? departureTime,
    Value<String?>? remarks,
    Value<String>? markedByUserId,
    Value<String>? markingMethod,
    Value<String>? idempotencyKey,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return AttendanceRecordsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      sectionId: sectionId ?? this.sectionId,
      date: date ?? this.date,
      status: status ?? this.status,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      remarks: remarks ?? this.remarks,
      markedByUserId: markedByUserId ?? this.markedByUserId,
      markingMethod: markingMethod ?? this.markingMethod,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (arrivalTime.present) {
      map['arrival_time'] = Variable<String>(arrivalTime.value);
    }
    if (departureTime.present) {
      map['departure_time'] = Variable<String>(departureTime.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (markedByUserId.present) {
      map['marked_by_user_id'] = Variable<String>(markedByUserId.value);
    }
    if (markingMethod.present) {
      map['marking_method'] = Variable<String>(markingMethod.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('classId: $classId, ')
          ..write('sectionId: $sectionId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('arrivalTime: $arrivalTime, ')
          ..write('departureTime: $departureTime, ')
          ..write('remarks: $remarks, ')
          ..write('markedByUserId: $markedByUserId, ')
          ..write('markingMethod: $markingMethod, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceAuditLogsTable extends AttendanceAuditLogs
    with TableInfo<$AttendanceAuditLogsTable, AttendanceAuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceAuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attendanceRecordIdMeta =
      const VerificationMeta('attendanceRecordId');
  @override
  late final GeneratedColumn<String> attendanceRecordId =
      GeneratedColumn<String>(
        'attendance_record_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _changedByUserIdMeta = const VerificationMeta(
    'changedByUserId',
  );
  @override
  late final GeneratedColumn<String> changedByUserId = GeneratedColumn<String>(
    'changed_by_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldStatusMeta = const VerificationMeta(
    'oldStatus',
  );
  @override
  late final GeneratedColumn<String> oldStatus = GeneratedColumn<String>(
    'old_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newStatusMeta = const VerificationMeta(
    'newStatus',
  );
  @override
  late final GeneratedColumn<String> newStatus = GeneratedColumn<String>(
    'new_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attendanceRecordId,
    changedByUserId,
    oldStatus,
    newStatus,
    reason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceAuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('attendance_record_id')) {
      context.handle(
        _attendanceRecordIdMeta,
        attendanceRecordId.isAcceptableOrUnknown(
          data['attendance_record_id']!,
          _attendanceRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attendanceRecordIdMeta);
    }
    if (data.containsKey('changed_by_user_id')) {
      context.handle(
        _changedByUserIdMeta,
        changedByUserId.isAcceptableOrUnknown(
          data['changed_by_user_id']!,
          _changedByUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_changedByUserIdMeta);
    }
    if (data.containsKey('old_status')) {
      context.handle(
        _oldStatusMeta,
        oldStatus.isAcceptableOrUnknown(data['old_status']!, _oldStatusMeta),
      );
    }
    if (data.containsKey('new_status')) {
      context.handle(
        _newStatusMeta,
        newStatus.isAcceptableOrUnknown(data['new_status']!, _newStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_newStatusMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceAuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceAuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      attendanceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendance_record_id'],
      )!,
      changedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}changed_by_user_id'],
      )!,
      oldStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_status'],
      ),
      newStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_status'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttendanceAuditLogsTable createAlias(String alias) {
    return $AttendanceAuditLogsTable(attachedDatabase, alias);
  }
}

class AttendanceAuditLog extends DataClass
    implements Insertable<AttendanceAuditLog> {
  final String id;
  final String attendanceRecordId;
  final String changedByUserId;
  final String? oldStatus;
  final String newStatus;
  final String reason;
  final int createdAt;
  const AttendanceAuditLog({
    required this.id,
    required this.attendanceRecordId,
    required this.changedByUserId,
    this.oldStatus,
    required this.newStatus,
    required this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['attendance_record_id'] = Variable<String>(attendanceRecordId);
    map['changed_by_user_id'] = Variable<String>(changedByUserId);
    if (!nullToAbsent || oldStatus != null) {
      map['old_status'] = Variable<String>(oldStatus);
    }
    map['new_status'] = Variable<String>(newStatus);
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AttendanceAuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceAuditLogsCompanion(
      id: Value(id),
      attendanceRecordId: Value(attendanceRecordId),
      changedByUserId: Value(changedByUserId),
      oldStatus: oldStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(oldStatus),
      newStatus: Value(newStatus),
      reason: Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory AttendanceAuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceAuditLog(
      id: serializer.fromJson<String>(json['id']),
      attendanceRecordId: serializer.fromJson<String>(
        json['attendanceRecordId'],
      ),
      changedByUserId: serializer.fromJson<String>(json['changedByUserId']),
      oldStatus: serializer.fromJson<String?>(json['oldStatus']),
      newStatus: serializer.fromJson<String>(json['newStatus']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'attendanceRecordId': serializer.toJson<String>(attendanceRecordId),
      'changedByUserId': serializer.toJson<String>(changedByUserId),
      'oldStatus': serializer.toJson<String?>(oldStatus),
      'newStatus': serializer.toJson<String>(newStatus),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AttendanceAuditLog copyWith({
    String? id,
    String? attendanceRecordId,
    String? changedByUserId,
    Value<String?> oldStatus = const Value.absent(),
    String? newStatus,
    String? reason,
    int? createdAt,
  }) => AttendanceAuditLog(
    id: id ?? this.id,
    attendanceRecordId: attendanceRecordId ?? this.attendanceRecordId,
    changedByUserId: changedByUserId ?? this.changedByUserId,
    oldStatus: oldStatus.present ? oldStatus.value : this.oldStatus,
    newStatus: newStatus ?? this.newStatus,
    reason: reason ?? this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  AttendanceAuditLog copyWithCompanion(AttendanceAuditLogsCompanion data) {
    return AttendanceAuditLog(
      id: data.id.present ? data.id.value : this.id,
      attendanceRecordId: data.attendanceRecordId.present
          ? data.attendanceRecordId.value
          : this.attendanceRecordId,
      changedByUserId: data.changedByUserId.present
          ? data.changedByUserId.value
          : this.changedByUserId,
      oldStatus: data.oldStatus.present ? data.oldStatus.value : this.oldStatus,
      newStatus: data.newStatus.present ? data.newStatus.value : this.newStatus,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceAuditLog(')
          ..write('id: $id, ')
          ..write('attendanceRecordId: $attendanceRecordId, ')
          ..write('changedByUserId: $changedByUserId, ')
          ..write('oldStatus: $oldStatus, ')
          ..write('newStatus: $newStatus, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    attendanceRecordId,
    changedByUserId,
    oldStatus,
    newStatus,
    reason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceAuditLog &&
          other.id == this.id &&
          other.attendanceRecordId == this.attendanceRecordId &&
          other.changedByUserId == this.changedByUserId &&
          other.oldStatus == this.oldStatus &&
          other.newStatus == this.newStatus &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class AttendanceAuditLogsCompanion extends UpdateCompanion<AttendanceAuditLog> {
  final Value<String> id;
  final Value<String> attendanceRecordId;
  final Value<String> changedByUserId;
  final Value<String?> oldStatus;
  final Value<String> newStatus;
  final Value<String> reason;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AttendanceAuditLogsCompanion({
    this.id = const Value.absent(),
    this.attendanceRecordId = const Value.absent(),
    this.changedByUserId = const Value.absent(),
    this.oldStatus = const Value.absent(),
    this.newStatus = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceAuditLogsCompanion.insert({
    required String id,
    required String attendanceRecordId,
    required String changedByUserId,
    this.oldStatus = const Value.absent(),
    required String newStatus,
    required String reason,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       attendanceRecordId = Value(attendanceRecordId),
       changedByUserId = Value(changedByUserId),
       newStatus = Value(newStatus),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<AttendanceAuditLog> custom({
    Expression<String>? id,
    Expression<String>? attendanceRecordId,
    Expression<String>? changedByUserId,
    Expression<String>? oldStatus,
    Expression<String>? newStatus,
    Expression<String>? reason,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attendanceRecordId != null)
        'attendance_record_id': attendanceRecordId,
      if (changedByUserId != null) 'changed_by_user_id': changedByUserId,
      if (oldStatus != null) 'old_status': oldStatus,
      if (newStatus != null) 'new_status': newStatus,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceAuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? attendanceRecordId,
    Value<String>? changedByUserId,
    Value<String?>? oldStatus,
    Value<String>? newStatus,
    Value<String>? reason,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AttendanceAuditLogsCompanion(
      id: id ?? this.id,
      attendanceRecordId: attendanceRecordId ?? this.attendanceRecordId,
      changedByUserId: changedByUserId ?? this.changedByUserId,
      oldStatus: oldStatus ?? this.oldStatus,
      newStatus: newStatus ?? this.newStatus,
      reason: reason ?? this.reason,
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
    if (attendanceRecordId.present) {
      map['attendance_record_id'] = Variable<String>(attendanceRecordId.value);
    }
    if (changedByUserId.present) {
      map['changed_by_user_id'] = Variable<String>(changedByUserId.value);
    }
    if (oldStatus.present) {
      map['old_status'] = Variable<String>(oldStatus.value);
    }
    if (newStatus.present) {
      map['new_status'] = Variable<String>(newStatus.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
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
    return (StringBuffer('AttendanceAuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('attendanceRecordId: $attendanceRecordId, ')
          ..write('changedByUserId: $changedByUserId, ')
          ..write('oldStatus: $oldStatus, ')
          ..write('newStatus: $newStatus, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _clientRevisionMeta = const VerificationMeta(
    'clientRevision',
  );
  @override
  late final GeneratedColumn<int> clientRevision = GeneratedColumn<int>(
    'client_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    recordId,
    operation,
    payloadJson,
    idempotencyKey,
    clientRevision,
    createdAt,
    retryCount,
    status,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('client_revision')) {
      context.handle(
        _clientRevisionMeta,
        clientRevision.isAcceptableOrUnknown(
          data['client_revision']!,
          _clientRevisionMeta,
        ),
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
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      clientRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String targetTable;
  final String recordId;
  final String operation;
  final String payloadJson;
  final String idempotencyKey;
  final int clientRevision;
  final int createdAt;
  final int retryCount;
  final String status;
  final String? errorMessage;
  const SyncQueueData({
    required this.id,
    required this.targetTable,
    required this.recordId,
    required this.operation,
    required this.payloadJson,
    required this.idempotencyKey,
    required this.clientRevision,
    required this.createdAt,
    required this.retryCount,
    required this.status,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_table'] = Variable<String>(targetTable);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['client_revision'] = Variable<int>(clientRevision);
    map['created_at'] = Variable<int>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      recordId: Value(recordId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      idempotencyKey: Value(idempotencyKey),
      clientRevision: Value(clientRevision),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      clientRevision: serializer.fromJson<int>(json['clientRevision']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'clientRevision': serializer.toJson<int>(clientRevision),
      'createdAt': serializer.toJson<int>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? targetTable,
    String? recordId,
    String? operation,
    String? payloadJson,
    String? idempotencyKey,
    int? clientRevision,
    int? createdAt,
    int? retryCount,
    String? status,
    Value<String?> errorMessage = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    recordId: recordId ?? this.recordId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    clientRevision: clientRevision ?? this.clientRevision,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      clientRevision: data.clientRevision.present
          ? data.clientRevision.value
          : this.clientRevision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('clientRevision: $clientRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetTable,
    recordId,
    operation,
    payloadJson,
    idempotencyKey,
    clientRevision,
    createdAt,
    retryCount,
    status,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.idempotencyKey == this.idempotencyKey &&
          other.clientRevision == this.clientRevision &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> targetTable;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<String> idempotencyKey;
  final Value<int> clientRevision;
  final Value<int> createdAt;
  final Value<int> retryCount;
  final Value<String> status;
  final Value<String?> errorMessage;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String targetTable,
    required String recordId,
    required String operation,
    required String payloadJson,
    required String idempotencyKey,
    this.clientRevision = const Value.absent(),
    required int createdAt,
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : targetTable = Value(targetTable),
       recordId = Value(recordId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       idempotencyKey = Value(idempotencyKey),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? targetTable,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<String>? idempotencyKey,
    Expression<int>? clientRevision,
    Expression<int>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? status,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (clientRevision != null) 'client_revision': clientRevision,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? targetTable,
    Value<String>? recordId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<String>? idempotencyKey,
    Value<int>? clientRevision,
    Value<int>? createdAt,
    Value<int>? retryCount,
    Value<String>? status,
    Value<String?>? errorMessage,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      clientRevision: clientRevision ?? this.clientRevision,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (clientRevision.present) {
      map['client_revision'] = Variable<int>(clientRevision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('clientRevision: $clientRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

class $SchoolSettingsTable extends SchoolSettings
    with TableInfo<$SchoolSettingsTable, SchoolSettingsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchoolSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolTypeMeta = const VerificationMeta(
    'schoolType',
  );
  @override
  late final GeneratedColumn<String> schoolType = GeneratedColumn<String>(
    'school_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GPS'),
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Peshawar'),
  );
  static const VerificationMeta _tehsilMeta = const VerificationMeta('tehsil');
  @override
  late final GeneratedColumn<String> tehsil = GeneratedColumn<String>(
    'tehsil',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('City Peshawar'),
  );
  static const VerificationMeta _circleOfficeMeta = const VerificationMeta(
    'circleOffice',
  );
  @override
  late final GeneratedColumn<String> circleOffice = GeneratedColumn<String>(
    'circle_office',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ASDEO Circle City-I'),
  );
  static const VerificationMeta _unionCouncilMeta = const VerificationMeta(
    'unionCouncil',
  );
  @override
  late final GeneratedColumn<String> unionCouncil = GeneratedColumn<String>(
    'union_council',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UC-12'),
  );
  static const VerificationMeta _climateZoneMeta = const VerificationMeta(
    'climateZone',
  );
  @override
  late final GeneratedColumn<String> climateZone = GeneratedColumn<String>(
    'climate_zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('summer_zone'),
  );
  static const VerificationMeta _openingTimeMeta = const VerificationMeta(
    'openingTime',
  );
  @override
  late final GeneratedColumn<String> openingTime = GeneratedColumn<String>(
    'opening_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('08:00'),
  );
  static const VerificationMeta _closingTimeMeta = const VerificationMeta(
    'closingTime',
  );
  @override
  late final GeneratedColumn<String> closingTime = GeneratedColumn<String>(
    'closing_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('13:30'),
  );
  static const VerificationMeta _lateCutoffTimeMeta = const VerificationMeta(
    'lateCutoffTime',
  );
  @override
  late final GeneratedColumn<String> lateCutoffTime = GeneratedColumn<String>(
    'late_cutoff_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('08:15'),
  );
  static const VerificationMeta _headTeacherNameMeta = const VerificationMeta(
    'headTeacherName',
  );
  @override
  late final GeneratedColumn<String> headTeacherName = GeneratedColumn<String>(
    'head_teacher_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Head Teacher'),
  );
  static const VerificationMeta _deoNameMeta = const VerificationMeta(
    'deoName',
  );
  @override
  late final GeneratedColumn<String> deoName = GeneratedColumn<String>(
    'deo_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DEO Peshawar'),
  );
  static const VerificationMeta _circleSdeoNameMeta = const VerificationMeta(
    'circleSdeoName',
  );
  @override
  late final GeneratedColumn<String> circleSdeoName = GeneratedColumn<String>(
    'circle_sdeo_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _centerInchargeNameMeta =
      const VerificationMeta('centerInchargeName');
  @override
  late final GeneratedColumn<String> centerInchargeName =
      GeneratedColumn<String>(
        'center_incharge_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _goshwaraNoMeta = const VerificationMeta(
    'goshwaraNo',
  );
  @override
  late final GeneratedColumn<String> goshwaraNo = GeneratedColumn<String>(
    'goshwara_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naConstituencyMeta = const VerificationMeta(
    'naConstituency',
  );
  @override
  late final GeneratedColumn<String> naConstituency = GeneratedColumn<String>(
    'na_constituency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pkConstituencyMeta = const VerificationMeta(
    'pkConstituency',
  );
  @override
  late final GeneratedColumn<String> pkConstituency = GeneratedColumn<String>(
    'pk_constituency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ltrcCenterMeta = const VerificationMeta(
    'ltrcCenter',
  );
  @override
  late final GeneratedColumn<String> ltrcCenter = GeneratedColumn<String>(
    'ltrc_center',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sanctionedPostsPshtMeta =
      const VerificationMeta('sanctionedPostsPsht');
  @override
  late final GeneratedColumn<int> sanctionedPostsPsht = GeneratedColumn<int>(
    'sanctioned_posts_psht',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _sanctionedPostsSpstMeta =
      const VerificationMeta('sanctionedPostsSpst');
  @override
  late final GeneratedColumn<int> sanctionedPostsSpst = GeneratedColumn<int>(
    'sanctioned_posts_spst',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _sanctionedPostsPstMeta =
      const VerificationMeta('sanctionedPostsPst');
  @override
  late final GeneratedColumn<int> sanctionedPostsPst = GeneratedColumn<int>(
    'sanctioned_posts_pst',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _vacantPostsPstMeta = const VerificationMeta(
    'vacantPostsPst',
  );
  @override
  late final GeneratedColumn<int> vacantPostsPst = GeneratedColumn<int>(
    'vacant_posts_pst',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vacantPostsChowkidarMeta =
      const VerificationMeta('vacantPostsChowkidar');
  @override
  late final GeneratedColumn<int> vacantPostsChowkidar = GeneratedColumn<int>(
    'vacant_posts_chowkidar',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _classroomsInstructionalMeta =
      const VerificationMeta('classroomsInstructional');
  @override
  late final GeneratedColumn<int> classroomsInstructional =
      GeneratedColumn<int>(
        'classrooms_instructional',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(3),
      );
  static const VerificationMeta _classroomsNonInstructionalMeta =
      const VerificationMeta('classroomsNonInstructional');
  @override
  late final GeneratedColumn<int> classroomsNonInstructional =
      GeneratedColumn<int>(
        'classrooms_non_instructional',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _establishmentYearMeta = const VerificationMeta(
    'establishmentYear',
  );
  @override
  late final GeneratedColumn<String> establishmentYear =
      GeneratedColumn<String>(
        'establishment_year',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _constructionYearMeta = const VerificationMeta(
    'constructionYear',
  );
  @override
  late final GeneratedColumn<String> constructionYear = GeneratedColumn<String>(
    'construction_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _facilityElectricityMeta =
      const VerificationMeta('facilityElectricity');
  @override
  late final GeneratedColumn<int> facilityElectricity = GeneratedColumn<int>(
    'facility_electricity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _facilityWaterPipeMeta = const VerificationMeta(
    'facilityWaterPipe',
  );
  @override
  late final GeneratedColumn<int> facilityWaterPipe = GeneratedColumn<int>(
    'facility_water_pipe',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _facilityWaterWellMeta = const VerificationMeta(
    'facilityWaterWell',
  );
  @override
  late final GeneratedColumn<int> facilityWaterWell = GeneratedColumn<int>(
    'facility_water_well',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _facilitySolarMeta = const VerificationMeta(
    'facilitySolar',
  );
  @override
  late final GeneratedColumn<int> facilitySolar = GeneratedColumn<int>(
    'facility_solar',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _facilityBoundaryWallMeta =
      const VerificationMeta('facilityBoundaryWall');
  @override
  late final GeneratedColumn<int> facilityBoundaryWall = GeneratedColumn<int>(
    'facility_boundary_wall',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _facilityPlayAreaMeta = const VerificationMeta(
    'facilityPlayArea',
  );
  @override
  late final GeneratedColumn<int> facilityPlayArea = GeneratedColumn<int>(
    'facility_play_area',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _facilityOfficeMeta = const VerificationMeta(
    'facilityOffice',
  );
  @override
  late final GeneratedColumn<int> facilityOffice = GeneratedColumn<int>(
    'facility_office',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _facilityToiletCountMeta =
      const VerificationMeta('facilityToiletCount');
  @override
  late final GeneratedColumn<int> facilityToiletCount = GeneratedColumn<int>(
    'facility_toilet_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _ptcChairmanNameMeta = const VerificationMeta(
    'ptcChairmanName',
  );
  @override
  late final GeneratedColumn<String> ptcChairmanName = GeneratedColumn<String>(
    'ptc_chairman_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ptcBankNameMeta = const VerificationMeta(
    'ptcBankName',
  );
  @override
  late final GeneratedColumn<String> ptcBankName = GeneratedColumn<String>(
    'ptc_bank_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ptcAccountNoMeta = const VerificationMeta(
    'ptcAccountNo',
  );
  @override
  late final GeneratedColumn<String> ptcAccountNo = GeneratedColumn<String>(
    'ptc_account_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ptcSanctionDateMeta = const VerificationMeta(
    'ptcSanctionDate',
  );
  @override
  late final GeneratedColumn<String> ptcSanctionDate = GeneratedColumn<String>(
    'ptc_sanction_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fundTotalBudgetMeta = const VerificationMeta(
    'fundTotalBudget',
  );
  @override
  late final GeneratedColumn<double> fundTotalBudget = GeneratedColumn<double>(
    'fund_total_budget',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _fundTotalSpentMeta = const VerificationMeta(
    'fundTotalSpent',
  );
  @override
  late final GeneratedColumn<double> fundTotalSpent = GeneratedColumn<double>(
    'fund_total_spent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _workingDaysCsvMeta = const VerificationMeta(
    'workingDaysCsv',
  );
  @override
  late final GeneratedColumn<String> workingDaysCsv = GeneratedColumn<String>(
    'working_days_csv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1,2,3,4,5,6'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    schoolId,
    schoolType,
    district,
    tehsil,
    circleOffice,
    unionCouncil,
    climateZone,
    openingTime,
    closingTime,
    lateCutoffTime,
    headTeacherName,
    deoName,
    circleSdeoName,
    centerInchargeName,
    goshwaraNo,
    naConstituency,
    pkConstituency,
    ltrcCenter,
    sanctionedPostsPsht,
    sanctionedPostsSpst,
    sanctionedPostsPst,
    vacantPostsPst,
    vacantPostsChowkidar,
    classroomsInstructional,
    classroomsNonInstructional,
    establishmentYear,
    constructionYear,
    facilityElectricity,
    facilityWaterPipe,
    facilityWaterWell,
    facilitySolar,
    facilityBoundaryWall,
    facilityPlayArea,
    facilityOffice,
    facilityToiletCount,
    ptcChairmanName,
    ptcBankName,
    ptcAccountNo,
    ptcSanctionDate,
    fundTotalBudget,
    fundTotalSpent,
    workingDaysCsv,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'school_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchoolSettingsEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('school_type')) {
      context.handle(
        _schoolTypeMeta,
        schoolType.isAcceptableOrUnknown(data['school_type']!, _schoolTypeMeta),
      );
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('tehsil')) {
      context.handle(
        _tehsilMeta,
        tehsil.isAcceptableOrUnknown(data['tehsil']!, _tehsilMeta),
      );
    }
    if (data.containsKey('circle_office')) {
      context.handle(
        _circleOfficeMeta,
        circleOffice.isAcceptableOrUnknown(
          data['circle_office']!,
          _circleOfficeMeta,
        ),
      );
    }
    if (data.containsKey('union_council')) {
      context.handle(
        _unionCouncilMeta,
        unionCouncil.isAcceptableOrUnknown(
          data['union_council']!,
          _unionCouncilMeta,
        ),
      );
    }
    if (data.containsKey('climate_zone')) {
      context.handle(
        _climateZoneMeta,
        climateZone.isAcceptableOrUnknown(
          data['climate_zone']!,
          _climateZoneMeta,
        ),
      );
    }
    if (data.containsKey('opening_time')) {
      context.handle(
        _openingTimeMeta,
        openingTime.isAcceptableOrUnknown(
          data['opening_time']!,
          _openingTimeMeta,
        ),
      );
    }
    if (data.containsKey('closing_time')) {
      context.handle(
        _closingTimeMeta,
        closingTime.isAcceptableOrUnknown(
          data['closing_time']!,
          _closingTimeMeta,
        ),
      );
    }
    if (data.containsKey('late_cutoff_time')) {
      context.handle(
        _lateCutoffTimeMeta,
        lateCutoffTime.isAcceptableOrUnknown(
          data['late_cutoff_time']!,
          _lateCutoffTimeMeta,
        ),
      );
    }
    if (data.containsKey('head_teacher_name')) {
      context.handle(
        _headTeacherNameMeta,
        headTeacherName.isAcceptableOrUnknown(
          data['head_teacher_name']!,
          _headTeacherNameMeta,
        ),
      );
    }
    if (data.containsKey('deo_name')) {
      context.handle(
        _deoNameMeta,
        deoName.isAcceptableOrUnknown(data['deo_name']!, _deoNameMeta),
      );
    }
    if (data.containsKey('circle_sdeo_name')) {
      context.handle(
        _circleSdeoNameMeta,
        circleSdeoName.isAcceptableOrUnknown(
          data['circle_sdeo_name']!,
          _circleSdeoNameMeta,
        ),
      );
    }
    if (data.containsKey('center_incharge_name')) {
      context.handle(
        _centerInchargeNameMeta,
        centerInchargeName.isAcceptableOrUnknown(
          data['center_incharge_name']!,
          _centerInchargeNameMeta,
        ),
      );
    }
    if (data.containsKey('goshwara_no')) {
      context.handle(
        _goshwaraNoMeta,
        goshwaraNo.isAcceptableOrUnknown(data['goshwara_no']!, _goshwaraNoMeta),
      );
    }
    if (data.containsKey('na_constituency')) {
      context.handle(
        _naConstituencyMeta,
        naConstituency.isAcceptableOrUnknown(
          data['na_constituency']!,
          _naConstituencyMeta,
        ),
      );
    }
    if (data.containsKey('pk_constituency')) {
      context.handle(
        _pkConstituencyMeta,
        pkConstituency.isAcceptableOrUnknown(
          data['pk_constituency']!,
          _pkConstituencyMeta,
        ),
      );
    }
    if (data.containsKey('ltrc_center')) {
      context.handle(
        _ltrcCenterMeta,
        ltrcCenter.isAcceptableOrUnknown(data['ltrc_center']!, _ltrcCenterMeta),
      );
    }
    if (data.containsKey('sanctioned_posts_psht')) {
      context.handle(
        _sanctionedPostsPshtMeta,
        sanctionedPostsPsht.isAcceptableOrUnknown(
          data['sanctioned_posts_psht']!,
          _sanctionedPostsPshtMeta,
        ),
      );
    }
    if (data.containsKey('sanctioned_posts_spst')) {
      context.handle(
        _sanctionedPostsSpstMeta,
        sanctionedPostsSpst.isAcceptableOrUnknown(
          data['sanctioned_posts_spst']!,
          _sanctionedPostsSpstMeta,
        ),
      );
    }
    if (data.containsKey('sanctioned_posts_pst')) {
      context.handle(
        _sanctionedPostsPstMeta,
        sanctionedPostsPst.isAcceptableOrUnknown(
          data['sanctioned_posts_pst']!,
          _sanctionedPostsPstMeta,
        ),
      );
    }
    if (data.containsKey('vacant_posts_pst')) {
      context.handle(
        _vacantPostsPstMeta,
        vacantPostsPst.isAcceptableOrUnknown(
          data['vacant_posts_pst']!,
          _vacantPostsPstMeta,
        ),
      );
    }
    if (data.containsKey('vacant_posts_chowkidar')) {
      context.handle(
        _vacantPostsChowkidarMeta,
        vacantPostsChowkidar.isAcceptableOrUnknown(
          data['vacant_posts_chowkidar']!,
          _vacantPostsChowkidarMeta,
        ),
      );
    }
    if (data.containsKey('classrooms_instructional')) {
      context.handle(
        _classroomsInstructionalMeta,
        classroomsInstructional.isAcceptableOrUnknown(
          data['classrooms_instructional']!,
          _classroomsInstructionalMeta,
        ),
      );
    }
    if (data.containsKey('classrooms_non_instructional')) {
      context.handle(
        _classroomsNonInstructionalMeta,
        classroomsNonInstructional.isAcceptableOrUnknown(
          data['classrooms_non_instructional']!,
          _classroomsNonInstructionalMeta,
        ),
      );
    }
    if (data.containsKey('establishment_year')) {
      context.handle(
        _establishmentYearMeta,
        establishmentYear.isAcceptableOrUnknown(
          data['establishment_year']!,
          _establishmentYearMeta,
        ),
      );
    }
    if (data.containsKey('construction_year')) {
      context.handle(
        _constructionYearMeta,
        constructionYear.isAcceptableOrUnknown(
          data['construction_year']!,
          _constructionYearMeta,
        ),
      );
    }
    if (data.containsKey('facility_electricity')) {
      context.handle(
        _facilityElectricityMeta,
        facilityElectricity.isAcceptableOrUnknown(
          data['facility_electricity']!,
          _facilityElectricityMeta,
        ),
      );
    }
    if (data.containsKey('facility_water_pipe')) {
      context.handle(
        _facilityWaterPipeMeta,
        facilityWaterPipe.isAcceptableOrUnknown(
          data['facility_water_pipe']!,
          _facilityWaterPipeMeta,
        ),
      );
    }
    if (data.containsKey('facility_water_well')) {
      context.handle(
        _facilityWaterWellMeta,
        facilityWaterWell.isAcceptableOrUnknown(
          data['facility_water_well']!,
          _facilityWaterWellMeta,
        ),
      );
    }
    if (data.containsKey('facility_solar')) {
      context.handle(
        _facilitySolarMeta,
        facilitySolar.isAcceptableOrUnknown(
          data['facility_solar']!,
          _facilitySolarMeta,
        ),
      );
    }
    if (data.containsKey('facility_boundary_wall')) {
      context.handle(
        _facilityBoundaryWallMeta,
        facilityBoundaryWall.isAcceptableOrUnknown(
          data['facility_boundary_wall']!,
          _facilityBoundaryWallMeta,
        ),
      );
    }
    if (data.containsKey('facility_play_area')) {
      context.handle(
        _facilityPlayAreaMeta,
        facilityPlayArea.isAcceptableOrUnknown(
          data['facility_play_area']!,
          _facilityPlayAreaMeta,
        ),
      );
    }
    if (data.containsKey('facility_office')) {
      context.handle(
        _facilityOfficeMeta,
        facilityOffice.isAcceptableOrUnknown(
          data['facility_office']!,
          _facilityOfficeMeta,
        ),
      );
    }
    if (data.containsKey('facility_toilet_count')) {
      context.handle(
        _facilityToiletCountMeta,
        facilityToiletCount.isAcceptableOrUnknown(
          data['facility_toilet_count']!,
          _facilityToiletCountMeta,
        ),
      );
    }
    if (data.containsKey('ptc_chairman_name')) {
      context.handle(
        _ptcChairmanNameMeta,
        ptcChairmanName.isAcceptableOrUnknown(
          data['ptc_chairman_name']!,
          _ptcChairmanNameMeta,
        ),
      );
    }
    if (data.containsKey('ptc_bank_name')) {
      context.handle(
        _ptcBankNameMeta,
        ptcBankName.isAcceptableOrUnknown(
          data['ptc_bank_name']!,
          _ptcBankNameMeta,
        ),
      );
    }
    if (data.containsKey('ptc_account_no')) {
      context.handle(
        _ptcAccountNoMeta,
        ptcAccountNo.isAcceptableOrUnknown(
          data['ptc_account_no']!,
          _ptcAccountNoMeta,
        ),
      );
    }
    if (data.containsKey('ptc_sanction_date')) {
      context.handle(
        _ptcSanctionDateMeta,
        ptcSanctionDate.isAcceptableOrUnknown(
          data['ptc_sanction_date']!,
          _ptcSanctionDateMeta,
        ),
      );
    }
    if (data.containsKey('fund_total_budget')) {
      context.handle(
        _fundTotalBudgetMeta,
        fundTotalBudget.isAcceptableOrUnknown(
          data['fund_total_budget']!,
          _fundTotalBudgetMeta,
        ),
      );
    }
    if (data.containsKey('fund_total_spent')) {
      context.handle(
        _fundTotalSpentMeta,
        fundTotalSpent.isAcceptableOrUnknown(
          data['fund_total_spent']!,
          _fundTotalSpentMeta,
        ),
      );
    }
    if (data.containsKey('working_days_csv')) {
      context.handle(
        _workingDaysCsvMeta,
        workingDaysCsv.isAcceptableOrUnknown(
          data['working_days_csv']!,
          _workingDaysCsvMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {schoolId};
  @override
  SchoolSettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchoolSettingsEntry(
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      schoolType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_type'],
      )!,
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      )!,
      tehsil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tehsil'],
      )!,
      circleOffice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circle_office'],
      )!,
      unionCouncil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}union_council'],
      )!,
      climateZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}climate_zone'],
      )!,
      openingTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opening_time'],
      )!,
      closingTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closing_time'],
      )!,
      lateCutoffTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}late_cutoff_time'],
      )!,
      headTeacherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}head_teacher_name'],
      )!,
      deoName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deo_name'],
      )!,
      circleSdeoName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circle_sdeo_name'],
      )!,
      centerInchargeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}center_incharge_name'],
      )!,
      goshwaraNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goshwara_no'],
      )!,
      naConstituency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}na_constituency'],
      )!,
      pkConstituency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pk_constituency'],
      )!,
      ltrcCenter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ltrc_center'],
      )!,
      sanctionedPostsPsht: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sanctioned_posts_psht'],
      )!,
      sanctionedPostsSpst: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sanctioned_posts_spst'],
      )!,
      sanctionedPostsPst: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sanctioned_posts_pst'],
      )!,
      vacantPostsPst: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vacant_posts_pst'],
      )!,
      vacantPostsChowkidar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vacant_posts_chowkidar'],
      )!,
      classroomsInstructional: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}classrooms_instructional'],
      )!,
      classroomsNonInstructional: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}classrooms_non_instructional'],
      )!,
      establishmentYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establishment_year'],
      )!,
      constructionYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}construction_year'],
      )!,
      facilityElectricity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}facility_electricity'],
      )!,
      facilityWaterPipe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}facility_water_pipe'],
      )!,
      facilityWaterWell: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}facility_water_well'],
      )!,
      facilitySolar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}facility_solar'],
      )!,
      facilityBoundaryWall: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}facility_boundary_wall'],
      )!,
      facilityPlayArea: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}facility_play_area'],
      )!,
      facilityOffice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}facility_office'],
      )!,
      facilityToiletCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}facility_toilet_count'],
      )!,
      ptcChairmanName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ptc_chairman_name'],
      )!,
      ptcBankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ptc_bank_name'],
      )!,
      ptcAccountNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ptc_account_no'],
      )!,
      ptcSanctionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ptc_sanction_date'],
      )!,
      fundTotalBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fund_total_budget'],
      )!,
      fundTotalSpent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fund_total_spent'],
      )!,
      workingDaysCsv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}working_days_csv'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $SchoolSettingsTable createAlias(String alias) {
    return $SchoolSettingsTable(attachedDatabase, alias);
  }
}

class SchoolSettingsEntry extends DataClass
    implements Insertable<SchoolSettingsEntry> {
  final String schoolId;
  final String schoolType;
  final String district;
  final String tehsil;
  final String circleOffice;
  final String unionCouncil;
  final String climateZone;
  final String openingTime;
  final String closingTime;
  final String lateCutoffTime;
  final String headTeacherName;
  final String deoName;
  final String circleSdeoName;
  final String centerInchargeName;
  final String goshwaraNo;
  final String naConstituency;
  final String pkConstituency;
  final String ltrcCenter;
  final int sanctionedPostsPsht;
  final int sanctionedPostsSpst;
  final int sanctionedPostsPst;
  final int vacantPostsPst;
  final int vacantPostsChowkidar;
  final int classroomsInstructional;
  final int classroomsNonInstructional;
  final String establishmentYear;
  final String constructionYear;
  final int facilityElectricity;
  final int facilityWaterPipe;
  final int facilityWaterWell;
  final int facilitySolar;
  final int facilityBoundaryWall;
  final int facilityPlayArea;
  final int facilityOffice;
  final int facilityToiletCount;
  final String ptcChairmanName;
  final String ptcBankName;
  final String ptcAccountNo;
  final String ptcSanctionDate;
  final double fundTotalBudget;
  final double fundTotalSpent;
  final String workingDaysCsv;
  final int updatedAt;
  final int revision;
  const SchoolSettingsEntry({
    required this.schoolId,
    required this.schoolType,
    required this.district,
    required this.tehsil,
    required this.circleOffice,
    required this.unionCouncil,
    required this.climateZone,
    required this.openingTime,
    required this.closingTime,
    required this.lateCutoffTime,
    required this.headTeacherName,
    required this.deoName,
    required this.circleSdeoName,
    required this.centerInchargeName,
    required this.goshwaraNo,
    required this.naConstituency,
    required this.pkConstituency,
    required this.ltrcCenter,
    required this.sanctionedPostsPsht,
    required this.sanctionedPostsSpst,
    required this.sanctionedPostsPst,
    required this.vacantPostsPst,
    required this.vacantPostsChowkidar,
    required this.classroomsInstructional,
    required this.classroomsNonInstructional,
    required this.establishmentYear,
    required this.constructionYear,
    required this.facilityElectricity,
    required this.facilityWaterPipe,
    required this.facilityWaterWell,
    required this.facilitySolar,
    required this.facilityBoundaryWall,
    required this.facilityPlayArea,
    required this.facilityOffice,
    required this.facilityToiletCount,
    required this.ptcChairmanName,
    required this.ptcBankName,
    required this.ptcAccountNo,
    required this.ptcSanctionDate,
    required this.fundTotalBudget,
    required this.fundTotalSpent,
    required this.workingDaysCsv,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['school_id'] = Variable<String>(schoolId);
    map['school_type'] = Variable<String>(schoolType);
    map['district'] = Variable<String>(district);
    map['tehsil'] = Variable<String>(tehsil);
    map['circle_office'] = Variable<String>(circleOffice);
    map['union_council'] = Variable<String>(unionCouncil);
    map['climate_zone'] = Variable<String>(climateZone);
    map['opening_time'] = Variable<String>(openingTime);
    map['closing_time'] = Variable<String>(closingTime);
    map['late_cutoff_time'] = Variable<String>(lateCutoffTime);
    map['head_teacher_name'] = Variable<String>(headTeacherName);
    map['deo_name'] = Variable<String>(deoName);
    map['circle_sdeo_name'] = Variable<String>(circleSdeoName);
    map['center_incharge_name'] = Variable<String>(centerInchargeName);
    map['goshwara_no'] = Variable<String>(goshwaraNo);
    map['na_constituency'] = Variable<String>(naConstituency);
    map['pk_constituency'] = Variable<String>(pkConstituency);
    map['ltrc_center'] = Variable<String>(ltrcCenter);
    map['sanctioned_posts_psht'] = Variable<int>(sanctionedPostsPsht);
    map['sanctioned_posts_spst'] = Variable<int>(sanctionedPostsSpst);
    map['sanctioned_posts_pst'] = Variable<int>(sanctionedPostsPst);
    map['vacant_posts_pst'] = Variable<int>(vacantPostsPst);
    map['vacant_posts_chowkidar'] = Variable<int>(vacantPostsChowkidar);
    map['classrooms_instructional'] = Variable<int>(classroomsInstructional);
    map['classrooms_non_instructional'] = Variable<int>(
      classroomsNonInstructional,
    );
    map['establishment_year'] = Variable<String>(establishmentYear);
    map['construction_year'] = Variable<String>(constructionYear);
    map['facility_electricity'] = Variable<int>(facilityElectricity);
    map['facility_water_pipe'] = Variable<int>(facilityWaterPipe);
    map['facility_water_well'] = Variable<int>(facilityWaterWell);
    map['facility_solar'] = Variable<int>(facilitySolar);
    map['facility_boundary_wall'] = Variable<int>(facilityBoundaryWall);
    map['facility_play_area'] = Variable<int>(facilityPlayArea);
    map['facility_office'] = Variable<int>(facilityOffice);
    map['facility_toilet_count'] = Variable<int>(facilityToiletCount);
    map['ptc_chairman_name'] = Variable<String>(ptcChairmanName);
    map['ptc_bank_name'] = Variable<String>(ptcBankName);
    map['ptc_account_no'] = Variable<String>(ptcAccountNo);
    map['ptc_sanction_date'] = Variable<String>(ptcSanctionDate);
    map['fund_total_budget'] = Variable<double>(fundTotalBudget);
    map['fund_total_spent'] = Variable<double>(fundTotalSpent);
    map['working_days_csv'] = Variable<String>(workingDaysCsv);
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  SchoolSettingsCompanion toCompanion(bool nullToAbsent) {
    return SchoolSettingsCompanion(
      schoolId: Value(schoolId),
      schoolType: Value(schoolType),
      district: Value(district),
      tehsil: Value(tehsil),
      circleOffice: Value(circleOffice),
      unionCouncil: Value(unionCouncil),
      climateZone: Value(climateZone),
      openingTime: Value(openingTime),
      closingTime: Value(closingTime),
      lateCutoffTime: Value(lateCutoffTime),
      headTeacherName: Value(headTeacherName),
      deoName: Value(deoName),
      circleSdeoName: Value(circleSdeoName),
      centerInchargeName: Value(centerInchargeName),
      goshwaraNo: Value(goshwaraNo),
      naConstituency: Value(naConstituency),
      pkConstituency: Value(pkConstituency),
      ltrcCenter: Value(ltrcCenter),
      sanctionedPostsPsht: Value(sanctionedPostsPsht),
      sanctionedPostsSpst: Value(sanctionedPostsSpst),
      sanctionedPostsPst: Value(sanctionedPostsPst),
      vacantPostsPst: Value(vacantPostsPst),
      vacantPostsChowkidar: Value(vacantPostsChowkidar),
      classroomsInstructional: Value(classroomsInstructional),
      classroomsNonInstructional: Value(classroomsNonInstructional),
      establishmentYear: Value(establishmentYear),
      constructionYear: Value(constructionYear),
      facilityElectricity: Value(facilityElectricity),
      facilityWaterPipe: Value(facilityWaterPipe),
      facilityWaterWell: Value(facilityWaterWell),
      facilitySolar: Value(facilitySolar),
      facilityBoundaryWall: Value(facilityBoundaryWall),
      facilityPlayArea: Value(facilityPlayArea),
      facilityOffice: Value(facilityOffice),
      facilityToiletCount: Value(facilityToiletCount),
      ptcChairmanName: Value(ptcChairmanName),
      ptcBankName: Value(ptcBankName),
      ptcAccountNo: Value(ptcAccountNo),
      ptcSanctionDate: Value(ptcSanctionDate),
      fundTotalBudget: Value(fundTotalBudget),
      fundTotalSpent: Value(fundTotalSpent),
      workingDaysCsv: Value(workingDaysCsv),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory SchoolSettingsEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchoolSettingsEntry(
      schoolId: serializer.fromJson<String>(json['schoolId']),
      schoolType: serializer.fromJson<String>(json['schoolType']),
      district: serializer.fromJson<String>(json['district']),
      tehsil: serializer.fromJson<String>(json['tehsil']),
      circleOffice: serializer.fromJson<String>(json['circleOffice']),
      unionCouncil: serializer.fromJson<String>(json['unionCouncil']),
      climateZone: serializer.fromJson<String>(json['climateZone']),
      openingTime: serializer.fromJson<String>(json['openingTime']),
      closingTime: serializer.fromJson<String>(json['closingTime']),
      lateCutoffTime: serializer.fromJson<String>(json['lateCutoffTime']),
      headTeacherName: serializer.fromJson<String>(json['headTeacherName']),
      deoName: serializer.fromJson<String>(json['deoName']),
      circleSdeoName: serializer.fromJson<String>(json['circleSdeoName']),
      centerInchargeName: serializer.fromJson<String>(
        json['centerInchargeName'],
      ),
      goshwaraNo: serializer.fromJson<String>(json['goshwaraNo']),
      naConstituency: serializer.fromJson<String>(json['naConstituency']),
      pkConstituency: serializer.fromJson<String>(json['pkConstituency']),
      ltrcCenter: serializer.fromJson<String>(json['ltrcCenter']),
      sanctionedPostsPsht: serializer.fromJson<int>(
        json['sanctionedPostsPsht'],
      ),
      sanctionedPostsSpst: serializer.fromJson<int>(
        json['sanctionedPostsSpst'],
      ),
      sanctionedPostsPst: serializer.fromJson<int>(json['sanctionedPostsPst']),
      vacantPostsPst: serializer.fromJson<int>(json['vacantPostsPst']),
      vacantPostsChowkidar: serializer.fromJson<int>(
        json['vacantPostsChowkidar'],
      ),
      classroomsInstructional: serializer.fromJson<int>(
        json['classroomsInstructional'],
      ),
      classroomsNonInstructional: serializer.fromJson<int>(
        json['classroomsNonInstructional'],
      ),
      establishmentYear: serializer.fromJson<String>(json['establishmentYear']),
      constructionYear: serializer.fromJson<String>(json['constructionYear']),
      facilityElectricity: serializer.fromJson<int>(
        json['facilityElectricity'],
      ),
      facilityWaterPipe: serializer.fromJson<int>(json['facilityWaterPipe']),
      facilityWaterWell: serializer.fromJson<int>(json['facilityWaterWell']),
      facilitySolar: serializer.fromJson<int>(json['facilitySolar']),
      facilityBoundaryWall: serializer.fromJson<int>(
        json['facilityBoundaryWall'],
      ),
      facilityPlayArea: serializer.fromJson<int>(json['facilityPlayArea']),
      facilityOffice: serializer.fromJson<int>(json['facilityOffice']),
      facilityToiletCount: serializer.fromJson<int>(
        json['facilityToiletCount'],
      ),
      ptcChairmanName: serializer.fromJson<String>(json['ptcChairmanName']),
      ptcBankName: serializer.fromJson<String>(json['ptcBankName']),
      ptcAccountNo: serializer.fromJson<String>(json['ptcAccountNo']),
      ptcSanctionDate: serializer.fromJson<String>(json['ptcSanctionDate']),
      fundTotalBudget: serializer.fromJson<double>(json['fundTotalBudget']),
      fundTotalSpent: serializer.fromJson<double>(json['fundTotalSpent']),
      workingDaysCsv: serializer.fromJson<String>(json['workingDaysCsv']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'schoolId': serializer.toJson<String>(schoolId),
      'schoolType': serializer.toJson<String>(schoolType),
      'district': serializer.toJson<String>(district),
      'tehsil': serializer.toJson<String>(tehsil),
      'circleOffice': serializer.toJson<String>(circleOffice),
      'unionCouncil': serializer.toJson<String>(unionCouncil),
      'climateZone': serializer.toJson<String>(climateZone),
      'openingTime': serializer.toJson<String>(openingTime),
      'closingTime': serializer.toJson<String>(closingTime),
      'lateCutoffTime': serializer.toJson<String>(lateCutoffTime),
      'headTeacherName': serializer.toJson<String>(headTeacherName),
      'deoName': serializer.toJson<String>(deoName),
      'circleSdeoName': serializer.toJson<String>(circleSdeoName),
      'centerInchargeName': serializer.toJson<String>(centerInchargeName),
      'goshwaraNo': serializer.toJson<String>(goshwaraNo),
      'naConstituency': serializer.toJson<String>(naConstituency),
      'pkConstituency': serializer.toJson<String>(pkConstituency),
      'ltrcCenter': serializer.toJson<String>(ltrcCenter),
      'sanctionedPostsPsht': serializer.toJson<int>(sanctionedPostsPsht),
      'sanctionedPostsSpst': serializer.toJson<int>(sanctionedPostsSpst),
      'sanctionedPostsPst': serializer.toJson<int>(sanctionedPostsPst),
      'vacantPostsPst': serializer.toJson<int>(vacantPostsPst),
      'vacantPostsChowkidar': serializer.toJson<int>(vacantPostsChowkidar),
      'classroomsInstructional': serializer.toJson<int>(
        classroomsInstructional,
      ),
      'classroomsNonInstructional': serializer.toJson<int>(
        classroomsNonInstructional,
      ),
      'establishmentYear': serializer.toJson<String>(establishmentYear),
      'constructionYear': serializer.toJson<String>(constructionYear),
      'facilityElectricity': serializer.toJson<int>(facilityElectricity),
      'facilityWaterPipe': serializer.toJson<int>(facilityWaterPipe),
      'facilityWaterWell': serializer.toJson<int>(facilityWaterWell),
      'facilitySolar': serializer.toJson<int>(facilitySolar),
      'facilityBoundaryWall': serializer.toJson<int>(facilityBoundaryWall),
      'facilityPlayArea': serializer.toJson<int>(facilityPlayArea),
      'facilityOffice': serializer.toJson<int>(facilityOffice),
      'facilityToiletCount': serializer.toJson<int>(facilityToiletCount),
      'ptcChairmanName': serializer.toJson<String>(ptcChairmanName),
      'ptcBankName': serializer.toJson<String>(ptcBankName),
      'ptcAccountNo': serializer.toJson<String>(ptcAccountNo),
      'ptcSanctionDate': serializer.toJson<String>(ptcSanctionDate),
      'fundTotalBudget': serializer.toJson<double>(fundTotalBudget),
      'fundTotalSpent': serializer.toJson<double>(fundTotalSpent),
      'workingDaysCsv': serializer.toJson<String>(workingDaysCsv),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  SchoolSettingsEntry copyWith({
    String? schoolId,
    String? schoolType,
    String? district,
    String? tehsil,
    String? circleOffice,
    String? unionCouncil,
    String? climateZone,
    String? openingTime,
    String? closingTime,
    String? lateCutoffTime,
    String? headTeacherName,
    String? deoName,
    String? circleSdeoName,
    String? centerInchargeName,
    String? goshwaraNo,
    String? naConstituency,
    String? pkConstituency,
    String? ltrcCenter,
    int? sanctionedPostsPsht,
    int? sanctionedPostsSpst,
    int? sanctionedPostsPst,
    int? vacantPostsPst,
    int? vacantPostsChowkidar,
    int? classroomsInstructional,
    int? classroomsNonInstructional,
    String? establishmentYear,
    String? constructionYear,
    int? facilityElectricity,
    int? facilityWaterPipe,
    int? facilityWaterWell,
    int? facilitySolar,
    int? facilityBoundaryWall,
    int? facilityPlayArea,
    int? facilityOffice,
    int? facilityToiletCount,
    String? ptcChairmanName,
    String? ptcBankName,
    String? ptcAccountNo,
    String? ptcSanctionDate,
    double? fundTotalBudget,
    double? fundTotalSpent,
    String? workingDaysCsv,
    int? updatedAt,
    int? revision,
  }) => SchoolSettingsEntry(
    schoolId: schoolId ?? this.schoolId,
    schoolType: schoolType ?? this.schoolType,
    district: district ?? this.district,
    tehsil: tehsil ?? this.tehsil,
    circleOffice: circleOffice ?? this.circleOffice,
    unionCouncil: unionCouncil ?? this.unionCouncil,
    climateZone: climateZone ?? this.climateZone,
    openingTime: openingTime ?? this.openingTime,
    closingTime: closingTime ?? this.closingTime,
    lateCutoffTime: lateCutoffTime ?? this.lateCutoffTime,
    headTeacherName: headTeacherName ?? this.headTeacherName,
    deoName: deoName ?? this.deoName,
    circleSdeoName: circleSdeoName ?? this.circleSdeoName,
    centerInchargeName: centerInchargeName ?? this.centerInchargeName,
    goshwaraNo: goshwaraNo ?? this.goshwaraNo,
    naConstituency: naConstituency ?? this.naConstituency,
    pkConstituency: pkConstituency ?? this.pkConstituency,
    ltrcCenter: ltrcCenter ?? this.ltrcCenter,
    sanctionedPostsPsht: sanctionedPostsPsht ?? this.sanctionedPostsPsht,
    sanctionedPostsSpst: sanctionedPostsSpst ?? this.sanctionedPostsSpst,
    sanctionedPostsPst: sanctionedPostsPst ?? this.sanctionedPostsPst,
    vacantPostsPst: vacantPostsPst ?? this.vacantPostsPst,
    vacantPostsChowkidar: vacantPostsChowkidar ?? this.vacantPostsChowkidar,
    classroomsInstructional:
        classroomsInstructional ?? this.classroomsInstructional,
    classroomsNonInstructional:
        classroomsNonInstructional ?? this.classroomsNonInstructional,
    establishmentYear: establishmentYear ?? this.establishmentYear,
    constructionYear: constructionYear ?? this.constructionYear,
    facilityElectricity: facilityElectricity ?? this.facilityElectricity,
    facilityWaterPipe: facilityWaterPipe ?? this.facilityWaterPipe,
    facilityWaterWell: facilityWaterWell ?? this.facilityWaterWell,
    facilitySolar: facilitySolar ?? this.facilitySolar,
    facilityBoundaryWall: facilityBoundaryWall ?? this.facilityBoundaryWall,
    facilityPlayArea: facilityPlayArea ?? this.facilityPlayArea,
    facilityOffice: facilityOffice ?? this.facilityOffice,
    facilityToiletCount: facilityToiletCount ?? this.facilityToiletCount,
    ptcChairmanName: ptcChairmanName ?? this.ptcChairmanName,
    ptcBankName: ptcBankName ?? this.ptcBankName,
    ptcAccountNo: ptcAccountNo ?? this.ptcAccountNo,
    ptcSanctionDate: ptcSanctionDate ?? this.ptcSanctionDate,
    fundTotalBudget: fundTotalBudget ?? this.fundTotalBudget,
    fundTotalSpent: fundTotalSpent ?? this.fundTotalSpent,
    workingDaysCsv: workingDaysCsv ?? this.workingDaysCsv,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  SchoolSettingsEntry copyWithCompanion(SchoolSettingsCompanion data) {
    return SchoolSettingsEntry(
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      schoolType: data.schoolType.present
          ? data.schoolType.value
          : this.schoolType,
      district: data.district.present ? data.district.value : this.district,
      tehsil: data.tehsil.present ? data.tehsil.value : this.tehsil,
      circleOffice: data.circleOffice.present
          ? data.circleOffice.value
          : this.circleOffice,
      unionCouncil: data.unionCouncil.present
          ? data.unionCouncil.value
          : this.unionCouncil,
      climateZone: data.climateZone.present
          ? data.climateZone.value
          : this.climateZone,
      openingTime: data.openingTime.present
          ? data.openingTime.value
          : this.openingTime,
      closingTime: data.closingTime.present
          ? data.closingTime.value
          : this.closingTime,
      lateCutoffTime: data.lateCutoffTime.present
          ? data.lateCutoffTime.value
          : this.lateCutoffTime,
      headTeacherName: data.headTeacherName.present
          ? data.headTeacherName.value
          : this.headTeacherName,
      deoName: data.deoName.present ? data.deoName.value : this.deoName,
      circleSdeoName: data.circleSdeoName.present
          ? data.circleSdeoName.value
          : this.circleSdeoName,
      centerInchargeName: data.centerInchargeName.present
          ? data.centerInchargeName.value
          : this.centerInchargeName,
      goshwaraNo: data.goshwaraNo.present
          ? data.goshwaraNo.value
          : this.goshwaraNo,
      naConstituency: data.naConstituency.present
          ? data.naConstituency.value
          : this.naConstituency,
      pkConstituency: data.pkConstituency.present
          ? data.pkConstituency.value
          : this.pkConstituency,
      ltrcCenter: data.ltrcCenter.present
          ? data.ltrcCenter.value
          : this.ltrcCenter,
      sanctionedPostsPsht: data.sanctionedPostsPsht.present
          ? data.sanctionedPostsPsht.value
          : this.sanctionedPostsPsht,
      sanctionedPostsSpst: data.sanctionedPostsSpst.present
          ? data.sanctionedPostsSpst.value
          : this.sanctionedPostsSpst,
      sanctionedPostsPst: data.sanctionedPostsPst.present
          ? data.sanctionedPostsPst.value
          : this.sanctionedPostsPst,
      vacantPostsPst: data.vacantPostsPst.present
          ? data.vacantPostsPst.value
          : this.vacantPostsPst,
      vacantPostsChowkidar: data.vacantPostsChowkidar.present
          ? data.vacantPostsChowkidar.value
          : this.vacantPostsChowkidar,
      classroomsInstructional: data.classroomsInstructional.present
          ? data.classroomsInstructional.value
          : this.classroomsInstructional,
      classroomsNonInstructional: data.classroomsNonInstructional.present
          ? data.classroomsNonInstructional.value
          : this.classroomsNonInstructional,
      establishmentYear: data.establishmentYear.present
          ? data.establishmentYear.value
          : this.establishmentYear,
      constructionYear: data.constructionYear.present
          ? data.constructionYear.value
          : this.constructionYear,
      facilityElectricity: data.facilityElectricity.present
          ? data.facilityElectricity.value
          : this.facilityElectricity,
      facilityWaterPipe: data.facilityWaterPipe.present
          ? data.facilityWaterPipe.value
          : this.facilityWaterPipe,
      facilityWaterWell: data.facilityWaterWell.present
          ? data.facilityWaterWell.value
          : this.facilityWaterWell,
      facilitySolar: data.facilitySolar.present
          ? data.facilitySolar.value
          : this.facilitySolar,
      facilityBoundaryWall: data.facilityBoundaryWall.present
          ? data.facilityBoundaryWall.value
          : this.facilityBoundaryWall,
      facilityPlayArea: data.facilityPlayArea.present
          ? data.facilityPlayArea.value
          : this.facilityPlayArea,
      facilityOffice: data.facilityOffice.present
          ? data.facilityOffice.value
          : this.facilityOffice,
      facilityToiletCount: data.facilityToiletCount.present
          ? data.facilityToiletCount.value
          : this.facilityToiletCount,
      ptcChairmanName: data.ptcChairmanName.present
          ? data.ptcChairmanName.value
          : this.ptcChairmanName,
      ptcBankName: data.ptcBankName.present
          ? data.ptcBankName.value
          : this.ptcBankName,
      ptcAccountNo: data.ptcAccountNo.present
          ? data.ptcAccountNo.value
          : this.ptcAccountNo,
      ptcSanctionDate: data.ptcSanctionDate.present
          ? data.ptcSanctionDate.value
          : this.ptcSanctionDate,
      fundTotalBudget: data.fundTotalBudget.present
          ? data.fundTotalBudget.value
          : this.fundTotalBudget,
      fundTotalSpent: data.fundTotalSpent.present
          ? data.fundTotalSpent.value
          : this.fundTotalSpent,
      workingDaysCsv: data.workingDaysCsv.present
          ? data.workingDaysCsv.value
          : this.workingDaysCsv,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchoolSettingsEntry(')
          ..write('schoolId: $schoolId, ')
          ..write('schoolType: $schoolType, ')
          ..write('district: $district, ')
          ..write('tehsil: $tehsil, ')
          ..write('circleOffice: $circleOffice, ')
          ..write('unionCouncil: $unionCouncil, ')
          ..write('climateZone: $climateZone, ')
          ..write('openingTime: $openingTime, ')
          ..write('closingTime: $closingTime, ')
          ..write('lateCutoffTime: $lateCutoffTime, ')
          ..write('headTeacherName: $headTeacherName, ')
          ..write('deoName: $deoName, ')
          ..write('circleSdeoName: $circleSdeoName, ')
          ..write('centerInchargeName: $centerInchargeName, ')
          ..write('goshwaraNo: $goshwaraNo, ')
          ..write('naConstituency: $naConstituency, ')
          ..write('pkConstituency: $pkConstituency, ')
          ..write('ltrcCenter: $ltrcCenter, ')
          ..write('sanctionedPostsPsht: $sanctionedPostsPsht, ')
          ..write('sanctionedPostsSpst: $sanctionedPostsSpst, ')
          ..write('sanctionedPostsPst: $sanctionedPostsPst, ')
          ..write('vacantPostsPst: $vacantPostsPst, ')
          ..write('vacantPostsChowkidar: $vacantPostsChowkidar, ')
          ..write('classroomsInstructional: $classroomsInstructional, ')
          ..write('classroomsNonInstructional: $classroomsNonInstructional, ')
          ..write('establishmentYear: $establishmentYear, ')
          ..write('constructionYear: $constructionYear, ')
          ..write('facilityElectricity: $facilityElectricity, ')
          ..write('facilityWaterPipe: $facilityWaterPipe, ')
          ..write('facilityWaterWell: $facilityWaterWell, ')
          ..write('facilitySolar: $facilitySolar, ')
          ..write('facilityBoundaryWall: $facilityBoundaryWall, ')
          ..write('facilityPlayArea: $facilityPlayArea, ')
          ..write('facilityOffice: $facilityOffice, ')
          ..write('facilityToiletCount: $facilityToiletCount, ')
          ..write('ptcChairmanName: $ptcChairmanName, ')
          ..write('ptcBankName: $ptcBankName, ')
          ..write('ptcAccountNo: $ptcAccountNo, ')
          ..write('ptcSanctionDate: $ptcSanctionDate, ')
          ..write('fundTotalBudget: $fundTotalBudget, ')
          ..write('fundTotalSpent: $fundTotalSpent, ')
          ..write('workingDaysCsv: $workingDaysCsv, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    schoolId,
    schoolType,
    district,
    tehsil,
    circleOffice,
    unionCouncil,
    climateZone,
    openingTime,
    closingTime,
    lateCutoffTime,
    headTeacherName,
    deoName,
    circleSdeoName,
    centerInchargeName,
    goshwaraNo,
    naConstituency,
    pkConstituency,
    ltrcCenter,
    sanctionedPostsPsht,
    sanctionedPostsSpst,
    sanctionedPostsPst,
    vacantPostsPst,
    vacantPostsChowkidar,
    classroomsInstructional,
    classroomsNonInstructional,
    establishmentYear,
    constructionYear,
    facilityElectricity,
    facilityWaterPipe,
    facilityWaterWell,
    facilitySolar,
    facilityBoundaryWall,
    facilityPlayArea,
    facilityOffice,
    facilityToiletCount,
    ptcChairmanName,
    ptcBankName,
    ptcAccountNo,
    ptcSanctionDate,
    fundTotalBudget,
    fundTotalSpent,
    workingDaysCsv,
    updatedAt,
    revision,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchoolSettingsEntry &&
          other.schoolId == this.schoolId &&
          other.schoolType == this.schoolType &&
          other.district == this.district &&
          other.tehsil == this.tehsil &&
          other.circleOffice == this.circleOffice &&
          other.unionCouncil == this.unionCouncil &&
          other.climateZone == this.climateZone &&
          other.openingTime == this.openingTime &&
          other.closingTime == this.closingTime &&
          other.lateCutoffTime == this.lateCutoffTime &&
          other.headTeacherName == this.headTeacherName &&
          other.deoName == this.deoName &&
          other.circleSdeoName == this.circleSdeoName &&
          other.centerInchargeName == this.centerInchargeName &&
          other.goshwaraNo == this.goshwaraNo &&
          other.naConstituency == this.naConstituency &&
          other.pkConstituency == this.pkConstituency &&
          other.ltrcCenter == this.ltrcCenter &&
          other.sanctionedPostsPsht == this.sanctionedPostsPsht &&
          other.sanctionedPostsSpst == this.sanctionedPostsSpst &&
          other.sanctionedPostsPst == this.sanctionedPostsPst &&
          other.vacantPostsPst == this.vacantPostsPst &&
          other.vacantPostsChowkidar == this.vacantPostsChowkidar &&
          other.classroomsInstructional == this.classroomsInstructional &&
          other.classroomsNonInstructional == this.classroomsNonInstructional &&
          other.establishmentYear == this.establishmentYear &&
          other.constructionYear == this.constructionYear &&
          other.facilityElectricity == this.facilityElectricity &&
          other.facilityWaterPipe == this.facilityWaterPipe &&
          other.facilityWaterWell == this.facilityWaterWell &&
          other.facilitySolar == this.facilitySolar &&
          other.facilityBoundaryWall == this.facilityBoundaryWall &&
          other.facilityPlayArea == this.facilityPlayArea &&
          other.facilityOffice == this.facilityOffice &&
          other.facilityToiletCount == this.facilityToiletCount &&
          other.ptcChairmanName == this.ptcChairmanName &&
          other.ptcBankName == this.ptcBankName &&
          other.ptcAccountNo == this.ptcAccountNo &&
          other.ptcSanctionDate == this.ptcSanctionDate &&
          other.fundTotalBudget == this.fundTotalBudget &&
          other.fundTotalSpent == this.fundTotalSpent &&
          other.workingDaysCsv == this.workingDaysCsv &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class SchoolSettingsCompanion extends UpdateCompanion<SchoolSettingsEntry> {
  final Value<String> schoolId;
  final Value<String> schoolType;
  final Value<String> district;
  final Value<String> tehsil;
  final Value<String> circleOffice;
  final Value<String> unionCouncil;
  final Value<String> climateZone;
  final Value<String> openingTime;
  final Value<String> closingTime;
  final Value<String> lateCutoffTime;
  final Value<String> headTeacherName;
  final Value<String> deoName;
  final Value<String> circleSdeoName;
  final Value<String> centerInchargeName;
  final Value<String> goshwaraNo;
  final Value<String> naConstituency;
  final Value<String> pkConstituency;
  final Value<String> ltrcCenter;
  final Value<int> sanctionedPostsPsht;
  final Value<int> sanctionedPostsSpst;
  final Value<int> sanctionedPostsPst;
  final Value<int> vacantPostsPst;
  final Value<int> vacantPostsChowkidar;
  final Value<int> classroomsInstructional;
  final Value<int> classroomsNonInstructional;
  final Value<String> establishmentYear;
  final Value<String> constructionYear;
  final Value<int> facilityElectricity;
  final Value<int> facilityWaterPipe;
  final Value<int> facilityWaterWell;
  final Value<int> facilitySolar;
  final Value<int> facilityBoundaryWall;
  final Value<int> facilityPlayArea;
  final Value<int> facilityOffice;
  final Value<int> facilityToiletCount;
  final Value<String> ptcChairmanName;
  final Value<String> ptcBankName;
  final Value<String> ptcAccountNo;
  final Value<String> ptcSanctionDate;
  final Value<double> fundTotalBudget;
  final Value<double> fundTotalSpent;
  final Value<String> workingDaysCsv;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const SchoolSettingsCompanion({
    this.schoolId = const Value.absent(),
    this.schoolType = const Value.absent(),
    this.district = const Value.absent(),
    this.tehsil = const Value.absent(),
    this.circleOffice = const Value.absent(),
    this.unionCouncil = const Value.absent(),
    this.climateZone = const Value.absent(),
    this.openingTime = const Value.absent(),
    this.closingTime = const Value.absent(),
    this.lateCutoffTime = const Value.absent(),
    this.headTeacherName = const Value.absent(),
    this.deoName = const Value.absent(),
    this.circleSdeoName = const Value.absent(),
    this.centerInchargeName = const Value.absent(),
    this.goshwaraNo = const Value.absent(),
    this.naConstituency = const Value.absent(),
    this.pkConstituency = const Value.absent(),
    this.ltrcCenter = const Value.absent(),
    this.sanctionedPostsPsht = const Value.absent(),
    this.sanctionedPostsSpst = const Value.absent(),
    this.sanctionedPostsPst = const Value.absent(),
    this.vacantPostsPst = const Value.absent(),
    this.vacantPostsChowkidar = const Value.absent(),
    this.classroomsInstructional = const Value.absent(),
    this.classroomsNonInstructional = const Value.absent(),
    this.establishmentYear = const Value.absent(),
    this.constructionYear = const Value.absent(),
    this.facilityElectricity = const Value.absent(),
    this.facilityWaterPipe = const Value.absent(),
    this.facilityWaterWell = const Value.absent(),
    this.facilitySolar = const Value.absent(),
    this.facilityBoundaryWall = const Value.absent(),
    this.facilityPlayArea = const Value.absent(),
    this.facilityOffice = const Value.absent(),
    this.facilityToiletCount = const Value.absent(),
    this.ptcChairmanName = const Value.absent(),
    this.ptcBankName = const Value.absent(),
    this.ptcAccountNo = const Value.absent(),
    this.ptcSanctionDate = const Value.absent(),
    this.fundTotalBudget = const Value.absent(),
    this.fundTotalSpent = const Value.absent(),
    this.workingDaysCsv = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchoolSettingsCompanion.insert({
    required String schoolId,
    this.schoolType = const Value.absent(),
    this.district = const Value.absent(),
    this.tehsil = const Value.absent(),
    this.circleOffice = const Value.absent(),
    this.unionCouncil = const Value.absent(),
    this.climateZone = const Value.absent(),
    this.openingTime = const Value.absent(),
    this.closingTime = const Value.absent(),
    this.lateCutoffTime = const Value.absent(),
    this.headTeacherName = const Value.absent(),
    this.deoName = const Value.absent(),
    this.circleSdeoName = const Value.absent(),
    this.centerInchargeName = const Value.absent(),
    this.goshwaraNo = const Value.absent(),
    this.naConstituency = const Value.absent(),
    this.pkConstituency = const Value.absent(),
    this.ltrcCenter = const Value.absent(),
    this.sanctionedPostsPsht = const Value.absent(),
    this.sanctionedPostsSpst = const Value.absent(),
    this.sanctionedPostsPst = const Value.absent(),
    this.vacantPostsPst = const Value.absent(),
    this.vacantPostsChowkidar = const Value.absent(),
    this.classroomsInstructional = const Value.absent(),
    this.classroomsNonInstructional = const Value.absent(),
    this.establishmentYear = const Value.absent(),
    this.constructionYear = const Value.absent(),
    this.facilityElectricity = const Value.absent(),
    this.facilityWaterPipe = const Value.absent(),
    this.facilityWaterWell = const Value.absent(),
    this.facilitySolar = const Value.absent(),
    this.facilityBoundaryWall = const Value.absent(),
    this.facilityPlayArea = const Value.absent(),
    this.facilityOffice = const Value.absent(),
    this.facilityToiletCount = const Value.absent(),
    this.ptcChairmanName = const Value.absent(),
    this.ptcBankName = const Value.absent(),
    this.ptcAccountNo = const Value.absent(),
    this.ptcSanctionDate = const Value.absent(),
    this.fundTotalBudget = const Value.absent(),
    this.fundTotalSpent = const Value.absent(),
    this.workingDaysCsv = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : schoolId = Value(schoolId);
  static Insertable<SchoolSettingsEntry> custom({
    Expression<String>? schoolId,
    Expression<String>? schoolType,
    Expression<String>? district,
    Expression<String>? tehsil,
    Expression<String>? circleOffice,
    Expression<String>? unionCouncil,
    Expression<String>? climateZone,
    Expression<String>? openingTime,
    Expression<String>? closingTime,
    Expression<String>? lateCutoffTime,
    Expression<String>? headTeacherName,
    Expression<String>? deoName,
    Expression<String>? circleSdeoName,
    Expression<String>? centerInchargeName,
    Expression<String>? goshwaraNo,
    Expression<String>? naConstituency,
    Expression<String>? pkConstituency,
    Expression<String>? ltrcCenter,
    Expression<int>? sanctionedPostsPsht,
    Expression<int>? sanctionedPostsSpst,
    Expression<int>? sanctionedPostsPst,
    Expression<int>? vacantPostsPst,
    Expression<int>? vacantPostsChowkidar,
    Expression<int>? classroomsInstructional,
    Expression<int>? classroomsNonInstructional,
    Expression<String>? establishmentYear,
    Expression<String>? constructionYear,
    Expression<int>? facilityElectricity,
    Expression<int>? facilityWaterPipe,
    Expression<int>? facilityWaterWell,
    Expression<int>? facilitySolar,
    Expression<int>? facilityBoundaryWall,
    Expression<int>? facilityPlayArea,
    Expression<int>? facilityOffice,
    Expression<int>? facilityToiletCount,
    Expression<String>? ptcChairmanName,
    Expression<String>? ptcBankName,
    Expression<String>? ptcAccountNo,
    Expression<String>? ptcSanctionDate,
    Expression<double>? fundTotalBudget,
    Expression<double>? fundTotalSpent,
    Expression<String>? workingDaysCsv,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (schoolId != null) 'school_id': schoolId,
      if (schoolType != null) 'school_type': schoolType,
      if (district != null) 'district': district,
      if (tehsil != null) 'tehsil': tehsil,
      if (circleOffice != null) 'circle_office': circleOffice,
      if (unionCouncil != null) 'union_council': unionCouncil,
      if (climateZone != null) 'climate_zone': climateZone,
      if (openingTime != null) 'opening_time': openingTime,
      if (closingTime != null) 'closing_time': closingTime,
      if (lateCutoffTime != null) 'late_cutoff_time': lateCutoffTime,
      if (headTeacherName != null) 'head_teacher_name': headTeacherName,
      if (deoName != null) 'deo_name': deoName,
      if (circleSdeoName != null) 'circle_sdeo_name': circleSdeoName,
      if (centerInchargeName != null)
        'center_incharge_name': centerInchargeName,
      if (goshwaraNo != null) 'goshwara_no': goshwaraNo,
      if (naConstituency != null) 'na_constituency': naConstituency,
      if (pkConstituency != null) 'pk_constituency': pkConstituency,
      if (ltrcCenter != null) 'ltrc_center': ltrcCenter,
      if (sanctionedPostsPsht != null)
        'sanctioned_posts_psht': sanctionedPostsPsht,
      if (sanctionedPostsSpst != null)
        'sanctioned_posts_spst': sanctionedPostsSpst,
      if (sanctionedPostsPst != null)
        'sanctioned_posts_pst': sanctionedPostsPst,
      if (vacantPostsPst != null) 'vacant_posts_pst': vacantPostsPst,
      if (vacantPostsChowkidar != null)
        'vacant_posts_chowkidar': vacantPostsChowkidar,
      if (classroomsInstructional != null)
        'classrooms_instructional': classroomsInstructional,
      if (classroomsNonInstructional != null)
        'classrooms_non_instructional': classroomsNonInstructional,
      if (establishmentYear != null) 'establishment_year': establishmentYear,
      if (constructionYear != null) 'construction_year': constructionYear,
      if (facilityElectricity != null)
        'facility_electricity': facilityElectricity,
      if (facilityWaterPipe != null) 'facility_water_pipe': facilityWaterPipe,
      if (facilityWaterWell != null) 'facility_water_well': facilityWaterWell,
      if (facilitySolar != null) 'facility_solar': facilitySolar,
      if (facilityBoundaryWall != null)
        'facility_boundary_wall': facilityBoundaryWall,
      if (facilityPlayArea != null) 'facility_play_area': facilityPlayArea,
      if (facilityOffice != null) 'facility_office': facilityOffice,
      if (facilityToiletCount != null)
        'facility_toilet_count': facilityToiletCount,
      if (ptcChairmanName != null) 'ptc_chairman_name': ptcChairmanName,
      if (ptcBankName != null) 'ptc_bank_name': ptcBankName,
      if (ptcAccountNo != null) 'ptc_account_no': ptcAccountNo,
      if (ptcSanctionDate != null) 'ptc_sanction_date': ptcSanctionDate,
      if (fundTotalBudget != null) 'fund_total_budget': fundTotalBudget,
      if (fundTotalSpent != null) 'fund_total_spent': fundTotalSpent,
      if (workingDaysCsv != null) 'working_days_csv': workingDaysCsv,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchoolSettingsCompanion copyWith({
    Value<String>? schoolId,
    Value<String>? schoolType,
    Value<String>? district,
    Value<String>? tehsil,
    Value<String>? circleOffice,
    Value<String>? unionCouncil,
    Value<String>? climateZone,
    Value<String>? openingTime,
    Value<String>? closingTime,
    Value<String>? lateCutoffTime,
    Value<String>? headTeacherName,
    Value<String>? deoName,
    Value<String>? circleSdeoName,
    Value<String>? centerInchargeName,
    Value<String>? goshwaraNo,
    Value<String>? naConstituency,
    Value<String>? pkConstituency,
    Value<String>? ltrcCenter,
    Value<int>? sanctionedPostsPsht,
    Value<int>? sanctionedPostsSpst,
    Value<int>? sanctionedPostsPst,
    Value<int>? vacantPostsPst,
    Value<int>? vacantPostsChowkidar,
    Value<int>? classroomsInstructional,
    Value<int>? classroomsNonInstructional,
    Value<String>? establishmentYear,
    Value<String>? constructionYear,
    Value<int>? facilityElectricity,
    Value<int>? facilityWaterPipe,
    Value<int>? facilityWaterWell,
    Value<int>? facilitySolar,
    Value<int>? facilityBoundaryWall,
    Value<int>? facilityPlayArea,
    Value<int>? facilityOffice,
    Value<int>? facilityToiletCount,
    Value<String>? ptcChairmanName,
    Value<String>? ptcBankName,
    Value<String>? ptcAccountNo,
    Value<String>? ptcSanctionDate,
    Value<double>? fundTotalBudget,
    Value<double>? fundTotalSpent,
    Value<String>? workingDaysCsv,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return SchoolSettingsCompanion(
      schoolId: schoolId ?? this.schoolId,
      schoolType: schoolType ?? this.schoolType,
      district: district ?? this.district,
      tehsil: tehsil ?? this.tehsil,
      circleOffice: circleOffice ?? this.circleOffice,
      unionCouncil: unionCouncil ?? this.unionCouncil,
      climateZone: climateZone ?? this.climateZone,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      lateCutoffTime: lateCutoffTime ?? this.lateCutoffTime,
      headTeacherName: headTeacherName ?? this.headTeacherName,
      deoName: deoName ?? this.deoName,
      circleSdeoName: circleSdeoName ?? this.circleSdeoName,
      centerInchargeName: centerInchargeName ?? this.centerInchargeName,
      goshwaraNo: goshwaraNo ?? this.goshwaraNo,
      naConstituency: naConstituency ?? this.naConstituency,
      pkConstituency: pkConstituency ?? this.pkConstituency,
      ltrcCenter: ltrcCenter ?? this.ltrcCenter,
      sanctionedPostsPsht: sanctionedPostsPsht ?? this.sanctionedPostsPsht,
      sanctionedPostsSpst: sanctionedPostsSpst ?? this.sanctionedPostsSpst,
      sanctionedPostsPst: sanctionedPostsPst ?? this.sanctionedPostsPst,
      vacantPostsPst: vacantPostsPst ?? this.vacantPostsPst,
      vacantPostsChowkidar: vacantPostsChowkidar ?? this.vacantPostsChowkidar,
      classroomsInstructional:
          classroomsInstructional ?? this.classroomsInstructional,
      classroomsNonInstructional:
          classroomsNonInstructional ?? this.classroomsNonInstructional,
      establishmentYear: establishmentYear ?? this.establishmentYear,
      constructionYear: constructionYear ?? this.constructionYear,
      facilityElectricity: facilityElectricity ?? this.facilityElectricity,
      facilityWaterPipe: facilityWaterPipe ?? this.facilityWaterPipe,
      facilityWaterWell: facilityWaterWell ?? this.facilityWaterWell,
      facilitySolar: facilitySolar ?? this.facilitySolar,
      facilityBoundaryWall: facilityBoundaryWall ?? this.facilityBoundaryWall,
      facilityPlayArea: facilityPlayArea ?? this.facilityPlayArea,
      facilityOffice: facilityOffice ?? this.facilityOffice,
      facilityToiletCount: facilityToiletCount ?? this.facilityToiletCount,
      ptcChairmanName: ptcChairmanName ?? this.ptcChairmanName,
      ptcBankName: ptcBankName ?? this.ptcBankName,
      ptcAccountNo: ptcAccountNo ?? this.ptcAccountNo,
      ptcSanctionDate: ptcSanctionDate ?? this.ptcSanctionDate,
      fundTotalBudget: fundTotalBudget ?? this.fundTotalBudget,
      fundTotalSpent: fundTotalSpent ?? this.fundTotalSpent,
      workingDaysCsv: workingDaysCsv ?? this.workingDaysCsv,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (schoolType.present) {
      map['school_type'] = Variable<String>(schoolType.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (tehsil.present) {
      map['tehsil'] = Variable<String>(tehsil.value);
    }
    if (circleOffice.present) {
      map['circle_office'] = Variable<String>(circleOffice.value);
    }
    if (unionCouncil.present) {
      map['union_council'] = Variable<String>(unionCouncil.value);
    }
    if (climateZone.present) {
      map['climate_zone'] = Variable<String>(climateZone.value);
    }
    if (openingTime.present) {
      map['opening_time'] = Variable<String>(openingTime.value);
    }
    if (closingTime.present) {
      map['closing_time'] = Variable<String>(closingTime.value);
    }
    if (lateCutoffTime.present) {
      map['late_cutoff_time'] = Variable<String>(lateCutoffTime.value);
    }
    if (headTeacherName.present) {
      map['head_teacher_name'] = Variable<String>(headTeacherName.value);
    }
    if (deoName.present) {
      map['deo_name'] = Variable<String>(deoName.value);
    }
    if (circleSdeoName.present) {
      map['circle_sdeo_name'] = Variable<String>(circleSdeoName.value);
    }
    if (centerInchargeName.present) {
      map['center_incharge_name'] = Variable<String>(centerInchargeName.value);
    }
    if (goshwaraNo.present) {
      map['goshwara_no'] = Variable<String>(goshwaraNo.value);
    }
    if (naConstituency.present) {
      map['na_constituency'] = Variable<String>(naConstituency.value);
    }
    if (pkConstituency.present) {
      map['pk_constituency'] = Variable<String>(pkConstituency.value);
    }
    if (ltrcCenter.present) {
      map['ltrc_center'] = Variable<String>(ltrcCenter.value);
    }
    if (sanctionedPostsPsht.present) {
      map['sanctioned_posts_psht'] = Variable<int>(sanctionedPostsPsht.value);
    }
    if (sanctionedPostsSpst.present) {
      map['sanctioned_posts_spst'] = Variable<int>(sanctionedPostsSpst.value);
    }
    if (sanctionedPostsPst.present) {
      map['sanctioned_posts_pst'] = Variable<int>(sanctionedPostsPst.value);
    }
    if (vacantPostsPst.present) {
      map['vacant_posts_pst'] = Variable<int>(vacantPostsPst.value);
    }
    if (vacantPostsChowkidar.present) {
      map['vacant_posts_chowkidar'] = Variable<int>(vacantPostsChowkidar.value);
    }
    if (classroomsInstructional.present) {
      map['classrooms_instructional'] = Variable<int>(
        classroomsInstructional.value,
      );
    }
    if (classroomsNonInstructional.present) {
      map['classrooms_non_instructional'] = Variable<int>(
        classroomsNonInstructional.value,
      );
    }
    if (establishmentYear.present) {
      map['establishment_year'] = Variable<String>(establishmentYear.value);
    }
    if (constructionYear.present) {
      map['construction_year'] = Variable<String>(constructionYear.value);
    }
    if (facilityElectricity.present) {
      map['facility_electricity'] = Variable<int>(facilityElectricity.value);
    }
    if (facilityWaterPipe.present) {
      map['facility_water_pipe'] = Variable<int>(facilityWaterPipe.value);
    }
    if (facilityWaterWell.present) {
      map['facility_water_well'] = Variable<int>(facilityWaterWell.value);
    }
    if (facilitySolar.present) {
      map['facility_solar'] = Variable<int>(facilitySolar.value);
    }
    if (facilityBoundaryWall.present) {
      map['facility_boundary_wall'] = Variable<int>(facilityBoundaryWall.value);
    }
    if (facilityPlayArea.present) {
      map['facility_play_area'] = Variable<int>(facilityPlayArea.value);
    }
    if (facilityOffice.present) {
      map['facility_office'] = Variable<int>(facilityOffice.value);
    }
    if (facilityToiletCount.present) {
      map['facility_toilet_count'] = Variable<int>(facilityToiletCount.value);
    }
    if (ptcChairmanName.present) {
      map['ptc_chairman_name'] = Variable<String>(ptcChairmanName.value);
    }
    if (ptcBankName.present) {
      map['ptc_bank_name'] = Variable<String>(ptcBankName.value);
    }
    if (ptcAccountNo.present) {
      map['ptc_account_no'] = Variable<String>(ptcAccountNo.value);
    }
    if (ptcSanctionDate.present) {
      map['ptc_sanction_date'] = Variable<String>(ptcSanctionDate.value);
    }
    if (fundTotalBudget.present) {
      map['fund_total_budget'] = Variable<double>(fundTotalBudget.value);
    }
    if (fundTotalSpent.present) {
      map['fund_total_spent'] = Variable<double>(fundTotalSpent.value);
    }
    if (workingDaysCsv.present) {
      map['working_days_csv'] = Variable<String>(workingDaysCsv.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolSettingsCompanion(')
          ..write('schoolId: $schoolId, ')
          ..write('schoolType: $schoolType, ')
          ..write('district: $district, ')
          ..write('tehsil: $tehsil, ')
          ..write('circleOffice: $circleOffice, ')
          ..write('unionCouncil: $unionCouncil, ')
          ..write('climateZone: $climateZone, ')
          ..write('openingTime: $openingTime, ')
          ..write('closingTime: $closingTime, ')
          ..write('lateCutoffTime: $lateCutoffTime, ')
          ..write('headTeacherName: $headTeacherName, ')
          ..write('deoName: $deoName, ')
          ..write('circleSdeoName: $circleSdeoName, ')
          ..write('centerInchargeName: $centerInchargeName, ')
          ..write('goshwaraNo: $goshwaraNo, ')
          ..write('naConstituency: $naConstituency, ')
          ..write('pkConstituency: $pkConstituency, ')
          ..write('ltrcCenter: $ltrcCenter, ')
          ..write('sanctionedPostsPsht: $sanctionedPostsPsht, ')
          ..write('sanctionedPostsSpst: $sanctionedPostsSpst, ')
          ..write('sanctionedPostsPst: $sanctionedPostsPst, ')
          ..write('vacantPostsPst: $vacantPostsPst, ')
          ..write('vacantPostsChowkidar: $vacantPostsChowkidar, ')
          ..write('classroomsInstructional: $classroomsInstructional, ')
          ..write('classroomsNonInstructional: $classroomsNonInstructional, ')
          ..write('establishmentYear: $establishmentYear, ')
          ..write('constructionYear: $constructionYear, ')
          ..write('facilityElectricity: $facilityElectricity, ')
          ..write('facilityWaterPipe: $facilityWaterPipe, ')
          ..write('facilityWaterWell: $facilityWaterWell, ')
          ..write('facilitySolar: $facilitySolar, ')
          ..write('facilityBoundaryWall: $facilityBoundaryWall, ')
          ..write('facilityPlayArea: $facilityPlayArea, ')
          ..write('facilityOffice: $facilityOffice, ')
          ..write('facilityToiletCount: $facilityToiletCount, ')
          ..write('ptcChairmanName: $ptcChairmanName, ')
          ..write('ptcBankName: $ptcBankName, ')
          ..write('ptcAccountNo: $ptcAccountNo, ')
          ..write('ptcSanctionDate: $ptcSanctionDate, ')
          ..write('fundTotalBudget: $fundTotalBudget, ')
          ..write('fundTotalSpent: $fundTotalSpent, ')
          ..write('workingDaysCsv: $workingDaysCsv, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudentExtendedInfoTable extends StudentExtendedInfo
    with TableInfo<$StudentExtendedInfoTable, StudentExtendedInfoEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentExtendedInfoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentBFormMeta = const VerificationMeta(
    'studentBForm',
  );
  @override
  late final GeneratedColumn<String> studentBForm = GeneratedColumn<String>(
    'student_b_form',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatherCnicMeta = const VerificationMeta(
    'fatherCnic',
  );
  @override
  late final GeneratedColumn<String> fatherCnic = GeneratedColumn<String>(
    'father_cnic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motherNameMeta = const VerificationMeta(
    'motherName',
  );
  @override
  late final GeneratedColumn<String> motherName = GeneratedColumn<String>(
    'mother_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _domicileDistrictMeta = const VerificationMeta(
    'domicileDistrict',
  );
  @override
  late final GeneratedColumn<String> domicileDistrict = GeneratedColumn<String>(
    'domicile_district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leavingDateMeta = const VerificationMeta(
    'leavingDate',
  );
  @override
  late final GeneratedColumn<String> leavingDate = GeneratedColumn<String>(
    'leaving_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leavingReasonMeta = const VerificationMeta(
    'leavingReason',
  );
  @override
  late final GeneratedColumn<String> leavingReason = GeneratedColumn<String>(
    'leaving_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slcNumberMeta = const VerificationMeta(
    'slcNumber',
  );
  @override
  late final GeneratedColumn<String> slcNumber = GeneratedColumn<String>(
    'slc_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _freeBooksIssuedMeta = const VerificationMeta(
    'freeBooksIssued',
  );
  @override
  late final GeneratedColumn<int> freeBooksIssued = GeneratedColumn<int>(
    'free_books_issued',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isVaccinatedMeta = const VerificationMeta(
    'isVaccinated',
  );
  @override
  late final GeneratedColumn<int> isVaccinated = GeneratedColumn<int>(
    'is_vaccinated',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vaccineFirstDoseDateMeta =
      const VerificationMeta('vaccineFirstDoseDate');
  @override
  late final GeneratedColumn<String> vaccineFirstDoseDate =
      GeneratedColumn<String>(
        'vaccine_first_dose_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _vaccineSecondDoseDateMeta =
      const VerificationMeta('vaccineSecondDoseDate');
  @override
  late final GeneratedColumn<String> vaccineSecondDoseDate =
      GeneratedColumn<String>(
        'vaccine_second_dose_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _previousQrTokensJsonMeta =
      const VerificationMeta('previousQrTokensJson');
  @override
  late final GeneratedColumn<String> previousQrTokensJson =
      GeneratedColumn<String>(
        'previous_qr_tokens_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    studentId,
    studentBForm,
    fatherCnic,
    motherName,
    domicileDistrict,
    leavingDate,
    leavingReason,
    slcNumber,
    freeBooksIssued,
    isVaccinated,
    vaccineFirstDoseDate,
    vaccineSecondDoseDate,
    previousQrTokensJson,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_extended_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentExtendedInfoEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('student_b_form')) {
      context.handle(
        _studentBFormMeta,
        studentBForm.isAcceptableOrUnknown(
          data['student_b_form']!,
          _studentBFormMeta,
        ),
      );
    }
    if (data.containsKey('father_cnic')) {
      context.handle(
        _fatherCnicMeta,
        fatherCnic.isAcceptableOrUnknown(data['father_cnic']!, _fatherCnicMeta),
      );
    }
    if (data.containsKey('mother_name')) {
      context.handle(
        _motherNameMeta,
        motherName.isAcceptableOrUnknown(data['mother_name']!, _motherNameMeta),
      );
    }
    if (data.containsKey('domicile_district')) {
      context.handle(
        _domicileDistrictMeta,
        domicileDistrict.isAcceptableOrUnknown(
          data['domicile_district']!,
          _domicileDistrictMeta,
        ),
      );
    }
    if (data.containsKey('leaving_date')) {
      context.handle(
        _leavingDateMeta,
        leavingDate.isAcceptableOrUnknown(
          data['leaving_date']!,
          _leavingDateMeta,
        ),
      );
    }
    if (data.containsKey('leaving_reason')) {
      context.handle(
        _leavingReasonMeta,
        leavingReason.isAcceptableOrUnknown(
          data['leaving_reason']!,
          _leavingReasonMeta,
        ),
      );
    }
    if (data.containsKey('slc_number')) {
      context.handle(
        _slcNumberMeta,
        slcNumber.isAcceptableOrUnknown(data['slc_number']!, _slcNumberMeta),
      );
    }
    if (data.containsKey('free_books_issued')) {
      context.handle(
        _freeBooksIssuedMeta,
        freeBooksIssued.isAcceptableOrUnknown(
          data['free_books_issued']!,
          _freeBooksIssuedMeta,
        ),
      );
    }
    if (data.containsKey('is_vaccinated')) {
      context.handle(
        _isVaccinatedMeta,
        isVaccinated.isAcceptableOrUnknown(
          data['is_vaccinated']!,
          _isVaccinatedMeta,
        ),
      );
    }
    if (data.containsKey('vaccine_first_dose_date')) {
      context.handle(
        _vaccineFirstDoseDateMeta,
        vaccineFirstDoseDate.isAcceptableOrUnknown(
          data['vaccine_first_dose_date']!,
          _vaccineFirstDoseDateMeta,
        ),
      );
    }
    if (data.containsKey('vaccine_second_dose_date')) {
      context.handle(
        _vaccineSecondDoseDateMeta,
        vaccineSecondDoseDate.isAcceptableOrUnknown(
          data['vaccine_second_dose_date']!,
          _vaccineSecondDoseDateMeta,
        ),
      );
    }
    if (data.containsKey('previous_qr_tokens_json')) {
      context.handle(
        _previousQrTokensJsonMeta,
        previousQrTokensJson.isAcceptableOrUnknown(
          data['previous_qr_tokens_json']!,
          _previousQrTokensJsonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {studentId};
  @override
  StudentExtendedInfoEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentExtendedInfoEntry(
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      studentBForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_b_form'],
      ),
      fatherCnic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_cnic'],
      ),
      motherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mother_name'],
      ),
      domicileDistrict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domicile_district'],
      ),
      leavingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leaving_date'],
      ),
      leavingReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leaving_reason'],
      ),
      slcNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slc_number'],
      ),
      freeBooksIssued: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}free_books_issued'],
      )!,
      isVaccinated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_vaccinated'],
      )!,
      vaccineFirstDoseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vaccine_first_dose_date'],
      ),
      vaccineSecondDoseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vaccine_second_dose_date'],
      ),
      previousQrTokensJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_qr_tokens_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $StudentExtendedInfoTable createAlias(String alias) {
    return $StudentExtendedInfoTable(attachedDatabase, alias);
  }
}

class StudentExtendedInfoEntry extends DataClass
    implements Insertable<StudentExtendedInfoEntry> {
  final String studentId;
  final String? studentBForm;
  final String? fatherCnic;
  final String? motherName;
  final String? domicileDistrict;
  final String? leavingDate;
  final String? leavingReason;
  final String? slcNumber;
  final int freeBooksIssued;
  final int isVaccinated;
  final String? vaccineFirstDoseDate;
  final String? vaccineSecondDoseDate;
  final String previousQrTokensJson;
  final int updatedAt;
  final int revision;
  const StudentExtendedInfoEntry({
    required this.studentId,
    this.studentBForm,
    this.fatherCnic,
    this.motherName,
    this.domicileDistrict,
    this.leavingDate,
    this.leavingReason,
    this.slcNumber,
    required this.freeBooksIssued,
    required this.isVaccinated,
    this.vaccineFirstDoseDate,
    this.vaccineSecondDoseDate,
    required this.previousQrTokensJson,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['student_id'] = Variable<String>(studentId);
    if (!nullToAbsent || studentBForm != null) {
      map['student_b_form'] = Variable<String>(studentBForm);
    }
    if (!nullToAbsent || fatherCnic != null) {
      map['father_cnic'] = Variable<String>(fatherCnic);
    }
    if (!nullToAbsent || motherName != null) {
      map['mother_name'] = Variable<String>(motherName);
    }
    if (!nullToAbsent || domicileDistrict != null) {
      map['domicile_district'] = Variable<String>(domicileDistrict);
    }
    if (!nullToAbsent || leavingDate != null) {
      map['leaving_date'] = Variable<String>(leavingDate);
    }
    if (!nullToAbsent || leavingReason != null) {
      map['leaving_reason'] = Variable<String>(leavingReason);
    }
    if (!nullToAbsent || slcNumber != null) {
      map['slc_number'] = Variable<String>(slcNumber);
    }
    map['free_books_issued'] = Variable<int>(freeBooksIssued);
    map['is_vaccinated'] = Variable<int>(isVaccinated);
    if (!nullToAbsent || vaccineFirstDoseDate != null) {
      map['vaccine_first_dose_date'] = Variable<String>(vaccineFirstDoseDate);
    }
    if (!nullToAbsent || vaccineSecondDoseDate != null) {
      map['vaccine_second_dose_date'] = Variable<String>(vaccineSecondDoseDate);
    }
    map['previous_qr_tokens_json'] = Variable<String>(previousQrTokensJson);
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  StudentExtendedInfoCompanion toCompanion(bool nullToAbsent) {
    return StudentExtendedInfoCompanion(
      studentId: Value(studentId),
      studentBForm: studentBForm == null && nullToAbsent
          ? const Value.absent()
          : Value(studentBForm),
      fatherCnic: fatherCnic == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherCnic),
      motherName: motherName == null && nullToAbsent
          ? const Value.absent()
          : Value(motherName),
      domicileDistrict: domicileDistrict == null && nullToAbsent
          ? const Value.absent()
          : Value(domicileDistrict),
      leavingDate: leavingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(leavingDate),
      leavingReason: leavingReason == null && nullToAbsent
          ? const Value.absent()
          : Value(leavingReason),
      slcNumber: slcNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(slcNumber),
      freeBooksIssued: Value(freeBooksIssued),
      isVaccinated: Value(isVaccinated),
      vaccineFirstDoseDate: vaccineFirstDoseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(vaccineFirstDoseDate),
      vaccineSecondDoseDate: vaccineSecondDoseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(vaccineSecondDoseDate),
      previousQrTokensJson: Value(previousQrTokensJson),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory StudentExtendedInfoEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentExtendedInfoEntry(
      studentId: serializer.fromJson<String>(json['studentId']),
      studentBForm: serializer.fromJson<String?>(json['studentBForm']),
      fatherCnic: serializer.fromJson<String?>(json['fatherCnic']),
      motherName: serializer.fromJson<String?>(json['motherName']),
      domicileDistrict: serializer.fromJson<String?>(json['domicileDistrict']),
      leavingDate: serializer.fromJson<String?>(json['leavingDate']),
      leavingReason: serializer.fromJson<String?>(json['leavingReason']),
      slcNumber: serializer.fromJson<String?>(json['slcNumber']),
      freeBooksIssued: serializer.fromJson<int>(json['freeBooksIssued']),
      isVaccinated: serializer.fromJson<int>(json['isVaccinated']),
      vaccineFirstDoseDate: serializer.fromJson<String?>(
        json['vaccineFirstDoseDate'],
      ),
      vaccineSecondDoseDate: serializer.fromJson<String?>(
        json['vaccineSecondDoseDate'],
      ),
      previousQrTokensJson: serializer.fromJson<String>(
        json['previousQrTokensJson'],
      ),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'studentId': serializer.toJson<String>(studentId),
      'studentBForm': serializer.toJson<String?>(studentBForm),
      'fatherCnic': serializer.toJson<String?>(fatherCnic),
      'motherName': serializer.toJson<String?>(motherName),
      'domicileDistrict': serializer.toJson<String?>(domicileDistrict),
      'leavingDate': serializer.toJson<String?>(leavingDate),
      'leavingReason': serializer.toJson<String?>(leavingReason),
      'slcNumber': serializer.toJson<String?>(slcNumber),
      'freeBooksIssued': serializer.toJson<int>(freeBooksIssued),
      'isVaccinated': serializer.toJson<int>(isVaccinated),
      'vaccineFirstDoseDate': serializer.toJson<String?>(vaccineFirstDoseDate),
      'vaccineSecondDoseDate': serializer.toJson<String?>(
        vaccineSecondDoseDate,
      ),
      'previousQrTokensJson': serializer.toJson<String>(previousQrTokensJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  StudentExtendedInfoEntry copyWith({
    String? studentId,
    Value<String?> studentBForm = const Value.absent(),
    Value<String?> fatherCnic = const Value.absent(),
    Value<String?> motherName = const Value.absent(),
    Value<String?> domicileDistrict = const Value.absent(),
    Value<String?> leavingDate = const Value.absent(),
    Value<String?> leavingReason = const Value.absent(),
    Value<String?> slcNumber = const Value.absent(),
    int? freeBooksIssued,
    int? isVaccinated,
    Value<String?> vaccineFirstDoseDate = const Value.absent(),
    Value<String?> vaccineSecondDoseDate = const Value.absent(),
    String? previousQrTokensJson,
    int? updatedAt,
    int? revision,
  }) => StudentExtendedInfoEntry(
    studentId: studentId ?? this.studentId,
    studentBForm: studentBForm.present ? studentBForm.value : this.studentBForm,
    fatherCnic: fatherCnic.present ? fatherCnic.value : this.fatherCnic,
    motherName: motherName.present ? motherName.value : this.motherName,
    domicileDistrict: domicileDistrict.present
        ? domicileDistrict.value
        : this.domicileDistrict,
    leavingDate: leavingDate.present ? leavingDate.value : this.leavingDate,
    leavingReason: leavingReason.present
        ? leavingReason.value
        : this.leavingReason,
    slcNumber: slcNumber.present ? slcNumber.value : this.slcNumber,
    freeBooksIssued: freeBooksIssued ?? this.freeBooksIssued,
    isVaccinated: isVaccinated ?? this.isVaccinated,
    vaccineFirstDoseDate: vaccineFirstDoseDate.present
        ? vaccineFirstDoseDate.value
        : this.vaccineFirstDoseDate,
    vaccineSecondDoseDate: vaccineSecondDoseDate.present
        ? vaccineSecondDoseDate.value
        : this.vaccineSecondDoseDate,
    previousQrTokensJson: previousQrTokensJson ?? this.previousQrTokensJson,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  StudentExtendedInfoEntry copyWithCompanion(
    StudentExtendedInfoCompanion data,
  ) {
    return StudentExtendedInfoEntry(
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      studentBForm: data.studentBForm.present
          ? data.studentBForm.value
          : this.studentBForm,
      fatherCnic: data.fatherCnic.present
          ? data.fatherCnic.value
          : this.fatherCnic,
      motherName: data.motherName.present
          ? data.motherName.value
          : this.motherName,
      domicileDistrict: data.domicileDistrict.present
          ? data.domicileDistrict.value
          : this.domicileDistrict,
      leavingDate: data.leavingDate.present
          ? data.leavingDate.value
          : this.leavingDate,
      leavingReason: data.leavingReason.present
          ? data.leavingReason.value
          : this.leavingReason,
      slcNumber: data.slcNumber.present ? data.slcNumber.value : this.slcNumber,
      freeBooksIssued: data.freeBooksIssued.present
          ? data.freeBooksIssued.value
          : this.freeBooksIssued,
      isVaccinated: data.isVaccinated.present
          ? data.isVaccinated.value
          : this.isVaccinated,
      vaccineFirstDoseDate: data.vaccineFirstDoseDate.present
          ? data.vaccineFirstDoseDate.value
          : this.vaccineFirstDoseDate,
      vaccineSecondDoseDate: data.vaccineSecondDoseDate.present
          ? data.vaccineSecondDoseDate.value
          : this.vaccineSecondDoseDate,
      previousQrTokensJson: data.previousQrTokensJson.present
          ? data.previousQrTokensJson.value
          : this.previousQrTokensJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentExtendedInfoEntry(')
          ..write('studentId: $studentId, ')
          ..write('studentBForm: $studentBForm, ')
          ..write('fatherCnic: $fatherCnic, ')
          ..write('motherName: $motherName, ')
          ..write('domicileDistrict: $domicileDistrict, ')
          ..write('leavingDate: $leavingDate, ')
          ..write('leavingReason: $leavingReason, ')
          ..write('slcNumber: $slcNumber, ')
          ..write('freeBooksIssued: $freeBooksIssued, ')
          ..write('isVaccinated: $isVaccinated, ')
          ..write('vaccineFirstDoseDate: $vaccineFirstDoseDate, ')
          ..write('vaccineSecondDoseDate: $vaccineSecondDoseDate, ')
          ..write('previousQrTokensJson: $previousQrTokensJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    studentId,
    studentBForm,
    fatherCnic,
    motherName,
    domicileDistrict,
    leavingDate,
    leavingReason,
    slcNumber,
    freeBooksIssued,
    isVaccinated,
    vaccineFirstDoseDate,
    vaccineSecondDoseDate,
    previousQrTokensJson,
    updatedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentExtendedInfoEntry &&
          other.studentId == this.studentId &&
          other.studentBForm == this.studentBForm &&
          other.fatherCnic == this.fatherCnic &&
          other.motherName == this.motherName &&
          other.domicileDistrict == this.domicileDistrict &&
          other.leavingDate == this.leavingDate &&
          other.leavingReason == this.leavingReason &&
          other.slcNumber == this.slcNumber &&
          other.freeBooksIssued == this.freeBooksIssued &&
          other.isVaccinated == this.isVaccinated &&
          other.vaccineFirstDoseDate == this.vaccineFirstDoseDate &&
          other.vaccineSecondDoseDate == this.vaccineSecondDoseDate &&
          other.previousQrTokensJson == this.previousQrTokensJson &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class StudentExtendedInfoCompanion
    extends UpdateCompanion<StudentExtendedInfoEntry> {
  final Value<String> studentId;
  final Value<String?> studentBForm;
  final Value<String?> fatherCnic;
  final Value<String?> motherName;
  final Value<String?> domicileDistrict;
  final Value<String?> leavingDate;
  final Value<String?> leavingReason;
  final Value<String?> slcNumber;
  final Value<int> freeBooksIssued;
  final Value<int> isVaccinated;
  final Value<String?> vaccineFirstDoseDate;
  final Value<String?> vaccineSecondDoseDate;
  final Value<String> previousQrTokensJson;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const StudentExtendedInfoCompanion({
    this.studentId = const Value.absent(),
    this.studentBForm = const Value.absent(),
    this.fatherCnic = const Value.absent(),
    this.motherName = const Value.absent(),
    this.domicileDistrict = const Value.absent(),
    this.leavingDate = const Value.absent(),
    this.leavingReason = const Value.absent(),
    this.slcNumber = const Value.absent(),
    this.freeBooksIssued = const Value.absent(),
    this.isVaccinated = const Value.absent(),
    this.vaccineFirstDoseDate = const Value.absent(),
    this.vaccineSecondDoseDate = const Value.absent(),
    this.previousQrTokensJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentExtendedInfoCompanion.insert({
    required String studentId,
    this.studentBForm = const Value.absent(),
    this.fatherCnic = const Value.absent(),
    this.motherName = const Value.absent(),
    this.domicileDistrict = const Value.absent(),
    this.leavingDate = const Value.absent(),
    this.leavingReason = const Value.absent(),
    this.slcNumber = const Value.absent(),
    this.freeBooksIssued = const Value.absent(),
    this.isVaccinated = const Value.absent(),
    this.vaccineFirstDoseDate = const Value.absent(),
    this.vaccineSecondDoseDate = const Value.absent(),
    this.previousQrTokensJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : studentId = Value(studentId);
  static Insertable<StudentExtendedInfoEntry> custom({
    Expression<String>? studentId,
    Expression<String>? studentBForm,
    Expression<String>? fatherCnic,
    Expression<String>? motherName,
    Expression<String>? domicileDistrict,
    Expression<String>? leavingDate,
    Expression<String>? leavingReason,
    Expression<String>? slcNumber,
    Expression<int>? freeBooksIssued,
    Expression<int>? isVaccinated,
    Expression<String>? vaccineFirstDoseDate,
    Expression<String>? vaccineSecondDoseDate,
    Expression<String>? previousQrTokensJson,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (studentId != null) 'student_id': studentId,
      if (studentBForm != null) 'student_b_form': studentBForm,
      if (fatherCnic != null) 'father_cnic': fatherCnic,
      if (motherName != null) 'mother_name': motherName,
      if (domicileDistrict != null) 'domicile_district': domicileDistrict,
      if (leavingDate != null) 'leaving_date': leavingDate,
      if (leavingReason != null) 'leaving_reason': leavingReason,
      if (slcNumber != null) 'slc_number': slcNumber,
      if (freeBooksIssued != null) 'free_books_issued': freeBooksIssued,
      if (isVaccinated != null) 'is_vaccinated': isVaccinated,
      if (vaccineFirstDoseDate != null)
        'vaccine_first_dose_date': vaccineFirstDoseDate,
      if (vaccineSecondDoseDate != null)
        'vaccine_second_dose_date': vaccineSecondDoseDate,
      if (previousQrTokensJson != null)
        'previous_qr_tokens_json': previousQrTokensJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentExtendedInfoCompanion copyWith({
    Value<String>? studentId,
    Value<String?>? studentBForm,
    Value<String?>? fatherCnic,
    Value<String?>? motherName,
    Value<String?>? domicileDistrict,
    Value<String?>? leavingDate,
    Value<String?>? leavingReason,
    Value<String?>? slcNumber,
    Value<int>? freeBooksIssued,
    Value<int>? isVaccinated,
    Value<String?>? vaccineFirstDoseDate,
    Value<String?>? vaccineSecondDoseDate,
    Value<String>? previousQrTokensJson,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return StudentExtendedInfoCompanion(
      studentId: studentId ?? this.studentId,
      studentBForm: studentBForm ?? this.studentBForm,
      fatherCnic: fatherCnic ?? this.fatherCnic,
      motherName: motherName ?? this.motherName,
      domicileDistrict: domicileDistrict ?? this.domicileDistrict,
      leavingDate: leavingDate ?? this.leavingDate,
      leavingReason: leavingReason ?? this.leavingReason,
      slcNumber: slcNumber ?? this.slcNumber,
      freeBooksIssued: freeBooksIssued ?? this.freeBooksIssued,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      vaccineFirstDoseDate: vaccineFirstDoseDate ?? this.vaccineFirstDoseDate,
      vaccineSecondDoseDate:
          vaccineSecondDoseDate ?? this.vaccineSecondDoseDate,
      previousQrTokensJson: previousQrTokensJson ?? this.previousQrTokensJson,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (studentBForm.present) {
      map['student_b_form'] = Variable<String>(studentBForm.value);
    }
    if (fatherCnic.present) {
      map['father_cnic'] = Variable<String>(fatherCnic.value);
    }
    if (motherName.present) {
      map['mother_name'] = Variable<String>(motherName.value);
    }
    if (domicileDistrict.present) {
      map['domicile_district'] = Variable<String>(domicileDistrict.value);
    }
    if (leavingDate.present) {
      map['leaving_date'] = Variable<String>(leavingDate.value);
    }
    if (leavingReason.present) {
      map['leaving_reason'] = Variable<String>(leavingReason.value);
    }
    if (slcNumber.present) {
      map['slc_number'] = Variable<String>(slcNumber.value);
    }
    if (freeBooksIssued.present) {
      map['free_books_issued'] = Variable<int>(freeBooksIssued.value);
    }
    if (isVaccinated.present) {
      map['is_vaccinated'] = Variable<int>(isVaccinated.value);
    }
    if (vaccineFirstDoseDate.present) {
      map['vaccine_first_dose_date'] = Variable<String>(
        vaccineFirstDoseDate.value,
      );
    }
    if (vaccineSecondDoseDate.present) {
      map['vaccine_second_dose_date'] = Variable<String>(
        vaccineSecondDoseDate.value,
      );
    }
    if (previousQrTokensJson.present) {
      map['previous_qr_tokens_json'] = Variable<String>(
        previousQrTokensJson.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentExtendedInfoCompanion(')
          ..write('studentId: $studentId, ')
          ..write('studentBForm: $studentBForm, ')
          ..write('fatherCnic: $fatherCnic, ')
          ..write('motherName: $motherName, ')
          ..write('domicileDistrict: $domicileDistrict, ')
          ..write('leavingDate: $leavingDate, ')
          ..write('leavingReason: $leavingReason, ')
          ..write('slcNumber: $slcNumber, ')
          ..write('freeBooksIssued: $freeBooksIssued, ')
          ..write('isVaccinated: $isVaccinated, ')
          ..write('vaccineFirstDoseDate: $vaccineFirstDoseDate, ')
          ..write('vaccineSecondDoseDate: $vaccineSecondDoseDate, ')
          ..write('previousQrTokensJson: $previousQrTokensJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceSessionsTable extends AttendanceSessions
    with TableInfo<$AttendanceSessionsTable, AttendanceSessionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _finalizedByUserIdMeta = const VerificationMeta(
    'finalizedByUserId',
  );
  @override
  late final GeneratedColumn<String> finalizedByUserId =
      GeneratedColumn<String>(
        'finalized_by_user_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _finalizedAtMeta = const VerificationMeta(
    'finalizedAt',
  );
  @override
  late final GeneratedColumn<int> finalizedAt = GeneratedColumn<int>(
    'finalized_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    classId,
    sectionId,
    date,
    status,
    finalizedByUserId,
    finalizedAt,
    notes,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceSessionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('finalized_by_user_id')) {
      context.handle(
        _finalizedByUserIdMeta,
        finalizedByUserId.isAcceptableOrUnknown(
          data['finalized_by_user_id']!,
          _finalizedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('finalized_at')) {
      context.handle(
        _finalizedAtMeta,
        finalizedAt.isAcceptableOrUnknown(
          data['finalized_at']!,
          _finalizedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sectionId, date},
  ];
  @override
  AttendanceSessionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceSessionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      finalizedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finalized_by_user_id'],
      ),
      finalizedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finalized_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $AttendanceSessionsTable createAlias(String alias) {
    return $AttendanceSessionsTable(attachedDatabase, alias);
  }
}

class AttendanceSessionEntry extends DataClass
    implements Insertable<AttendanceSessionEntry> {
  final String id;
  final String schoolId;
  final String classId;
  final String sectionId;
  final String date;
  final String status;
  final String? finalizedByUserId;
  final int? finalizedAt;
  final String? notes;
  final int updatedAt;
  final int revision;
  const AttendanceSessionEntry({
    required this.id,
    required this.schoolId,
    required this.classId,
    required this.sectionId,
    required this.date,
    required this.status,
    this.finalizedByUserId,
    this.finalizedAt,
    this.notes,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['class_id'] = Variable<String>(classId);
    map['section_id'] = Variable<String>(sectionId);
    map['date'] = Variable<String>(date);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || finalizedByUserId != null) {
      map['finalized_by_user_id'] = Variable<String>(finalizedByUserId);
    }
    if (!nullToAbsent || finalizedAt != null) {
      map['finalized_at'] = Variable<int>(finalizedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  AttendanceSessionsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceSessionsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      classId: Value(classId),
      sectionId: Value(sectionId),
      date: Value(date),
      status: Value(status),
      finalizedByUserId: finalizedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(finalizedByUserId),
      finalizedAt: finalizedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finalizedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory AttendanceSessionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceSessionEntry(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      classId: serializer.fromJson<String>(json['classId']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      date: serializer.fromJson<String>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      finalizedByUserId: serializer.fromJson<String?>(
        json['finalizedByUserId'],
      ),
      finalizedAt: serializer.fromJson<int?>(json['finalizedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'classId': serializer.toJson<String>(classId),
      'sectionId': serializer.toJson<String>(sectionId),
      'date': serializer.toJson<String>(date),
      'status': serializer.toJson<String>(status),
      'finalizedByUserId': serializer.toJson<String?>(finalizedByUserId),
      'finalizedAt': serializer.toJson<int?>(finalizedAt),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  AttendanceSessionEntry copyWith({
    String? id,
    String? schoolId,
    String? classId,
    String? sectionId,
    String? date,
    String? status,
    Value<String?> finalizedByUserId = const Value.absent(),
    Value<int?> finalizedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? updatedAt,
    int? revision,
  }) => AttendanceSessionEntry(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    classId: classId ?? this.classId,
    sectionId: sectionId ?? this.sectionId,
    date: date ?? this.date,
    status: status ?? this.status,
    finalizedByUserId: finalizedByUserId.present
        ? finalizedByUserId.value
        : this.finalizedByUserId,
    finalizedAt: finalizedAt.present ? finalizedAt.value : this.finalizedAt,
    notes: notes.present ? notes.value : this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  AttendanceSessionEntry copyWithCompanion(AttendanceSessionsCompanion data) {
    return AttendanceSessionEntry(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      classId: data.classId.present ? data.classId.value : this.classId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      finalizedByUserId: data.finalizedByUserId.present
          ? data.finalizedByUserId.value
          : this.finalizedByUserId,
      finalizedAt: data.finalizedAt.present
          ? data.finalizedAt.value
          : this.finalizedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceSessionEntry(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('classId: $classId, ')
          ..write('sectionId: $sectionId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('finalizedByUserId: $finalizedByUserId, ')
          ..write('finalizedAt: $finalizedAt, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    classId,
    sectionId,
    date,
    status,
    finalizedByUserId,
    finalizedAt,
    notes,
    updatedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceSessionEntry &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.classId == this.classId &&
          other.sectionId == this.sectionId &&
          other.date == this.date &&
          other.status == this.status &&
          other.finalizedByUserId == this.finalizedByUserId &&
          other.finalizedAt == this.finalizedAt &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class AttendanceSessionsCompanion
    extends UpdateCompanion<AttendanceSessionEntry> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> classId;
  final Value<String> sectionId;
  final Value<String> date;
  final Value<String> status;
  final Value<String?> finalizedByUserId;
  final Value<int?> finalizedAt;
  final Value<String?> notes;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const AttendanceSessionsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.classId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.finalizedByUserId = const Value.absent(),
    this.finalizedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceSessionsCompanion.insert({
    required String id,
    required String schoolId,
    required String classId,
    required String sectionId,
    required String date,
    this.status = const Value.absent(),
    this.finalizedByUserId = const Value.absent(),
    this.finalizedAt = const Value.absent(),
    this.notes = const Value.absent(),
    required int updatedAt,
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       classId = Value(classId),
       sectionId = Value(sectionId),
       date = Value(date),
       updatedAt = Value(updatedAt);
  static Insertable<AttendanceSessionEntry> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? classId,
    Expression<String>? sectionId,
    Expression<String>? date,
    Expression<String>? status,
    Expression<String>? finalizedByUserId,
    Expression<int>? finalizedAt,
    Expression<String>? notes,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (classId != null) 'class_id': classId,
      if (sectionId != null) 'section_id': sectionId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (finalizedByUserId != null) 'finalized_by_user_id': finalizedByUserId,
      if (finalizedAt != null) 'finalized_at': finalizedAt,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? classId,
    Value<String>? sectionId,
    Value<String>? date,
    Value<String>? status,
    Value<String?>? finalizedByUserId,
    Value<int?>? finalizedAt,
    Value<String?>? notes,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return AttendanceSessionsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      classId: classId ?? this.classId,
      sectionId: sectionId ?? this.sectionId,
      date: date ?? this.date,
      status: status ?? this.status,
      finalizedByUserId: finalizedByUserId ?? this.finalizedByUserId,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (finalizedByUserId.present) {
      map['finalized_by_user_id'] = Variable<String>(finalizedByUserId.value);
    }
    if (finalizedAt.present) {
      map['finalized_at'] = Variable<int>(finalizedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceSessionsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('classId: $classId, ')
          ..write('sectionId: $sectionId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('finalizedByUserId: $finalizedByUserId, ')
          ..write('finalizedAt: $finalizedAt, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CorrectionRequestsTable extends CorrectionRequests
    with TableInfo<$CorrectionRequestsTable, CorrectionRequestEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CorrectionRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attendanceRecordIdMeta =
      const VerificationMeta('attendanceRecordId');
  @override
  late final GeneratedColumn<String> attendanceRecordId =
      GeneratedColumn<String>(
        'attendance_record_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentNameMeta = const VerificationMeta(
    'studentName',
  );
  @override
  late final GeneratedColumn<String> studentName = GeneratedColumn<String>(
    'student_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldStatusMeta = const VerificationMeta(
    'oldStatus',
  );
  @override
  late final GeneratedColumn<String> oldStatus = GeneratedColumn<String>(
    'old_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proposedStatusMeta = const VerificationMeta(
    'proposedStatus',
  );
  @override
  late final GeneratedColumn<String> proposedStatus = GeneratedColumn<String>(
    'proposed_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestedByUserIdMeta = const VerificationMeta(
    'requestedByUserId',
  );
  @override
  late final GeneratedColumn<String> requestedByUserId =
      GeneratedColumn<String>(
        'requested_by_user_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _requestedByNameMeta = const VerificationMeta(
    'requestedByName',
  );
  @override
  late final GeneratedColumn<String> requestedByName = GeneratedColumn<String>(
    'requested_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _reviewedByUserIdMeta = const VerificationMeta(
    'reviewedByUserId',
  );
  @override
  late final GeneratedColumn<String> reviewedByUserId = GeneratedColumn<String>(
    'reviewed_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewRemarksMeta = const VerificationMeta(
    'reviewRemarks',
  );
  @override
  late final GeneratedColumn<String> reviewRemarks = GeneratedColumn<String>(
    'review_remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    attendanceRecordId,
    studentId,
    studentName,
    classId,
    sectionId,
    date,
    oldStatus,
    proposedStatus,
    reason,
    requestedByUserId,
    requestedByName,
    status,
    reviewedByUserId,
    reviewRemarks,
    createdAt,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'correction_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<CorrectionRequestEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('attendance_record_id')) {
      context.handle(
        _attendanceRecordIdMeta,
        attendanceRecordId.isAcceptableOrUnknown(
          data['attendance_record_id']!,
          _attendanceRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attendanceRecordIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('student_name')) {
      context.handle(
        _studentNameMeta,
        studentName.isAcceptableOrUnknown(
          data['student_name']!,
          _studentNameMeta,
        ),
      );
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('old_status')) {
      context.handle(
        _oldStatusMeta,
        oldStatus.isAcceptableOrUnknown(data['old_status']!, _oldStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_oldStatusMeta);
    }
    if (data.containsKey('proposed_status')) {
      context.handle(
        _proposedStatusMeta,
        proposedStatus.isAcceptableOrUnknown(
          data['proposed_status']!,
          _proposedStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proposedStatusMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('requested_by_user_id')) {
      context.handle(
        _requestedByUserIdMeta,
        requestedByUserId.isAcceptableOrUnknown(
          data['requested_by_user_id']!,
          _requestedByUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedByUserIdMeta);
    }
    if (data.containsKey('requested_by_name')) {
      context.handle(
        _requestedByNameMeta,
        requestedByName.isAcceptableOrUnknown(
          data['requested_by_name']!,
          _requestedByNameMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('reviewed_by_user_id')) {
      context.handle(
        _reviewedByUserIdMeta,
        reviewedByUserId.isAcceptableOrUnknown(
          data['reviewed_by_user_id']!,
          _reviewedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('review_remarks')) {
      context.handle(
        _reviewRemarksMeta,
        reviewRemarks.isAcceptableOrUnknown(
          data['review_remarks']!,
          _reviewRemarksMeta,
        ),
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
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CorrectionRequestEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CorrectionRequestEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      attendanceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendance_record_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      studentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_name'],
      ),
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      oldStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_status'],
      )!,
      proposedStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposed_status'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      requestedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_by_user_id'],
      )!,
      requestedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_by_name'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      reviewedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewed_by_user_id'],
      ),
      reviewRemarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_remarks'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $CorrectionRequestsTable createAlias(String alias) {
    return $CorrectionRequestsTable(attachedDatabase, alias);
  }
}

class CorrectionRequestEntry extends DataClass
    implements Insertable<CorrectionRequestEntry> {
  final String id;
  final String schoolId;
  final String attendanceRecordId;
  final String studentId;
  final String? studentName;
  final String classId;
  final String sectionId;
  final String date;
  final String oldStatus;
  final String proposedStatus;
  final String reason;
  final String requestedByUserId;
  final String? requestedByName;
  final String status;
  final String? reviewedByUserId;
  final String? reviewRemarks;
  final int createdAt;
  final int updatedAt;
  final int revision;
  const CorrectionRequestEntry({
    required this.id,
    required this.schoolId,
    required this.attendanceRecordId,
    required this.studentId,
    this.studentName,
    required this.classId,
    required this.sectionId,
    required this.date,
    required this.oldStatus,
    required this.proposedStatus,
    required this.reason,
    required this.requestedByUserId,
    this.requestedByName,
    required this.status,
    this.reviewedByUserId,
    this.reviewRemarks,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['attendance_record_id'] = Variable<String>(attendanceRecordId);
    map['student_id'] = Variable<String>(studentId);
    if (!nullToAbsent || studentName != null) {
      map['student_name'] = Variable<String>(studentName);
    }
    map['class_id'] = Variable<String>(classId);
    map['section_id'] = Variable<String>(sectionId);
    map['date'] = Variable<String>(date);
    map['old_status'] = Variable<String>(oldStatus);
    map['proposed_status'] = Variable<String>(proposedStatus);
    map['reason'] = Variable<String>(reason);
    map['requested_by_user_id'] = Variable<String>(requestedByUserId);
    if (!nullToAbsent || requestedByName != null) {
      map['requested_by_name'] = Variable<String>(requestedByName);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || reviewedByUserId != null) {
      map['reviewed_by_user_id'] = Variable<String>(reviewedByUserId);
    }
    if (!nullToAbsent || reviewRemarks != null) {
      map['review_remarks'] = Variable<String>(reviewRemarks);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  CorrectionRequestsCompanion toCompanion(bool nullToAbsent) {
    return CorrectionRequestsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      attendanceRecordId: Value(attendanceRecordId),
      studentId: Value(studentId),
      studentName: studentName == null && nullToAbsent
          ? const Value.absent()
          : Value(studentName),
      classId: Value(classId),
      sectionId: Value(sectionId),
      date: Value(date),
      oldStatus: Value(oldStatus),
      proposedStatus: Value(proposedStatus),
      reason: Value(reason),
      requestedByUserId: Value(requestedByUserId),
      requestedByName: requestedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(requestedByName),
      status: Value(status),
      reviewedByUserId: reviewedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedByUserId),
      reviewRemarks: reviewRemarks == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewRemarks),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory CorrectionRequestEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CorrectionRequestEntry(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      attendanceRecordId: serializer.fromJson<String>(
        json['attendanceRecordId'],
      ),
      studentId: serializer.fromJson<String>(json['studentId']),
      studentName: serializer.fromJson<String?>(json['studentName']),
      classId: serializer.fromJson<String>(json['classId']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      date: serializer.fromJson<String>(json['date']),
      oldStatus: serializer.fromJson<String>(json['oldStatus']),
      proposedStatus: serializer.fromJson<String>(json['proposedStatus']),
      reason: serializer.fromJson<String>(json['reason']),
      requestedByUserId: serializer.fromJson<String>(json['requestedByUserId']),
      requestedByName: serializer.fromJson<String?>(json['requestedByName']),
      status: serializer.fromJson<String>(json['status']),
      reviewedByUserId: serializer.fromJson<String?>(json['reviewedByUserId']),
      reviewRemarks: serializer.fromJson<String?>(json['reviewRemarks']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'attendanceRecordId': serializer.toJson<String>(attendanceRecordId),
      'studentId': serializer.toJson<String>(studentId),
      'studentName': serializer.toJson<String?>(studentName),
      'classId': serializer.toJson<String>(classId),
      'sectionId': serializer.toJson<String>(sectionId),
      'date': serializer.toJson<String>(date),
      'oldStatus': serializer.toJson<String>(oldStatus),
      'proposedStatus': serializer.toJson<String>(proposedStatus),
      'reason': serializer.toJson<String>(reason),
      'requestedByUserId': serializer.toJson<String>(requestedByUserId),
      'requestedByName': serializer.toJson<String?>(requestedByName),
      'status': serializer.toJson<String>(status),
      'reviewedByUserId': serializer.toJson<String?>(reviewedByUserId),
      'reviewRemarks': serializer.toJson<String?>(reviewRemarks),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  CorrectionRequestEntry copyWith({
    String? id,
    String? schoolId,
    String? attendanceRecordId,
    String? studentId,
    Value<String?> studentName = const Value.absent(),
    String? classId,
    String? sectionId,
    String? date,
    String? oldStatus,
    String? proposedStatus,
    String? reason,
    String? requestedByUserId,
    Value<String?> requestedByName = const Value.absent(),
    String? status,
    Value<String?> reviewedByUserId = const Value.absent(),
    Value<String?> reviewRemarks = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    int? revision,
  }) => CorrectionRequestEntry(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    attendanceRecordId: attendanceRecordId ?? this.attendanceRecordId,
    studentId: studentId ?? this.studentId,
    studentName: studentName.present ? studentName.value : this.studentName,
    classId: classId ?? this.classId,
    sectionId: sectionId ?? this.sectionId,
    date: date ?? this.date,
    oldStatus: oldStatus ?? this.oldStatus,
    proposedStatus: proposedStatus ?? this.proposedStatus,
    reason: reason ?? this.reason,
    requestedByUserId: requestedByUserId ?? this.requestedByUserId,
    requestedByName: requestedByName.present
        ? requestedByName.value
        : this.requestedByName,
    status: status ?? this.status,
    reviewedByUserId: reviewedByUserId.present
        ? reviewedByUserId.value
        : this.reviewedByUserId,
    reviewRemarks: reviewRemarks.present
        ? reviewRemarks.value
        : this.reviewRemarks,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  CorrectionRequestEntry copyWithCompanion(CorrectionRequestsCompanion data) {
    return CorrectionRequestEntry(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      attendanceRecordId: data.attendanceRecordId.present
          ? data.attendanceRecordId.value
          : this.attendanceRecordId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      studentName: data.studentName.present
          ? data.studentName.value
          : this.studentName,
      classId: data.classId.present ? data.classId.value : this.classId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      date: data.date.present ? data.date.value : this.date,
      oldStatus: data.oldStatus.present ? data.oldStatus.value : this.oldStatus,
      proposedStatus: data.proposedStatus.present
          ? data.proposedStatus.value
          : this.proposedStatus,
      reason: data.reason.present ? data.reason.value : this.reason,
      requestedByUserId: data.requestedByUserId.present
          ? data.requestedByUserId.value
          : this.requestedByUserId,
      requestedByName: data.requestedByName.present
          ? data.requestedByName.value
          : this.requestedByName,
      status: data.status.present ? data.status.value : this.status,
      reviewedByUserId: data.reviewedByUserId.present
          ? data.reviewedByUserId.value
          : this.reviewedByUserId,
      reviewRemarks: data.reviewRemarks.present
          ? data.reviewRemarks.value
          : this.reviewRemarks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CorrectionRequestEntry(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('attendanceRecordId: $attendanceRecordId, ')
          ..write('studentId: $studentId, ')
          ..write('studentName: $studentName, ')
          ..write('classId: $classId, ')
          ..write('sectionId: $sectionId, ')
          ..write('date: $date, ')
          ..write('oldStatus: $oldStatus, ')
          ..write('proposedStatus: $proposedStatus, ')
          ..write('reason: $reason, ')
          ..write('requestedByUserId: $requestedByUserId, ')
          ..write('requestedByName: $requestedByName, ')
          ..write('status: $status, ')
          ..write('reviewedByUserId: $reviewedByUserId, ')
          ..write('reviewRemarks: $reviewRemarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    attendanceRecordId,
    studentId,
    studentName,
    classId,
    sectionId,
    date,
    oldStatus,
    proposedStatus,
    reason,
    requestedByUserId,
    requestedByName,
    status,
    reviewedByUserId,
    reviewRemarks,
    createdAt,
    updatedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CorrectionRequestEntry &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.attendanceRecordId == this.attendanceRecordId &&
          other.studentId == this.studentId &&
          other.studentName == this.studentName &&
          other.classId == this.classId &&
          other.sectionId == this.sectionId &&
          other.date == this.date &&
          other.oldStatus == this.oldStatus &&
          other.proposedStatus == this.proposedStatus &&
          other.reason == this.reason &&
          other.requestedByUserId == this.requestedByUserId &&
          other.requestedByName == this.requestedByName &&
          other.status == this.status &&
          other.reviewedByUserId == this.reviewedByUserId &&
          other.reviewRemarks == this.reviewRemarks &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class CorrectionRequestsCompanion
    extends UpdateCompanion<CorrectionRequestEntry> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> attendanceRecordId;
  final Value<String> studentId;
  final Value<String?> studentName;
  final Value<String> classId;
  final Value<String> sectionId;
  final Value<String> date;
  final Value<String> oldStatus;
  final Value<String> proposedStatus;
  final Value<String> reason;
  final Value<String> requestedByUserId;
  final Value<String?> requestedByName;
  final Value<String> status;
  final Value<String?> reviewedByUserId;
  final Value<String?> reviewRemarks;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const CorrectionRequestsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.attendanceRecordId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.studentName = const Value.absent(),
    this.classId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.date = const Value.absent(),
    this.oldStatus = const Value.absent(),
    this.proposedStatus = const Value.absent(),
    this.reason = const Value.absent(),
    this.requestedByUserId = const Value.absent(),
    this.requestedByName = const Value.absent(),
    this.status = const Value.absent(),
    this.reviewedByUserId = const Value.absent(),
    this.reviewRemarks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CorrectionRequestsCompanion.insert({
    required String id,
    required String schoolId,
    required String attendanceRecordId,
    required String studentId,
    this.studentName = const Value.absent(),
    required String classId,
    required String sectionId,
    required String date,
    required String oldStatus,
    required String proposedStatus,
    required String reason,
    required String requestedByUserId,
    this.requestedByName = const Value.absent(),
    this.status = const Value.absent(),
    this.reviewedByUserId = const Value.absent(),
    this.reviewRemarks = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       attendanceRecordId = Value(attendanceRecordId),
       studentId = Value(studentId),
       classId = Value(classId),
       sectionId = Value(sectionId),
       date = Value(date),
       oldStatus = Value(oldStatus),
       proposedStatus = Value(proposedStatus),
       reason = Value(reason),
       requestedByUserId = Value(requestedByUserId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CorrectionRequestEntry> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? attendanceRecordId,
    Expression<String>? studentId,
    Expression<String>? studentName,
    Expression<String>? classId,
    Expression<String>? sectionId,
    Expression<String>? date,
    Expression<String>? oldStatus,
    Expression<String>? proposedStatus,
    Expression<String>? reason,
    Expression<String>? requestedByUserId,
    Expression<String>? requestedByName,
    Expression<String>? status,
    Expression<String>? reviewedByUserId,
    Expression<String>? reviewRemarks,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (attendanceRecordId != null)
        'attendance_record_id': attendanceRecordId,
      if (studentId != null) 'student_id': studentId,
      if (studentName != null) 'student_name': studentName,
      if (classId != null) 'class_id': classId,
      if (sectionId != null) 'section_id': sectionId,
      if (date != null) 'date': date,
      if (oldStatus != null) 'old_status': oldStatus,
      if (proposedStatus != null) 'proposed_status': proposedStatus,
      if (reason != null) 'reason': reason,
      if (requestedByUserId != null) 'requested_by_user_id': requestedByUserId,
      if (requestedByName != null) 'requested_by_name': requestedByName,
      if (status != null) 'status': status,
      if (reviewedByUserId != null) 'reviewed_by_user_id': reviewedByUserId,
      if (reviewRemarks != null) 'review_remarks': reviewRemarks,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CorrectionRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? attendanceRecordId,
    Value<String>? studentId,
    Value<String?>? studentName,
    Value<String>? classId,
    Value<String>? sectionId,
    Value<String>? date,
    Value<String>? oldStatus,
    Value<String>? proposedStatus,
    Value<String>? reason,
    Value<String>? requestedByUserId,
    Value<String?>? requestedByName,
    Value<String>? status,
    Value<String?>? reviewedByUserId,
    Value<String?>? reviewRemarks,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return CorrectionRequestsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      attendanceRecordId: attendanceRecordId ?? this.attendanceRecordId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      classId: classId ?? this.classId,
      sectionId: sectionId ?? this.sectionId,
      date: date ?? this.date,
      oldStatus: oldStatus ?? this.oldStatus,
      proposedStatus: proposedStatus ?? this.proposedStatus,
      reason: reason ?? this.reason,
      requestedByUserId: requestedByUserId ?? this.requestedByUserId,
      requestedByName: requestedByName ?? this.requestedByName,
      status: status ?? this.status,
      reviewedByUserId: reviewedByUserId ?? this.reviewedByUserId,
      reviewRemarks: reviewRemarks ?? this.reviewRemarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (attendanceRecordId.present) {
      map['attendance_record_id'] = Variable<String>(attendanceRecordId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (studentName.present) {
      map['student_name'] = Variable<String>(studentName.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (oldStatus.present) {
      map['old_status'] = Variable<String>(oldStatus.value);
    }
    if (proposedStatus.present) {
      map['proposed_status'] = Variable<String>(proposedStatus.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (requestedByUserId.present) {
      map['requested_by_user_id'] = Variable<String>(requestedByUserId.value);
    }
    if (requestedByName.present) {
      map['requested_by_name'] = Variable<String>(requestedByName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reviewedByUserId.present) {
      map['reviewed_by_user_id'] = Variable<String>(reviewedByUserId.value);
    }
    if (reviewRemarks.present) {
      map['review_remarks'] = Variable<String>(reviewRemarks.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CorrectionRequestsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('attendanceRecordId: $attendanceRecordId, ')
          ..write('studentId: $studentId, ')
          ..write('studentName: $studentName, ')
          ..write('classId: $classId, ')
          ..write('sectionId: $sectionId, ')
          ..write('date: $date, ')
          ..write('oldStatus: $oldStatus, ')
          ..write('proposedStatus: $proposedStatus, ')
          ..write('reason: $reason, ')
          ..write('requestedByUserId: $requestedByUserId, ')
          ..write('requestedByName: $requestedByName, ')
          ..write('status: $status, ')
          ..write('reviewedByUserId: $reviewedByUserId, ')
          ..write('reviewRemarks: $reviewRemarks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflictEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableNameMeta = const VerificationMeta(
    'targetTableName',
  );
  @override
  late final GeneratedColumn<String> targetTableName = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localStatusMeta = const VerificationMeta(
    'localStatus',
  );
  @override
  late final GeneratedColumn<String> localStatus = GeneratedColumn<String>(
    'local_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverStatusMeta = const VerificationMeta(
    'serverStatus',
  );
  @override
  late final GeneratedColumn<String> serverStatus = GeneratedColumn<String>(
    'server_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conflictReasonMeta = const VerificationMeta(
    'conflictReason',
  );
  @override
  late final GeneratedColumn<String> conflictReason = GeneratedColumn<String>(
    'conflict_reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unresolved'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    recordId,
    targetTableName,
    studentId,
    date,
    localStatus,
    serverStatus,
    conflictReason,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflictEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _targetTableNameMeta,
        targetTableName.isAcceptableOrUnknown(
          data['table_name']!,
          _targetTableNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableNameMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('local_status')) {
      context.handle(
        _localStatusMeta,
        localStatus.isAcceptableOrUnknown(
          data['local_status']!,
          _localStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localStatusMeta);
    }
    if (data.containsKey('server_status')) {
      context.handle(
        _serverStatusMeta,
        serverStatus.isAcceptableOrUnknown(
          data['server_status']!,
          _serverStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverStatusMeta);
    }
    if (data.containsKey('conflict_reason')) {
      context.handle(
        _conflictReasonMeta,
        conflictReason.isAcceptableOrUnknown(
          data['conflict_reason']!,
          _conflictReasonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conflictReasonMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflictEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflictEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      ),
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      targetTableName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      localStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_status'],
      )!,
      serverStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_status'],
      )!,
      conflictReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_reason'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflictEntry extends DataClass
    implements Insertable<SyncConflictEntry> {
  final String id;
  final String? schoolId;
  final String recordId;
  final String targetTableName;
  final String studentId;
  final String date;
  final String localStatus;
  final String serverStatus;
  final String conflictReason;
  final String status;
  final int createdAt;
  const SyncConflictEntry({
    required this.id,
    this.schoolId,
    required this.recordId,
    required this.targetTableName,
    required this.studentId,
    required this.date,
    required this.localStatus,
    required this.serverStatus,
    required this.conflictReason,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || schoolId != null) {
      map['school_id'] = Variable<String>(schoolId);
    }
    map['record_id'] = Variable<String>(recordId);
    map['table_name'] = Variable<String>(targetTableName);
    map['student_id'] = Variable<String>(studentId);
    map['date'] = Variable<String>(date);
    map['local_status'] = Variable<String>(localStatus);
    map['server_status'] = Variable<String>(serverStatus);
    map['conflict_reason'] = Variable<String>(conflictReason);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      schoolId: schoolId == null && nullToAbsent
          ? const Value.absent()
          : Value(schoolId),
      recordId: Value(recordId),
      targetTableName: Value(targetTableName),
      studentId: Value(studentId),
      date: Value(date),
      localStatus: Value(localStatus),
      serverStatus: Value(serverStatus),
      conflictReason: Value(conflictReason),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory SyncConflictEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflictEntry(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String?>(json['schoolId']),
      recordId: serializer.fromJson<String>(json['recordId']),
      targetTableName: serializer.fromJson<String>(json['targetTableName']),
      studentId: serializer.fromJson<String>(json['studentId']),
      date: serializer.fromJson<String>(json['date']),
      localStatus: serializer.fromJson<String>(json['localStatus']),
      serverStatus: serializer.fromJson<String>(json['serverStatus']),
      conflictReason: serializer.fromJson<String>(json['conflictReason']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String?>(schoolId),
      'recordId': serializer.toJson<String>(recordId),
      'targetTableName': serializer.toJson<String>(targetTableName),
      'studentId': serializer.toJson<String>(studentId),
      'date': serializer.toJson<String>(date),
      'localStatus': serializer.toJson<String>(localStatus),
      'serverStatus': serializer.toJson<String>(serverStatus),
      'conflictReason': serializer.toJson<String>(conflictReason),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SyncConflictEntry copyWith({
    String? id,
    Value<String?> schoolId = const Value.absent(),
    String? recordId,
    String? targetTableName,
    String? studentId,
    String? date,
    String? localStatus,
    String? serverStatus,
    String? conflictReason,
    String? status,
    int? createdAt,
  }) => SyncConflictEntry(
    id: id ?? this.id,
    schoolId: schoolId.present ? schoolId.value : this.schoolId,
    recordId: recordId ?? this.recordId,
    targetTableName: targetTableName ?? this.targetTableName,
    studentId: studentId ?? this.studentId,
    date: date ?? this.date,
    localStatus: localStatus ?? this.localStatus,
    serverStatus: serverStatus ?? this.serverStatus,
    conflictReason: conflictReason ?? this.conflictReason,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncConflictEntry copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflictEntry(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      targetTableName: data.targetTableName.present
          ? data.targetTableName.value
          : this.targetTableName,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      date: data.date.present ? data.date.value : this.date,
      localStatus: data.localStatus.present
          ? data.localStatus.value
          : this.localStatus,
      serverStatus: data.serverStatus.present
          ? data.serverStatus.value
          : this.serverStatus,
      conflictReason: data.conflictReason.present
          ? data.conflictReason.value
          : this.conflictReason,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictEntry(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('recordId: $recordId, ')
          ..write('targetTableName: $targetTableName, ')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('localStatus: $localStatus, ')
          ..write('serverStatus: $serverStatus, ')
          ..write('conflictReason: $conflictReason, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    recordId,
    targetTableName,
    studentId,
    date,
    localStatus,
    serverStatus,
    conflictReason,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflictEntry &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.recordId == this.recordId &&
          other.targetTableName == this.targetTableName &&
          other.studentId == this.studentId &&
          other.date == this.date &&
          other.localStatus == this.localStatus &&
          other.serverStatus == this.serverStatus &&
          other.conflictReason == this.conflictReason &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflictEntry> {
  final Value<String> id;
  final Value<String?> schoolId;
  final Value<String> recordId;
  final Value<String> targetTableName;
  final Value<String> studentId;
  final Value<String> date;
  final Value<String> localStatus;
  final Value<String> serverStatus;
  final Value<String> conflictReason;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.recordId = const Value.absent(),
    this.targetTableName = const Value.absent(),
    this.studentId = const Value.absent(),
    this.date = const Value.absent(),
    this.localStatus = const Value.absent(),
    this.serverStatus = const Value.absent(),
    this.conflictReason = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    this.schoolId = const Value.absent(),
    required String recordId,
    required String targetTableName,
    required String studentId,
    required String date,
    required String localStatus,
    required String serverStatus,
    required String conflictReason,
    this.status = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recordId = Value(recordId),
       targetTableName = Value(targetTableName),
       studentId = Value(studentId),
       date = Value(date),
       localStatus = Value(localStatus),
       serverStatus = Value(serverStatus),
       conflictReason = Value(conflictReason),
       createdAt = Value(createdAt);
  static Insertable<SyncConflictEntry> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? recordId,
    Expression<String>? targetTableName,
    Expression<String>? studentId,
    Expression<String>? date,
    Expression<String>? localStatus,
    Expression<String>? serverStatus,
    Expression<String>? conflictReason,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (recordId != null) 'record_id': recordId,
      if (targetTableName != null) 'table_name': targetTableName,
      if (studentId != null) 'student_id': studentId,
      if (date != null) 'date': date,
      if (localStatus != null) 'local_status': localStatus,
      if (serverStatus != null) 'server_status': serverStatus,
      if (conflictReason != null) 'conflict_reason': conflictReason,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? id,
    Value<String?>? schoolId,
    Value<String>? recordId,
    Value<String>? targetTableName,
    Value<String>? studentId,
    Value<String>? date,
    Value<String>? localStatus,
    Value<String>? serverStatus,
    Value<String>? conflictReason,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      recordId: recordId ?? this.recordId,
      targetTableName: targetTableName ?? this.targetTableName,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      localStatus: localStatus ?? this.localStatus,
      serverStatus: serverStatus ?? this.serverStatus,
      conflictReason: conflictReason ?? this.conflictReason,
      status: status ?? this.status,
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
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (targetTableName.present) {
      map['table_name'] = Variable<String>(targetTableName.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (localStatus.present) {
      map['local_status'] = Variable<String>(localStatus.value);
    }
    if (serverStatus.present) {
      map['server_status'] = Variable<String>(serverStatus.value);
    }
    if (conflictReason.present) {
      map['conflict_reason'] = Variable<String>(conflictReason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('recordId: $recordId, ')
          ..write('targetTableName: $targetTableName, ')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('localStatus: $localStatus, ')
          ..write('serverStatus: $serverStatus, ')
          ..write('conflictReason: $conflictReason, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeacherGoshwaraProfilesTable extends TeacherGoshwaraProfiles
    with TableInfo<$TeacherGoshwaraProfilesTable, TeacherGoshwaraProfileEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeacherGoshwaraProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatherNameMeta = const VerificationMeta(
    'fatherName',
  );
  @override
  late final GeneratedColumn<String> fatherName = GeneratedColumn<String>(
    'father_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _personalNoMeta = const VerificationMeta(
    'personalNo',
  );
  @override
  late final GeneratedColumn<String> personalNo = GeneratedColumn<String>(
    'personal_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dobMeta = const VerificationMeta('dob');
  @override
  late final GeneratedColumn<String> dob = GeneratedColumn<String>(
    'dob',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _academicQualificationMeta =
      const VerificationMeta('academicQualification');
  @override
  late final GeneratedColumn<String> academicQualification =
      GeneratedColumn<String>(
        'academic_qualification',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _professionalQualificationMeta =
      const VerificationMeta('professionalQualification');
  @override
  late final GeneratedColumn<String> professionalQualification =
      GeneratedColumn<String>(
        'professional_qualification',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _appointmentDateMeta = const VerificationMeta(
    'appointmentDate',
  );
  @override
  late final GeneratedColumn<String> appointmentDate = GeneratedColumn<String>(
    'appointment_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _transferInDateMeta = const VerificationMeta(
    'transferInDate',
  );
  @override
  late final GeneratedColumn<String> transferInDate = GeneratedColumn<String>(
    'transfer_in_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _currentBpsMeta = const VerificationMeta(
    'currentBps',
  );
  @override
  late final GeneratedColumn<String> currentBps = GeneratedColumn<String>(
    'current_bps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bpsAwardDateMeta = const VerificationMeta(
    'bpsAwardDate',
  );
  @override
  late final GeneratedColumn<String> bpsAwardDate = GeneratedColumn<String>(
    'bps_award_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _basicPayMeta = const VerificationMeta(
    'basicPay',
  );
  @override
  late final GeneratedColumn<double> basicPay = GeneratedColumn<double>(
    'basic_pay',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _villageMeta = const VerificationMeta(
    'village',
  );
  @override
  late final GeneratedColumn<String> village = GeneratedColumn<String>(
    'village',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _unionCouncilMeta = const VerificationMeta(
    'unionCouncil',
  );
  @override
  late final GeneratedColumn<String> unionCouncil = GeneratedColumn<String>(
    'union_council',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _employmentTypeMeta = const VerificationMeta(
    'employmentType',
  );
  @override
  late final GeneratedColumn<String> employmentType = GeneratedColumn<String>(
    'employment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('permanent'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    fatherName,
    personalNo,
    dob,
    academicQualification,
    professionalQualification,
    appointmentDate,
    transferInDate,
    currentBps,
    bpsAwardDate,
    basicPay,
    village,
    unionCouncil,
    district,
    employmentType,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teacher_goshwara_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeacherGoshwaraProfileEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('father_name')) {
      context.handle(
        _fatherNameMeta,
        fatherName.isAcceptableOrUnknown(data['father_name']!, _fatherNameMeta),
      );
    }
    if (data.containsKey('personal_no')) {
      context.handle(
        _personalNoMeta,
        personalNo.isAcceptableOrUnknown(data['personal_no']!, _personalNoMeta),
      );
    }
    if (data.containsKey('dob')) {
      context.handle(
        _dobMeta,
        dob.isAcceptableOrUnknown(data['dob']!, _dobMeta),
      );
    }
    if (data.containsKey('academic_qualification')) {
      context.handle(
        _academicQualificationMeta,
        academicQualification.isAcceptableOrUnknown(
          data['academic_qualification']!,
          _academicQualificationMeta,
        ),
      );
    }
    if (data.containsKey('professional_qualification')) {
      context.handle(
        _professionalQualificationMeta,
        professionalQualification.isAcceptableOrUnknown(
          data['professional_qualification']!,
          _professionalQualificationMeta,
        ),
      );
    }
    if (data.containsKey('appointment_date')) {
      context.handle(
        _appointmentDateMeta,
        appointmentDate.isAcceptableOrUnknown(
          data['appointment_date']!,
          _appointmentDateMeta,
        ),
      );
    }
    if (data.containsKey('transfer_in_date')) {
      context.handle(
        _transferInDateMeta,
        transferInDate.isAcceptableOrUnknown(
          data['transfer_in_date']!,
          _transferInDateMeta,
        ),
      );
    }
    if (data.containsKey('current_bps')) {
      context.handle(
        _currentBpsMeta,
        currentBps.isAcceptableOrUnknown(data['current_bps']!, _currentBpsMeta),
      );
    }
    if (data.containsKey('bps_award_date')) {
      context.handle(
        _bpsAwardDateMeta,
        bpsAwardDate.isAcceptableOrUnknown(
          data['bps_award_date']!,
          _bpsAwardDateMeta,
        ),
      );
    }
    if (data.containsKey('basic_pay')) {
      context.handle(
        _basicPayMeta,
        basicPay.isAcceptableOrUnknown(data['basic_pay']!, _basicPayMeta),
      );
    }
    if (data.containsKey('village')) {
      context.handle(
        _villageMeta,
        village.isAcceptableOrUnknown(data['village']!, _villageMeta),
      );
    }
    if (data.containsKey('union_council')) {
      context.handle(
        _unionCouncilMeta,
        unionCouncil.isAcceptableOrUnknown(
          data['union_council']!,
          _unionCouncilMeta,
        ),
      );
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('employment_type')) {
      context.handle(
        _employmentTypeMeta,
        employmentType.isAcceptableOrUnknown(
          data['employment_type']!,
          _employmentTypeMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  TeacherGoshwaraProfileEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeacherGoshwaraProfileEntry(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      fatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_name'],
      )!,
      personalNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personal_no'],
      )!,
      dob: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dob'],
      )!,
      academicQualification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}academic_qualification'],
      )!,
      professionalQualification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}professional_qualification'],
      )!,
      appointmentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appointment_date'],
      )!,
      transferInDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_in_date'],
      )!,
      currentBps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_bps'],
      )!,
      bpsAwardDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bps_award_date'],
      )!,
      basicPay: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}basic_pay'],
      )!,
      village: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village'],
      )!,
      unionCouncil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}union_council'],
      )!,
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      )!,
      employmentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employment_type'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $TeacherGoshwaraProfilesTable createAlias(String alias) {
    return $TeacherGoshwaraProfilesTable(attachedDatabase, alias);
  }
}

class TeacherGoshwaraProfileEntry extends DataClass
    implements Insertable<TeacherGoshwaraProfileEntry> {
  final String userId;
  final String fatherName;
  final String personalNo;
  final String dob;
  final String academicQualification;
  final String professionalQualification;
  final String appointmentDate;
  final String transferInDate;
  final String currentBps;
  final String bpsAwardDate;
  final double basicPay;
  final String village;
  final String unionCouncil;
  final String district;
  final String employmentType;
  final int updatedAt;
  final int revision;
  const TeacherGoshwaraProfileEntry({
    required this.userId,
    required this.fatherName,
    required this.personalNo,
    required this.dob,
    required this.academicQualification,
    required this.professionalQualification,
    required this.appointmentDate,
    required this.transferInDate,
    required this.currentBps,
    required this.bpsAwardDate,
    required this.basicPay,
    required this.village,
    required this.unionCouncil,
    required this.district,
    required this.employmentType,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['father_name'] = Variable<String>(fatherName);
    map['personal_no'] = Variable<String>(personalNo);
    map['dob'] = Variable<String>(dob);
    map['academic_qualification'] = Variable<String>(academicQualification);
    map['professional_qualification'] = Variable<String>(
      professionalQualification,
    );
    map['appointment_date'] = Variable<String>(appointmentDate);
    map['transfer_in_date'] = Variable<String>(transferInDate);
    map['current_bps'] = Variable<String>(currentBps);
    map['bps_award_date'] = Variable<String>(bpsAwardDate);
    map['basic_pay'] = Variable<double>(basicPay);
    map['village'] = Variable<String>(village);
    map['union_council'] = Variable<String>(unionCouncil);
    map['district'] = Variable<String>(district);
    map['employment_type'] = Variable<String>(employmentType);
    map['updated_at'] = Variable<int>(updatedAt);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  TeacherGoshwaraProfilesCompanion toCompanion(bool nullToAbsent) {
    return TeacherGoshwaraProfilesCompanion(
      userId: Value(userId),
      fatherName: Value(fatherName),
      personalNo: Value(personalNo),
      dob: Value(dob),
      academicQualification: Value(academicQualification),
      professionalQualification: Value(professionalQualification),
      appointmentDate: Value(appointmentDate),
      transferInDate: Value(transferInDate),
      currentBps: Value(currentBps),
      bpsAwardDate: Value(bpsAwardDate),
      basicPay: Value(basicPay),
      village: Value(village),
      unionCouncil: Value(unionCouncil),
      district: Value(district),
      employmentType: Value(employmentType),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory TeacherGoshwaraProfileEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeacherGoshwaraProfileEntry(
      userId: serializer.fromJson<String>(json['userId']),
      fatherName: serializer.fromJson<String>(json['fatherName']),
      personalNo: serializer.fromJson<String>(json['personalNo']),
      dob: serializer.fromJson<String>(json['dob']),
      academicQualification: serializer.fromJson<String>(
        json['academicQualification'],
      ),
      professionalQualification: serializer.fromJson<String>(
        json['professionalQualification'],
      ),
      appointmentDate: serializer.fromJson<String>(json['appointmentDate']),
      transferInDate: serializer.fromJson<String>(json['transferInDate']),
      currentBps: serializer.fromJson<String>(json['currentBps']),
      bpsAwardDate: serializer.fromJson<String>(json['bpsAwardDate']),
      basicPay: serializer.fromJson<double>(json['basicPay']),
      village: serializer.fromJson<String>(json['village']),
      unionCouncil: serializer.fromJson<String>(json['unionCouncil']),
      district: serializer.fromJson<String>(json['district']),
      employmentType: serializer.fromJson<String>(json['employmentType']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'fatherName': serializer.toJson<String>(fatherName),
      'personalNo': serializer.toJson<String>(personalNo),
      'dob': serializer.toJson<String>(dob),
      'academicQualification': serializer.toJson<String>(academicQualification),
      'professionalQualification': serializer.toJson<String>(
        professionalQualification,
      ),
      'appointmentDate': serializer.toJson<String>(appointmentDate),
      'transferInDate': serializer.toJson<String>(transferInDate),
      'currentBps': serializer.toJson<String>(currentBps),
      'bpsAwardDate': serializer.toJson<String>(bpsAwardDate),
      'basicPay': serializer.toJson<double>(basicPay),
      'village': serializer.toJson<String>(village),
      'unionCouncil': serializer.toJson<String>(unionCouncil),
      'district': serializer.toJson<String>(district),
      'employmentType': serializer.toJson<String>(employmentType),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  TeacherGoshwaraProfileEntry copyWith({
    String? userId,
    String? fatherName,
    String? personalNo,
    String? dob,
    String? academicQualification,
    String? professionalQualification,
    String? appointmentDate,
    String? transferInDate,
    String? currentBps,
    String? bpsAwardDate,
    double? basicPay,
    String? village,
    String? unionCouncil,
    String? district,
    String? employmentType,
    int? updatedAt,
    int? revision,
  }) => TeacherGoshwaraProfileEntry(
    userId: userId ?? this.userId,
    fatherName: fatherName ?? this.fatherName,
    personalNo: personalNo ?? this.personalNo,
    dob: dob ?? this.dob,
    academicQualification: academicQualification ?? this.academicQualification,
    professionalQualification:
        professionalQualification ?? this.professionalQualification,
    appointmentDate: appointmentDate ?? this.appointmentDate,
    transferInDate: transferInDate ?? this.transferInDate,
    currentBps: currentBps ?? this.currentBps,
    bpsAwardDate: bpsAwardDate ?? this.bpsAwardDate,
    basicPay: basicPay ?? this.basicPay,
    village: village ?? this.village,
    unionCouncil: unionCouncil ?? this.unionCouncil,
    district: district ?? this.district,
    employmentType: employmentType ?? this.employmentType,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  TeacherGoshwaraProfileEntry copyWithCompanion(
    TeacherGoshwaraProfilesCompanion data,
  ) {
    return TeacherGoshwaraProfileEntry(
      userId: data.userId.present ? data.userId.value : this.userId,
      fatherName: data.fatherName.present
          ? data.fatherName.value
          : this.fatherName,
      personalNo: data.personalNo.present
          ? data.personalNo.value
          : this.personalNo,
      dob: data.dob.present ? data.dob.value : this.dob,
      academicQualification: data.academicQualification.present
          ? data.academicQualification.value
          : this.academicQualification,
      professionalQualification: data.professionalQualification.present
          ? data.professionalQualification.value
          : this.professionalQualification,
      appointmentDate: data.appointmentDate.present
          ? data.appointmentDate.value
          : this.appointmentDate,
      transferInDate: data.transferInDate.present
          ? data.transferInDate.value
          : this.transferInDate,
      currentBps: data.currentBps.present
          ? data.currentBps.value
          : this.currentBps,
      bpsAwardDate: data.bpsAwardDate.present
          ? data.bpsAwardDate.value
          : this.bpsAwardDate,
      basicPay: data.basicPay.present ? data.basicPay.value : this.basicPay,
      village: data.village.present ? data.village.value : this.village,
      unionCouncil: data.unionCouncil.present
          ? data.unionCouncil.value
          : this.unionCouncil,
      district: data.district.present ? data.district.value : this.district,
      employmentType: data.employmentType.present
          ? data.employmentType.value
          : this.employmentType,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeacherGoshwaraProfileEntry(')
          ..write('userId: $userId, ')
          ..write('fatherName: $fatherName, ')
          ..write('personalNo: $personalNo, ')
          ..write('dob: $dob, ')
          ..write('academicQualification: $academicQualification, ')
          ..write('professionalQualification: $professionalQualification, ')
          ..write('appointmentDate: $appointmentDate, ')
          ..write('transferInDate: $transferInDate, ')
          ..write('currentBps: $currentBps, ')
          ..write('bpsAwardDate: $bpsAwardDate, ')
          ..write('basicPay: $basicPay, ')
          ..write('village: $village, ')
          ..write('unionCouncil: $unionCouncil, ')
          ..write('district: $district, ')
          ..write('employmentType: $employmentType, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    fatherName,
    personalNo,
    dob,
    academicQualification,
    professionalQualification,
    appointmentDate,
    transferInDate,
    currentBps,
    bpsAwardDate,
    basicPay,
    village,
    unionCouncil,
    district,
    employmentType,
    updatedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeacherGoshwaraProfileEntry &&
          other.userId == this.userId &&
          other.fatherName == this.fatherName &&
          other.personalNo == this.personalNo &&
          other.dob == this.dob &&
          other.academicQualification == this.academicQualification &&
          other.professionalQualification == this.professionalQualification &&
          other.appointmentDate == this.appointmentDate &&
          other.transferInDate == this.transferInDate &&
          other.currentBps == this.currentBps &&
          other.bpsAwardDate == this.bpsAwardDate &&
          other.basicPay == this.basicPay &&
          other.village == this.village &&
          other.unionCouncil == this.unionCouncil &&
          other.district == this.district &&
          other.employmentType == this.employmentType &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class TeacherGoshwaraProfilesCompanion
    extends UpdateCompanion<TeacherGoshwaraProfileEntry> {
  final Value<String> userId;
  final Value<String> fatherName;
  final Value<String> personalNo;
  final Value<String> dob;
  final Value<String> academicQualification;
  final Value<String> professionalQualification;
  final Value<String> appointmentDate;
  final Value<String> transferInDate;
  final Value<String> currentBps;
  final Value<String> bpsAwardDate;
  final Value<double> basicPay;
  final Value<String> village;
  final Value<String> unionCouncil;
  final Value<String> district;
  final Value<String> employmentType;
  final Value<int> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const TeacherGoshwaraProfilesCompanion({
    this.userId = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.personalNo = const Value.absent(),
    this.dob = const Value.absent(),
    this.academicQualification = const Value.absent(),
    this.professionalQualification = const Value.absent(),
    this.appointmentDate = const Value.absent(),
    this.transferInDate = const Value.absent(),
    this.currentBps = const Value.absent(),
    this.bpsAwardDate = const Value.absent(),
    this.basicPay = const Value.absent(),
    this.village = const Value.absent(),
    this.unionCouncil = const Value.absent(),
    this.district = const Value.absent(),
    this.employmentType = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeacherGoshwaraProfilesCompanion.insert({
    required String userId,
    this.fatherName = const Value.absent(),
    this.personalNo = const Value.absent(),
    this.dob = const Value.absent(),
    this.academicQualification = const Value.absent(),
    this.professionalQualification = const Value.absent(),
    this.appointmentDate = const Value.absent(),
    this.transferInDate = const Value.absent(),
    this.currentBps = const Value.absent(),
    this.bpsAwardDate = const Value.absent(),
    this.basicPay = const Value.absent(),
    this.village = const Value.absent(),
    this.unionCouncil = const Value.absent(),
    this.district = const Value.absent(),
    this.employmentType = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<TeacherGoshwaraProfileEntry> custom({
    Expression<String>? userId,
    Expression<String>? fatherName,
    Expression<String>? personalNo,
    Expression<String>? dob,
    Expression<String>? academicQualification,
    Expression<String>? professionalQualification,
    Expression<String>? appointmentDate,
    Expression<String>? transferInDate,
    Expression<String>? currentBps,
    Expression<String>? bpsAwardDate,
    Expression<double>? basicPay,
    Expression<String>? village,
    Expression<String>? unionCouncil,
    Expression<String>? district,
    Expression<String>? employmentType,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (fatherName != null) 'father_name': fatherName,
      if (personalNo != null) 'personal_no': personalNo,
      if (dob != null) 'dob': dob,
      if (academicQualification != null)
        'academic_qualification': academicQualification,
      if (professionalQualification != null)
        'professional_qualification': professionalQualification,
      if (appointmentDate != null) 'appointment_date': appointmentDate,
      if (transferInDate != null) 'transfer_in_date': transferInDate,
      if (currentBps != null) 'current_bps': currentBps,
      if (bpsAwardDate != null) 'bps_award_date': bpsAwardDate,
      if (basicPay != null) 'basic_pay': basicPay,
      if (village != null) 'village': village,
      if (unionCouncil != null) 'union_council': unionCouncil,
      if (district != null) 'district': district,
      if (employmentType != null) 'employment_type': employmentType,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeacherGoshwaraProfilesCompanion copyWith({
    Value<String>? userId,
    Value<String>? fatherName,
    Value<String>? personalNo,
    Value<String>? dob,
    Value<String>? academicQualification,
    Value<String>? professionalQualification,
    Value<String>? appointmentDate,
    Value<String>? transferInDate,
    Value<String>? currentBps,
    Value<String>? bpsAwardDate,
    Value<double>? basicPay,
    Value<String>? village,
    Value<String>? unionCouncil,
    Value<String>? district,
    Value<String>? employmentType,
    Value<int>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return TeacherGoshwaraProfilesCompanion(
      userId: userId ?? this.userId,
      fatherName: fatherName ?? this.fatherName,
      personalNo: personalNo ?? this.personalNo,
      dob: dob ?? this.dob,
      academicQualification:
          academicQualification ?? this.academicQualification,
      professionalQualification:
          professionalQualification ?? this.professionalQualification,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      transferInDate: transferInDate ?? this.transferInDate,
      currentBps: currentBps ?? this.currentBps,
      bpsAwardDate: bpsAwardDate ?? this.bpsAwardDate,
      basicPay: basicPay ?? this.basicPay,
      village: village ?? this.village,
      unionCouncil: unionCouncil ?? this.unionCouncil,
      district: district ?? this.district,
      employmentType: employmentType ?? this.employmentType,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (fatherName.present) {
      map['father_name'] = Variable<String>(fatherName.value);
    }
    if (personalNo.present) {
      map['personal_no'] = Variable<String>(personalNo.value);
    }
    if (dob.present) {
      map['dob'] = Variable<String>(dob.value);
    }
    if (academicQualification.present) {
      map['academic_qualification'] = Variable<String>(
        academicQualification.value,
      );
    }
    if (professionalQualification.present) {
      map['professional_qualification'] = Variable<String>(
        professionalQualification.value,
      );
    }
    if (appointmentDate.present) {
      map['appointment_date'] = Variable<String>(appointmentDate.value);
    }
    if (transferInDate.present) {
      map['transfer_in_date'] = Variable<String>(transferInDate.value);
    }
    if (currentBps.present) {
      map['current_bps'] = Variable<String>(currentBps.value);
    }
    if (bpsAwardDate.present) {
      map['bps_award_date'] = Variable<String>(bpsAwardDate.value);
    }
    if (basicPay.present) {
      map['basic_pay'] = Variable<double>(basicPay.value);
    }
    if (village.present) {
      map['village'] = Variable<String>(village.value);
    }
    if (unionCouncil.present) {
      map['union_council'] = Variable<String>(unionCouncil.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (employmentType.present) {
      map['employment_type'] = Variable<String>(employmentType.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeacherGoshwaraProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('fatherName: $fatherName, ')
          ..write('personalNo: $personalNo, ')
          ..write('dob: $dob, ')
          ..write('academicQualification: $academicQualification, ')
          ..write('professionalQualification: $professionalQualification, ')
          ..write('appointmentDate: $appointmentDate, ')
          ..write('transferInDate: $transferInDate, ')
          ..write('currentBps: $currentBps, ')
          ..write('bpsAwardDate: $bpsAwardDate, ')
          ..write('basicPay: $basicPay, ')
          ..write('village: $village, ')
          ..write('unionCouncil: $unionCouncil, ')
          ..write('district: $district, ')
          ..write('employmentType: $employmentType, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchoolsTable schools = $SchoolsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ClassesTable classes = $ClassesTable(this);
  late final $SectionsTable sections = $SectionsTable(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $ParentContactsTable parentContacts = $ParentContactsTable(this);
  late final $SchoolCalendarHolidaysTable schoolCalendarHolidays =
      $SchoolCalendarHolidaysTable(this);
  late final $AttendanceRecordsTable attendanceRecords =
      $AttendanceRecordsTable(this);
  late final $AttendanceAuditLogsTable attendanceAuditLogs =
      $AttendanceAuditLogsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $SchoolSettingsTable schoolSettings = $SchoolSettingsTable(this);
  late final $StudentExtendedInfoTable studentExtendedInfo =
      $StudentExtendedInfoTable(this);
  late final $AttendanceSessionsTable attendanceSessions =
      $AttendanceSessionsTable(this);
  late final $CorrectionRequestsTable correctionRequests =
      $CorrectionRequestsTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $TeacherGoshwaraProfilesTable teacherGoshwaraProfiles =
      $TeacherGoshwaraProfilesTable(this);
  late final AttendanceDao attendanceDao = AttendanceDao(this as AppDatabase);
  late final StudentDao studentDao = StudentDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    schools,
    users,
    classes,
    sections,
    students,
    parentContacts,
    schoolCalendarHolidays,
    attendanceRecords,
    attendanceAuditLogs,
    syncQueue,
    schoolSettings,
    studentExtendedInfo,
    attendanceSessions,
    correctionRequests,
    syncConflicts,
    teacherGoshwaraProfiles,
  ];
}

typedef $$SchoolsTableCreateCompanionBuilder =
    SchoolsCompanion Function({
      required String id,
      required String name,
      required String code,
      Value<String?> address,
      Value<String?> phone,
      Value<String?> logoUrl,
      required String academicYearStart,
      required String academicYearEnd,
      required int createdAt,
      required int updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$SchoolsTableUpdateCompanionBuilder =
    SchoolsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> code,
      Value<String?> address,
      Value<String?> phone,
      Value<String?> logoUrl,
      Value<String> academicYearStart,
      Value<String> academicYearEnd,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$SchoolsTableFilterComposer
    extends Composer<_$AppDatabase, $SchoolsTable> {
  $$SchoolsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get academicYearStart => $composableBuilder(
    column: $table.academicYearStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get academicYearEnd => $composableBuilder(
    column: $table.academicYearEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchoolsTableOrderingComposer
    extends Composer<_$AppDatabase, $SchoolsTable> {
  $$SchoolsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get academicYearStart => $composableBuilder(
    column: $table.academicYearStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get academicYearEnd => $composableBuilder(
    column: $table.academicYearEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchoolsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchoolsTable> {
  $$SchoolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get academicYearStart => $composableBuilder(
    column: $table.academicYearStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get academicYearEnd => $composableBuilder(
    column: $table.academicYearEnd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$SchoolsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchoolsTable,
          School,
          $$SchoolsTableFilterComposer,
          $$SchoolsTableOrderingComposer,
          $$SchoolsTableAnnotationComposer,
          $$SchoolsTableCreateCompanionBuilder,
          $$SchoolsTableUpdateCompanionBuilder,
          (School, BaseReferences<_$AppDatabase, $SchoolsTable, School>),
          School,
          PrefetchHooks Function()
        > {
  $$SchoolsTableTableManager(_$AppDatabase db, $SchoolsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchoolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchoolsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchoolsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String> academicYearStart = const Value.absent(),
                Value<String> academicYearEnd = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolsCompanion(
                id: id,
                name: name,
                code: code,
                address: address,
                phone: phone,
                logoUrl: logoUrl,
                academicYearStart: academicYearStart,
                academicYearEnd: academicYearEnd,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String code,
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                required String academicYearStart,
                required String academicYearEnd,
                required int createdAt,
                required int updatedAt,
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolsCompanion.insert(
                id: id,
                name: name,
                code: code,
                address: address,
                phone: phone,
                logoUrl: logoUrl,
                academicYearStart: academicYearStart,
                academicYearEnd: academicYearEnd,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SchoolsTable, School>(table),
                  BaseReferences<_$AppDatabase, $SchoolsTable, School>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchoolsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchoolsTable,
      School,
      $$SchoolsTableFilterComposer,
      $$SchoolsTableOrderingComposer,
      $$SchoolsTableAnnotationComposer,
      $$SchoolsTableCreateCompanionBuilder,
      $$SchoolsTableUpdateCompanionBuilder,
      (School, BaseReferences<_$AppDatabase, $SchoolsTable, School>),
      School,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String schoolId,
      required String name,
      Value<String?> email,
      Value<String?> phone,
      required String role,
      Value<String?> pinCodeHash,
      Value<String?> avatarUrl,
      Value<String?> cnic,
      Value<String?> designation,
      Value<bool> isActive,
      required int createdAt,
      required int updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> name,
      Value<String?> email,
      Value<String?> phone,
      Value<String> role,
      Value<String?> pinCodeHash,
      Value<String?> avatarUrl,
      Value<String?> cnic,
      Value<String?> designation,
      Value<bool> isActive,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinCodeHash => $composableBuilder(
    column: $table.pinCodeHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cnic => $composableBuilder(
    column: $table.cnic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinCodeHash => $composableBuilder(
    column: $table.pinCodeHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cnic => $composableBuilder(
    column: $table.cnic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get pinCodeHash => $composableBuilder(
    column: $table.pinCodeHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get cnic =>
      $composableBuilder(column: $table.cnic, builder: (column) => column);

  GeneratedColumn<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> pinCodeHash = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> cnic = const Value.absent(),
                Value<String?> designation = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                schoolId: schoolId,
                name: name,
                email: email,
                phone: phone,
                role: role,
                pinCodeHash: pinCodeHash,
                avatarUrl: avatarUrl,
                cnic: cnic,
                designation: designation,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String name,
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                required String role,
                Value<String?> pinCodeHash = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> cnic = const Value.absent(),
                Value<String?> designation = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                schoolId: schoolId,
                name: name,
                email: email,
                phone: phone,
                role: role,
                pinCodeHash: pinCodeHash,
                avatarUrl: avatarUrl,
                cnic: cnic,
                designation: designation,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, User>(table),
                  BaseReferences<_$AppDatabase, $UsersTable, User>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$ClassesTableCreateCompanionBuilder =
    ClassesCompanion Function({
      required String id,
      required String schoolId,
      required String name,
      Value<int> numericLevel,
      required int createdAt,
      required int updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$ClassesTableUpdateCompanionBuilder =
    ClassesCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> name,
      Value<int> numericLevel,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$ClassesTableFilterComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numericLevel => $composableBuilder(
    column: $table.numericLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClassesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numericLevel => $composableBuilder(
    column: $table.numericLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClassesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get numericLevel => $composableBuilder(
    column: $table.numericLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$ClassesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClassesTable,
          ClassesData,
          $$ClassesTableFilterComposer,
          $$ClassesTableOrderingComposer,
          $$ClassesTableAnnotationComposer,
          $$ClassesTableCreateCompanionBuilder,
          $$ClassesTableUpdateCompanionBuilder,
          (
            ClassesData,
            BaseReferences<_$AppDatabase, $ClassesTable, ClassesData>,
          ),
          ClassesData,
          PrefetchHooks Function()
        > {
  $$ClassesTableTableManager(_$AppDatabase db, $ClassesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> numericLevel = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassesCompanion(
                id: id,
                schoolId: schoolId,
                name: name,
                numericLevel: numericLevel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String name,
                Value<int> numericLevel = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassesCompanion.insert(
                id: id,
                schoolId: schoolId,
                name: name,
                numericLevel: numericLevel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClassesTable, ClassesData>(table),
                  BaseReferences<_$AppDatabase, $ClassesTable, ClassesData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClassesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClassesTable,
      ClassesData,
      $$ClassesTableFilterComposer,
      $$ClassesTableOrderingComposer,
      $$ClassesTableAnnotationComposer,
      $$ClassesTableCreateCompanionBuilder,
      $$ClassesTableUpdateCompanionBuilder,
      (ClassesData, BaseReferences<_$AppDatabase, $ClassesTable, ClassesData>),
      ClassesData,
      PrefetchHooks Function()
    >;
typedef $$SectionsTableCreateCompanionBuilder =
    SectionsCompanion Function({
      required String id,
      required String schoolId,
      required String classId,
      required String name,
      Value<String?> teacherId,
      required int createdAt,
      required int updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$SectionsTableUpdateCompanionBuilder =
    SectionsCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> classId,
      Value<String> name,
      Value<String?> teacherId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$SectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$SectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SectionsTable,
          Section,
          $$SectionsTableFilterComposer,
          $$SectionsTableOrderingComposer,
          $$SectionsTableAnnotationComposer,
          $$SectionsTableCreateCompanionBuilder,
          $$SectionsTableUpdateCompanionBuilder,
          (Section, BaseReferences<_$AppDatabase, $SectionsTable, Section>),
          Section,
          PrefetchHooks Function()
        > {
  $$SectionsTableTableManager(_$AppDatabase db, $SectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> teacherId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SectionsCompanion(
                id: id,
                schoolId: schoolId,
                classId: classId,
                name: name,
                teacherId: teacherId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String classId,
                required String name,
                Value<String?> teacherId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SectionsCompanion.insert(
                id: id,
                schoolId: schoolId,
                classId: classId,
                name: name,
                teacherId: teacherId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SectionsTable, Section>(table),
                  BaseReferences<_$AppDatabase, $SectionsTable, Section>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SectionsTable,
      Section,
      $$SectionsTableFilterComposer,
      $$SectionsTableOrderingComposer,
      $$SectionsTableAnnotationComposer,
      $$SectionsTableCreateCompanionBuilder,
      $$SectionsTableUpdateCompanionBuilder,
      (Section, BaseReferences<_$AppDatabase, $SectionsTable, Section>),
      Section,
      PrefetchHooks Function()
    >;
typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      required String id,
      required String schoolId,
      required String classId,
      required String sectionId,
      required String admissionNumber,
      Value<String?> rollNumber,
      required String fullName,
      required String fatherOrGuardianName,
      required String gender,
      Value<String?> dateOfBirth,
      required String admissionDate,
      Value<String> status,
      required String qrToken,
      Value<String?> photoUrl,
      Value<String?> studentCnic,
      Value<String?> fatherCnic,
      Value<bool> isVaccinated,
      Value<String?> vaccineFirstDoseDate,
      Value<String?> vaccineSecondDoseDate,
      Value<bool> isDeleted,
      required int createdAt,
      required int updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> classId,
      Value<String> sectionId,
      Value<String> admissionNumber,
      Value<String?> rollNumber,
      Value<String> fullName,
      Value<String> fatherOrGuardianName,
      Value<String> gender,
      Value<String?> dateOfBirth,
      Value<String> admissionDate,
      Value<String> status,
      Value<String> qrToken,
      Value<String?> photoUrl,
      Value<String?> studentCnic,
      Value<String?> fatherCnic,
      Value<bool> isVaccinated,
      Value<String?> vaccineFirstDoseDate,
      Value<String?> vaccineSecondDoseDate,
      Value<bool> isDeleted,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get admissionNumber => $composableBuilder(
    column: $table.admissionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rollNumber => $composableBuilder(
    column: $table.rollNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherOrGuardianName => $composableBuilder(
    column: $table.fatherOrGuardianName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get admissionDate => $composableBuilder(
    column: $table.admissionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qrToken => $composableBuilder(
    column: $table.qrToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentCnic => $composableBuilder(
    column: $table.studentCnic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherCnic => $composableBuilder(
    column: $table.fatherCnic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVaccinated => $composableBuilder(
    column: $table.isVaccinated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vaccineFirstDoseDate => $composableBuilder(
    column: $table.vaccineFirstDoseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vaccineSecondDoseDate => $composableBuilder(
    column: $table.vaccineSecondDoseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get admissionNumber => $composableBuilder(
    column: $table.admissionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rollNumber => $composableBuilder(
    column: $table.rollNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherOrGuardianName => $composableBuilder(
    column: $table.fatherOrGuardianName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get admissionDate => $composableBuilder(
    column: $table.admissionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qrToken => $composableBuilder(
    column: $table.qrToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentCnic => $composableBuilder(
    column: $table.studentCnic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherCnic => $composableBuilder(
    column: $table.fatherCnic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVaccinated => $composableBuilder(
    column: $table.isVaccinated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vaccineFirstDoseDate => $composableBuilder(
    column: $table.vaccineFirstDoseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vaccineSecondDoseDate => $composableBuilder(
    column: $table.vaccineSecondDoseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<String> get admissionNumber => $composableBuilder(
    column: $table.admissionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rollNumber => $composableBuilder(
    column: $table.rollNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get fatherOrGuardianName => $composableBuilder(
    column: $table.fatherOrGuardianName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get admissionDate => $composableBuilder(
    column: $table.admissionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get qrToken =>
      $composableBuilder(column: $table.qrToken, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get studentCnic => $composableBuilder(
    column: $table.studentCnic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherCnic => $composableBuilder(
    column: $table.fatherCnic,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVaccinated => $composableBuilder(
    column: $table.isVaccinated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vaccineFirstDoseDate => $composableBuilder(
    column: $table.vaccineFirstDoseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vaccineSecondDoseDate => $composableBuilder(
    column: $table.vaccineSecondDoseDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, BaseReferences<_$AppDatabase, $StudentsTable, Student>),
          Student,
          PrefetchHooks Function()
        > {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<String> admissionNumber = const Value.absent(),
                Value<String?> rollNumber = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> fatherOrGuardianName = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String?> dateOfBirth = const Value.absent(),
                Value<String> admissionDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> qrToken = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> studentCnic = const Value.absent(),
                Value<String?> fatherCnic = const Value.absent(),
                Value<bool> isVaccinated = const Value.absent(),
                Value<String?> vaccineFirstDoseDate = const Value.absent(),
                Value<String?> vaccineSecondDoseDate = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                schoolId: schoolId,
                classId: classId,
                sectionId: sectionId,
                admissionNumber: admissionNumber,
                rollNumber: rollNumber,
                fullName: fullName,
                fatherOrGuardianName: fatherOrGuardianName,
                gender: gender,
                dateOfBirth: dateOfBirth,
                admissionDate: admissionDate,
                status: status,
                qrToken: qrToken,
                photoUrl: photoUrl,
                studentCnic: studentCnic,
                fatherCnic: fatherCnic,
                isVaccinated: isVaccinated,
                vaccineFirstDoseDate: vaccineFirstDoseDate,
                vaccineSecondDoseDate: vaccineSecondDoseDate,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String classId,
                required String sectionId,
                required String admissionNumber,
                Value<String?> rollNumber = const Value.absent(),
                required String fullName,
                required String fatherOrGuardianName,
                required String gender,
                Value<String?> dateOfBirth = const Value.absent(),
                required String admissionDate,
                Value<String> status = const Value.absent(),
                required String qrToken,
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> studentCnic = const Value.absent(),
                Value<String?> fatherCnic = const Value.absent(),
                Value<bool> isVaccinated = const Value.absent(),
                Value<String?> vaccineFirstDoseDate = const Value.absent(),
                Value<String?> vaccineSecondDoseDate = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                schoolId: schoolId,
                classId: classId,
                sectionId: sectionId,
                admissionNumber: admissionNumber,
                rollNumber: rollNumber,
                fullName: fullName,
                fatherOrGuardianName: fatherOrGuardianName,
                gender: gender,
                dateOfBirth: dateOfBirth,
                admissionDate: admissionDate,
                status: status,
                qrToken: qrToken,
                photoUrl: photoUrl,
                studentCnic: studentCnic,
                fatherCnic: fatherCnic,
                isVaccinated: isVaccinated,
                vaccineFirstDoseDate: vaccineFirstDoseDate,
                vaccineSecondDoseDate: vaccineSecondDoseDate,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudentsTable, Student>(table),
                  BaseReferences<_$AppDatabase, $StudentsTable, Student>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, BaseReferences<_$AppDatabase, $StudentsTable, Student>),
      Student,
      PrefetchHooks Function()
    >;
typedef $$ParentContactsTableCreateCompanionBuilder =
    ParentContactsCompanion Function({
      required String id,
      required String studentId,
      required String relation,
      required String phoneNumber,
      Value<bool> whatsappEnabled,
      Value<bool> notifyAbsent,
      Value<bool> notifyLate,
      Value<bool> notifyLeave,
      required int createdAt,
      required int updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$ParentContactsTableUpdateCompanionBuilder =
    ParentContactsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String> relation,
      Value<String> phoneNumber,
      Value<bool> whatsappEnabled,
      Value<bool> notifyAbsent,
      Value<bool> notifyLate,
      Value<bool> notifyLeave,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$ParentContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ParentContactsTable> {
  $$ParentContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get whatsappEnabled => $composableBuilder(
    column: $table.whatsappEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyAbsent => $composableBuilder(
    column: $table.notifyAbsent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyLate => $composableBuilder(
    column: $table.notifyLate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyLeave => $composableBuilder(
    column: $table.notifyLeave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ParentContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParentContactsTable> {
  $$ParentContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get whatsappEnabled => $composableBuilder(
    column: $table.whatsappEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyAbsent => $composableBuilder(
    column: $table.notifyAbsent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyLate => $composableBuilder(
    column: $table.notifyLate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyLeave => $composableBuilder(
    column: $table.notifyLeave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ParentContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParentContactsTable> {
  $$ParentContactsTableAnnotationComposer({
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

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get whatsappEnabled => $composableBuilder(
    column: $table.whatsappEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyAbsent => $composableBuilder(
    column: $table.notifyAbsent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyLate => $composableBuilder(
    column: $table.notifyLate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyLeave => $composableBuilder(
    column: $table.notifyLeave,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$ParentContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParentContactsTable,
          ParentContact,
          $$ParentContactsTableFilterComposer,
          $$ParentContactsTableOrderingComposer,
          $$ParentContactsTableAnnotationComposer,
          $$ParentContactsTableCreateCompanionBuilder,
          $$ParentContactsTableUpdateCompanionBuilder,
          (
            ParentContact,
            BaseReferences<_$AppDatabase, $ParentContactsTable, ParentContact>,
          ),
          ParentContact,
          PrefetchHooks Function()
        > {
  $$ParentContactsTableTableManager(
    _$AppDatabase db,
    $ParentContactsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParentContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParentContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParentContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> relation = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<bool> whatsappEnabled = const Value.absent(),
                Value<bool> notifyAbsent = const Value.absent(),
                Value<bool> notifyLate = const Value.absent(),
                Value<bool> notifyLeave = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParentContactsCompanion(
                id: id,
                studentId: studentId,
                relation: relation,
                phoneNumber: phoneNumber,
                whatsappEnabled: whatsappEnabled,
                notifyAbsent: notifyAbsent,
                notifyLate: notifyLate,
                notifyLeave: notifyLeave,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String relation,
                required String phoneNumber,
                Value<bool> whatsappEnabled = const Value.absent(),
                Value<bool> notifyAbsent = const Value.absent(),
                Value<bool> notifyLate = const Value.absent(),
                Value<bool> notifyLeave = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParentContactsCompanion.insert(
                id: id,
                studentId: studentId,
                relation: relation,
                phoneNumber: phoneNumber,
                whatsappEnabled: whatsappEnabled,
                notifyAbsent: notifyAbsent,
                notifyLate: notifyLate,
                notifyLeave: notifyLeave,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ParentContactsTable, ParentContact>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ParentContactsTable,
                    ParentContact
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ParentContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParentContactsTable,
      ParentContact,
      $$ParentContactsTableFilterComposer,
      $$ParentContactsTableOrderingComposer,
      $$ParentContactsTableAnnotationComposer,
      $$ParentContactsTableCreateCompanionBuilder,
      $$ParentContactsTableUpdateCompanionBuilder,
      (
        ParentContact,
        BaseReferences<_$AppDatabase, $ParentContactsTable, ParentContact>,
      ),
      ParentContact,
      PrefetchHooks Function()
    >;
typedef $$SchoolCalendarHolidaysTableCreateCompanionBuilder =
    SchoolCalendarHolidaysCompanion Function({
      required String id,
      required String schoolId,
      required String date,
      required String description,
      Value<bool> isInstructionalDay,
      required int createdAt,
      required int updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$SchoolCalendarHolidaysTableUpdateCompanionBuilder =
    SchoolCalendarHolidaysCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> date,
      Value<String> description,
      Value<bool> isInstructionalDay,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$SchoolCalendarHolidaysTableFilterComposer
    extends Composer<_$AppDatabase, $SchoolCalendarHolidaysTable> {
  $$SchoolCalendarHolidaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInstructionalDay => $composableBuilder(
    column: $table.isInstructionalDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchoolCalendarHolidaysTableOrderingComposer
    extends Composer<_$AppDatabase, $SchoolCalendarHolidaysTable> {
  $$SchoolCalendarHolidaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInstructionalDay => $composableBuilder(
    column: $table.isInstructionalDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchoolCalendarHolidaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchoolCalendarHolidaysTable> {
  $$SchoolCalendarHolidaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isInstructionalDay => $composableBuilder(
    column: $table.isInstructionalDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$SchoolCalendarHolidaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchoolCalendarHolidaysTable,
          SchoolCalendarHoliday,
          $$SchoolCalendarHolidaysTableFilterComposer,
          $$SchoolCalendarHolidaysTableOrderingComposer,
          $$SchoolCalendarHolidaysTableAnnotationComposer,
          $$SchoolCalendarHolidaysTableCreateCompanionBuilder,
          $$SchoolCalendarHolidaysTableUpdateCompanionBuilder,
          (
            SchoolCalendarHoliday,
            BaseReferences<
              _$AppDatabase,
              $SchoolCalendarHolidaysTable,
              SchoolCalendarHoliday
            >,
          ),
          SchoolCalendarHoliday,
          PrefetchHooks Function()
        > {
  $$SchoolCalendarHolidaysTableTableManager(
    _$AppDatabase db,
    $SchoolCalendarHolidaysTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchoolCalendarHolidaysTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SchoolCalendarHolidaysTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SchoolCalendarHolidaysTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> isInstructionalDay = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolCalendarHolidaysCompanion(
                id: id,
                schoolId: schoolId,
                date: date,
                description: description,
                isInstructionalDay: isInstructionalDay,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String date,
                required String description,
                Value<bool> isInstructionalDay = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolCalendarHolidaysCompanion.insert(
                id: id,
                schoolId: schoolId,
                date: date,
                description: description,
                isInstructionalDay: isInstructionalDay,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $SchoolCalendarHolidaysTable,
                    SchoolCalendarHoliday
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SchoolCalendarHolidaysTable,
                    SchoolCalendarHoliday
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchoolCalendarHolidaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchoolCalendarHolidaysTable,
      SchoolCalendarHoliday,
      $$SchoolCalendarHolidaysTableFilterComposer,
      $$SchoolCalendarHolidaysTableOrderingComposer,
      $$SchoolCalendarHolidaysTableAnnotationComposer,
      $$SchoolCalendarHolidaysTableCreateCompanionBuilder,
      $$SchoolCalendarHolidaysTableUpdateCompanionBuilder,
      (
        SchoolCalendarHoliday,
        BaseReferences<
          _$AppDatabase,
          $SchoolCalendarHolidaysTable,
          SchoolCalendarHoliday
        >,
      ),
      SchoolCalendarHoliday,
      PrefetchHooks Function()
    >;
typedef $$AttendanceRecordsTableCreateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      required String id,
      required String schoolId,
      required String studentId,
      required String classId,
      required String sectionId,
      required String date,
      required String status,
      Value<String?> arrivalTime,
      Value<String?> departureTime,
      Value<String?> remarks,
      required String markedByUserId,
      required String markingMethod,
      required String idempotencyKey,
      required int createdAt,
      required int updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$AttendanceRecordsTableUpdateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> studentId,
      Value<String> classId,
      Value<String> sectionId,
      Value<String> date,
      Value<String> status,
      Value<String?> arrivalTime,
      Value<String?> departureTime,
      Value<String?> remarks,
      Value<String> markedByUserId,
      Value<String> markingMethod,
      Value<String> idempotencyKey,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$AttendanceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get departureTime => $composableBuilder(
    column: $table.departureTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markedByUserId => $composableBuilder(
    column: $table.markedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markingMethod => $composableBuilder(
    column: $table.markingMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendanceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departureTime => $composableBuilder(
    column: $table.departureTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markedByUserId => $composableBuilder(
    column: $table.markedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markingMethod => $composableBuilder(
    column: $table.markingMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendanceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get departureTime => $composableBuilder(
    column: $table.departureTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get markedByUserId => $composableBuilder(
    column: $table.markedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get markingMethod => $composableBuilder(
    column: $table.markingMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$AttendanceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRecord,
          $$AttendanceRecordsTableFilterComposer,
          $$AttendanceRecordsTableOrderingComposer,
          $$AttendanceRecordsTableAnnotationComposer,
          $$AttendanceRecordsTableCreateCompanionBuilder,
          $$AttendanceRecordsTableUpdateCompanionBuilder,
          (
            AttendanceRecord,
            BaseReferences<
              _$AppDatabase,
              $AttendanceRecordsTable,
              AttendanceRecord
            >,
          ),
          AttendanceRecord,
          PrefetchHooks Function()
        > {
  $$AttendanceRecordsTableTableManager(
    _$AppDatabase db,
    $AttendanceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> arrivalTime = const Value.absent(),
                Value<String?> departureTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String> markedByUserId = const Value.absent(),
                Value<String> markingMethod = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceRecordsCompanion(
                id: id,
                schoolId: schoolId,
                studentId: studentId,
                classId: classId,
                sectionId: sectionId,
                date: date,
                status: status,
                arrivalTime: arrivalTime,
                departureTime: departureTime,
                remarks: remarks,
                markedByUserId: markedByUserId,
                markingMethod: markingMethod,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String studentId,
                required String classId,
                required String sectionId,
                required String date,
                required String status,
                Value<String?> arrivalTime = const Value.absent(),
                Value<String?> departureTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                required String markedByUserId,
                required String markingMethod,
                required String idempotencyKey,
                required int createdAt,
                required int updatedAt,
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceRecordsCompanion.insert(
                id: id,
                schoolId: schoolId,
                studentId: studentId,
                classId: classId,
                sectionId: sectionId,
                date: date,
                status: status,
                arrivalTime: arrivalTime,
                departureTime: departureTime,
                remarks: remarks,
                markedByUserId: markedByUserId,
                markingMethod: markingMethod,
                idempotencyKey: idempotencyKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendanceRecordsTable, AttendanceRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AttendanceRecordsTable,
                    AttendanceRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendanceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceRecordsTable,
      AttendanceRecord,
      $$AttendanceRecordsTableFilterComposer,
      $$AttendanceRecordsTableOrderingComposer,
      $$AttendanceRecordsTableAnnotationComposer,
      $$AttendanceRecordsTableCreateCompanionBuilder,
      $$AttendanceRecordsTableUpdateCompanionBuilder,
      (
        AttendanceRecord,
        BaseReferences<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRecord
        >,
      ),
      AttendanceRecord,
      PrefetchHooks Function()
    >;
typedef $$AttendanceAuditLogsTableCreateCompanionBuilder =
    AttendanceAuditLogsCompanion Function({
      required String id,
      required String attendanceRecordId,
      required String changedByUserId,
      Value<String?> oldStatus,
      required String newStatus,
      required String reason,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$AttendanceAuditLogsTableUpdateCompanionBuilder =
    AttendanceAuditLogsCompanion Function({
      Value<String> id,
      Value<String> attendanceRecordId,
      Value<String> changedByUserId,
      Value<String?> oldStatus,
      Value<String> newStatus,
      Value<String> reason,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$AttendanceAuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceAuditLogsTable> {
  $$AttendanceAuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attendanceRecordId => $composableBuilder(
    column: $table.attendanceRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changedByUserId => $composableBuilder(
    column: $table.changedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldStatus => $composableBuilder(
    column: $table.oldStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newStatus => $composableBuilder(
    column: $table.newStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendanceAuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceAuditLogsTable> {
  $$AttendanceAuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attendanceRecordId => $composableBuilder(
    column: $table.attendanceRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changedByUserId => $composableBuilder(
    column: $table.changedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldStatus => $composableBuilder(
    column: $table.oldStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newStatus => $composableBuilder(
    column: $table.newStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendanceAuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceAuditLogsTable> {
  $$AttendanceAuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get attendanceRecordId => $composableBuilder(
    column: $table.attendanceRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get changedByUserId => $composableBuilder(
    column: $table.changedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oldStatus =>
      $composableBuilder(column: $table.oldStatus, builder: (column) => column);

  GeneratedColumn<String> get newStatus =>
      $composableBuilder(column: $table.newStatus, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AttendanceAuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceAuditLogsTable,
          AttendanceAuditLog,
          $$AttendanceAuditLogsTableFilterComposer,
          $$AttendanceAuditLogsTableOrderingComposer,
          $$AttendanceAuditLogsTableAnnotationComposer,
          $$AttendanceAuditLogsTableCreateCompanionBuilder,
          $$AttendanceAuditLogsTableUpdateCompanionBuilder,
          (
            AttendanceAuditLog,
            BaseReferences<
              _$AppDatabase,
              $AttendanceAuditLogsTable,
              AttendanceAuditLog
            >,
          ),
          AttendanceAuditLog,
          PrefetchHooks Function()
        > {
  $$AttendanceAuditLogsTableTableManager(
    _$AppDatabase db,
    $AttendanceAuditLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceAuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceAuditLogsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AttendanceAuditLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> attendanceRecordId = const Value.absent(),
                Value<String> changedByUserId = const Value.absent(),
                Value<String?> oldStatus = const Value.absent(),
                Value<String> newStatus = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceAuditLogsCompanion(
                id: id,
                attendanceRecordId: attendanceRecordId,
                changedByUserId: changedByUserId,
                oldStatus: oldStatus,
                newStatus: newStatus,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String attendanceRecordId,
                required String changedByUserId,
                Value<String?> oldStatus = const Value.absent(),
                required String newStatus,
                required String reason,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttendanceAuditLogsCompanion.insert(
                id: id,
                attendanceRecordId: attendanceRecordId,
                changedByUserId: changedByUserId,
                oldStatus: oldStatus,
                newStatus: newStatus,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendanceAuditLogsTable, AttendanceAuditLog>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $AttendanceAuditLogsTable,
                    AttendanceAuditLog
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendanceAuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceAuditLogsTable,
      AttendanceAuditLog,
      $$AttendanceAuditLogsTableFilterComposer,
      $$AttendanceAuditLogsTableOrderingComposer,
      $$AttendanceAuditLogsTableAnnotationComposer,
      $$AttendanceAuditLogsTableCreateCompanionBuilder,
      $$AttendanceAuditLogsTableUpdateCompanionBuilder,
      (
        AttendanceAuditLog,
        BaseReferences<
          _$AppDatabase,
          $AttendanceAuditLogsTable,
          AttendanceAuditLog
        >,
      ),
      AttendanceAuditLog,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String targetTable,
      required String recordId,
      required String operation,
      required String payloadJson,
      required String idempotencyKey,
      Value<int> clientRevision,
      required int createdAt,
      Value<int> retryCount,
      Value<String> status,
      Value<String?> errorMessage,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> targetTable,
      Value<String> recordId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<String> idempotencyKey,
      Value<int> clientRevision,
      Value<int> createdAt,
      Value<int> retryCount,
      Value<String> status,
      Value<String?> errorMessage,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
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

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientRevision => $composableBuilder(
    column: $table.clientRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
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

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientRevision => $composableBuilder(
    column: $table.clientRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get clientRevision => $composableBuilder(
    column: $table.clientRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> clientRevision = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                targetTable: targetTable,
                recordId: recordId,
                operation: operation,
                payloadJson: payloadJson,
                idempotencyKey: idempotencyKey,
                clientRevision: clientRevision,
                createdAt: createdAt,
                retryCount: retryCount,
                status: status,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String targetTable,
                required String recordId,
                required String operation,
                required String payloadJson,
                required String idempotencyKey,
                Value<int> clientRevision = const Value.absent(),
                required int createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                targetTable: targetTable,
                recordId: recordId,
                operation: operation,
                payloadJson: payloadJson,
                idempotencyKey: idempotencyKey,
                clientRevision: clientRevision,
                createdAt: createdAt,
                retryCount: retryCount,
                status: status,
                errorMessage: errorMessage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncQueueTable, SyncQueueData>(table),
                  BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$SchoolSettingsTableCreateCompanionBuilder =
    SchoolSettingsCompanion Function({
      required String schoolId,
      Value<String> schoolType,
      Value<String> district,
      Value<String> tehsil,
      Value<String> circleOffice,
      Value<String> unionCouncil,
      Value<String> climateZone,
      Value<String> openingTime,
      Value<String> closingTime,
      Value<String> lateCutoffTime,
      Value<String> headTeacherName,
      Value<String> deoName,
      Value<String> circleSdeoName,
      Value<String> centerInchargeName,
      Value<String> goshwaraNo,
      Value<String> naConstituency,
      Value<String> pkConstituency,
      Value<String> ltrcCenter,
      Value<int> sanctionedPostsPsht,
      Value<int> sanctionedPostsSpst,
      Value<int> sanctionedPostsPst,
      Value<int> vacantPostsPst,
      Value<int> vacantPostsChowkidar,
      Value<int> classroomsInstructional,
      Value<int> classroomsNonInstructional,
      Value<String> establishmentYear,
      Value<String> constructionYear,
      Value<int> facilityElectricity,
      Value<int> facilityWaterPipe,
      Value<int> facilityWaterWell,
      Value<int> facilitySolar,
      Value<int> facilityBoundaryWall,
      Value<int> facilityPlayArea,
      Value<int> facilityOffice,
      Value<int> facilityToiletCount,
      Value<String> ptcChairmanName,
      Value<String> ptcBankName,
      Value<String> ptcAccountNo,
      Value<String> ptcSanctionDate,
      Value<double> fundTotalBudget,
      Value<double> fundTotalSpent,
      Value<String> workingDaysCsv,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$SchoolSettingsTableUpdateCompanionBuilder =
    SchoolSettingsCompanion Function({
      Value<String> schoolId,
      Value<String> schoolType,
      Value<String> district,
      Value<String> tehsil,
      Value<String> circleOffice,
      Value<String> unionCouncil,
      Value<String> climateZone,
      Value<String> openingTime,
      Value<String> closingTime,
      Value<String> lateCutoffTime,
      Value<String> headTeacherName,
      Value<String> deoName,
      Value<String> circleSdeoName,
      Value<String> centerInchargeName,
      Value<String> goshwaraNo,
      Value<String> naConstituency,
      Value<String> pkConstituency,
      Value<String> ltrcCenter,
      Value<int> sanctionedPostsPsht,
      Value<int> sanctionedPostsSpst,
      Value<int> sanctionedPostsPst,
      Value<int> vacantPostsPst,
      Value<int> vacantPostsChowkidar,
      Value<int> classroomsInstructional,
      Value<int> classroomsNonInstructional,
      Value<String> establishmentYear,
      Value<String> constructionYear,
      Value<int> facilityElectricity,
      Value<int> facilityWaterPipe,
      Value<int> facilityWaterWell,
      Value<int> facilitySolar,
      Value<int> facilityBoundaryWall,
      Value<int> facilityPlayArea,
      Value<int> facilityOffice,
      Value<int> facilityToiletCount,
      Value<String> ptcChairmanName,
      Value<String> ptcBankName,
      Value<String> ptcAccountNo,
      Value<String> ptcSanctionDate,
      Value<double> fundTotalBudget,
      Value<double> fundTotalSpent,
      Value<String> workingDaysCsv,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$SchoolSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SchoolSettingsTable> {
  $$SchoolSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolType => $composableBuilder(
    column: $table.schoolType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tehsil => $composableBuilder(
    column: $table.tehsil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get circleOffice => $composableBuilder(
    column: $table.circleOffice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unionCouncil => $composableBuilder(
    column: $table.unionCouncil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get climateZone => $composableBuilder(
    column: $table.climateZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openingTime => $composableBuilder(
    column: $table.openingTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closingTime => $composableBuilder(
    column: $table.closingTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lateCutoffTime => $composableBuilder(
    column: $table.lateCutoffTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headTeacherName => $composableBuilder(
    column: $table.headTeacherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deoName => $composableBuilder(
    column: $table.deoName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get circleSdeoName => $composableBuilder(
    column: $table.circleSdeoName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get centerInchargeName => $composableBuilder(
    column: $table.centerInchargeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goshwaraNo => $composableBuilder(
    column: $table.goshwaraNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naConstituency => $composableBuilder(
    column: $table.naConstituency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pkConstituency => $composableBuilder(
    column: $table.pkConstituency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ltrcCenter => $composableBuilder(
    column: $table.ltrcCenter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sanctionedPostsPsht => $composableBuilder(
    column: $table.sanctionedPostsPsht,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sanctionedPostsSpst => $composableBuilder(
    column: $table.sanctionedPostsSpst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sanctionedPostsPst => $composableBuilder(
    column: $table.sanctionedPostsPst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vacantPostsPst => $composableBuilder(
    column: $table.vacantPostsPst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vacantPostsChowkidar => $composableBuilder(
    column: $table.vacantPostsChowkidar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get classroomsInstructional => $composableBuilder(
    column: $table.classroomsInstructional,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get classroomsNonInstructional => $composableBuilder(
    column: $table.classroomsNonInstructional,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get establishmentYear => $composableBuilder(
    column: $table.establishmentYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get constructionYear => $composableBuilder(
    column: $table.constructionYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get facilityElectricity => $composableBuilder(
    column: $table.facilityElectricity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get facilityWaterPipe => $composableBuilder(
    column: $table.facilityWaterPipe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get facilityWaterWell => $composableBuilder(
    column: $table.facilityWaterWell,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get facilitySolar => $composableBuilder(
    column: $table.facilitySolar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get facilityBoundaryWall => $composableBuilder(
    column: $table.facilityBoundaryWall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get facilityPlayArea => $composableBuilder(
    column: $table.facilityPlayArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get facilityOffice => $composableBuilder(
    column: $table.facilityOffice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get facilityToiletCount => $composableBuilder(
    column: $table.facilityToiletCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ptcChairmanName => $composableBuilder(
    column: $table.ptcChairmanName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ptcBankName => $composableBuilder(
    column: $table.ptcBankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ptcAccountNo => $composableBuilder(
    column: $table.ptcAccountNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ptcSanctionDate => $composableBuilder(
    column: $table.ptcSanctionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fundTotalBudget => $composableBuilder(
    column: $table.fundTotalBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fundTotalSpent => $composableBuilder(
    column: $table.fundTotalSpent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workingDaysCsv => $composableBuilder(
    column: $table.workingDaysCsv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchoolSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SchoolSettingsTable> {
  $$SchoolSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolType => $composableBuilder(
    column: $table.schoolType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tehsil => $composableBuilder(
    column: $table.tehsil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get circleOffice => $composableBuilder(
    column: $table.circleOffice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unionCouncil => $composableBuilder(
    column: $table.unionCouncil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get climateZone => $composableBuilder(
    column: $table.climateZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openingTime => $composableBuilder(
    column: $table.openingTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closingTime => $composableBuilder(
    column: $table.closingTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lateCutoffTime => $composableBuilder(
    column: $table.lateCutoffTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headTeacherName => $composableBuilder(
    column: $table.headTeacherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deoName => $composableBuilder(
    column: $table.deoName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get circleSdeoName => $composableBuilder(
    column: $table.circleSdeoName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get centerInchargeName => $composableBuilder(
    column: $table.centerInchargeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goshwaraNo => $composableBuilder(
    column: $table.goshwaraNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naConstituency => $composableBuilder(
    column: $table.naConstituency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pkConstituency => $composableBuilder(
    column: $table.pkConstituency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ltrcCenter => $composableBuilder(
    column: $table.ltrcCenter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sanctionedPostsPsht => $composableBuilder(
    column: $table.sanctionedPostsPsht,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sanctionedPostsSpst => $composableBuilder(
    column: $table.sanctionedPostsSpst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sanctionedPostsPst => $composableBuilder(
    column: $table.sanctionedPostsPst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vacantPostsPst => $composableBuilder(
    column: $table.vacantPostsPst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vacantPostsChowkidar => $composableBuilder(
    column: $table.vacantPostsChowkidar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get classroomsInstructional => $composableBuilder(
    column: $table.classroomsInstructional,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get classroomsNonInstructional => $composableBuilder(
    column: $table.classroomsNonInstructional,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get establishmentYear => $composableBuilder(
    column: $table.establishmentYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get constructionYear => $composableBuilder(
    column: $table.constructionYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get facilityElectricity => $composableBuilder(
    column: $table.facilityElectricity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get facilityWaterPipe => $composableBuilder(
    column: $table.facilityWaterPipe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get facilityWaterWell => $composableBuilder(
    column: $table.facilityWaterWell,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get facilitySolar => $composableBuilder(
    column: $table.facilitySolar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get facilityBoundaryWall => $composableBuilder(
    column: $table.facilityBoundaryWall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get facilityPlayArea => $composableBuilder(
    column: $table.facilityPlayArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get facilityOffice => $composableBuilder(
    column: $table.facilityOffice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get facilityToiletCount => $composableBuilder(
    column: $table.facilityToiletCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ptcChairmanName => $composableBuilder(
    column: $table.ptcChairmanName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ptcBankName => $composableBuilder(
    column: $table.ptcBankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ptcAccountNo => $composableBuilder(
    column: $table.ptcAccountNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ptcSanctionDate => $composableBuilder(
    column: $table.ptcSanctionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fundTotalBudget => $composableBuilder(
    column: $table.fundTotalBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fundTotalSpent => $composableBuilder(
    column: $table.fundTotalSpent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workingDaysCsv => $composableBuilder(
    column: $table.workingDaysCsv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchoolSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchoolSettingsTable> {
  $$SchoolSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get schoolType => $composableBuilder(
    column: $table.schoolType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get tehsil =>
      $composableBuilder(column: $table.tehsil, builder: (column) => column);

  GeneratedColumn<String> get circleOffice => $composableBuilder(
    column: $table.circleOffice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unionCouncil => $composableBuilder(
    column: $table.unionCouncil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get climateZone => $composableBuilder(
    column: $table.climateZone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openingTime => $composableBuilder(
    column: $table.openingTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closingTime => $composableBuilder(
    column: $table.closingTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lateCutoffTime => $composableBuilder(
    column: $table.lateCutoffTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get headTeacherName => $composableBuilder(
    column: $table.headTeacherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deoName =>
      $composableBuilder(column: $table.deoName, builder: (column) => column);

  GeneratedColumn<String> get circleSdeoName => $composableBuilder(
    column: $table.circleSdeoName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get centerInchargeName => $composableBuilder(
    column: $table.centerInchargeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get goshwaraNo => $composableBuilder(
    column: $table.goshwaraNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naConstituency => $composableBuilder(
    column: $table.naConstituency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pkConstituency => $composableBuilder(
    column: $table.pkConstituency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ltrcCenter => $composableBuilder(
    column: $table.ltrcCenter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sanctionedPostsPsht => $composableBuilder(
    column: $table.sanctionedPostsPsht,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sanctionedPostsSpst => $composableBuilder(
    column: $table.sanctionedPostsSpst,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sanctionedPostsPst => $composableBuilder(
    column: $table.sanctionedPostsPst,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vacantPostsPst => $composableBuilder(
    column: $table.vacantPostsPst,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vacantPostsChowkidar => $composableBuilder(
    column: $table.vacantPostsChowkidar,
    builder: (column) => column,
  );

  GeneratedColumn<int> get classroomsInstructional => $composableBuilder(
    column: $table.classroomsInstructional,
    builder: (column) => column,
  );

  GeneratedColumn<int> get classroomsNonInstructional => $composableBuilder(
    column: $table.classroomsNonInstructional,
    builder: (column) => column,
  );

  GeneratedColumn<String> get establishmentYear => $composableBuilder(
    column: $table.establishmentYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get constructionYear => $composableBuilder(
    column: $table.constructionYear,
    builder: (column) => column,
  );

  GeneratedColumn<int> get facilityElectricity => $composableBuilder(
    column: $table.facilityElectricity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get facilityWaterPipe => $composableBuilder(
    column: $table.facilityWaterPipe,
    builder: (column) => column,
  );

  GeneratedColumn<int> get facilityWaterWell => $composableBuilder(
    column: $table.facilityWaterWell,
    builder: (column) => column,
  );

  GeneratedColumn<int> get facilitySolar => $composableBuilder(
    column: $table.facilitySolar,
    builder: (column) => column,
  );

  GeneratedColumn<int> get facilityBoundaryWall => $composableBuilder(
    column: $table.facilityBoundaryWall,
    builder: (column) => column,
  );

  GeneratedColumn<int> get facilityPlayArea => $composableBuilder(
    column: $table.facilityPlayArea,
    builder: (column) => column,
  );

  GeneratedColumn<int> get facilityOffice => $composableBuilder(
    column: $table.facilityOffice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get facilityToiletCount => $composableBuilder(
    column: $table.facilityToiletCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ptcChairmanName => $composableBuilder(
    column: $table.ptcChairmanName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ptcBankName => $composableBuilder(
    column: $table.ptcBankName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ptcAccountNo => $composableBuilder(
    column: $table.ptcAccountNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ptcSanctionDate => $composableBuilder(
    column: $table.ptcSanctionDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fundTotalBudget => $composableBuilder(
    column: $table.fundTotalBudget,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fundTotalSpent => $composableBuilder(
    column: $table.fundTotalSpent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workingDaysCsv => $composableBuilder(
    column: $table.workingDaysCsv,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$SchoolSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchoolSettingsTable,
          SchoolSettingsEntry,
          $$SchoolSettingsTableFilterComposer,
          $$SchoolSettingsTableOrderingComposer,
          $$SchoolSettingsTableAnnotationComposer,
          $$SchoolSettingsTableCreateCompanionBuilder,
          $$SchoolSettingsTableUpdateCompanionBuilder,
          (
            SchoolSettingsEntry,
            BaseReferences<
              _$AppDatabase,
              $SchoolSettingsTable,
              SchoolSettingsEntry
            >,
          ),
          SchoolSettingsEntry,
          PrefetchHooks Function()
        > {
  $$SchoolSettingsTableTableManager(
    _$AppDatabase db,
    $SchoolSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchoolSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchoolSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchoolSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> schoolId = const Value.absent(),
                Value<String> schoolType = const Value.absent(),
                Value<String> district = const Value.absent(),
                Value<String> tehsil = const Value.absent(),
                Value<String> circleOffice = const Value.absent(),
                Value<String> unionCouncil = const Value.absent(),
                Value<String> climateZone = const Value.absent(),
                Value<String> openingTime = const Value.absent(),
                Value<String> closingTime = const Value.absent(),
                Value<String> lateCutoffTime = const Value.absent(),
                Value<String> headTeacherName = const Value.absent(),
                Value<String> deoName = const Value.absent(),
                Value<String> circleSdeoName = const Value.absent(),
                Value<String> centerInchargeName = const Value.absent(),
                Value<String> goshwaraNo = const Value.absent(),
                Value<String> naConstituency = const Value.absent(),
                Value<String> pkConstituency = const Value.absent(),
                Value<String> ltrcCenter = const Value.absent(),
                Value<int> sanctionedPostsPsht = const Value.absent(),
                Value<int> sanctionedPostsSpst = const Value.absent(),
                Value<int> sanctionedPostsPst = const Value.absent(),
                Value<int> vacantPostsPst = const Value.absent(),
                Value<int> vacantPostsChowkidar = const Value.absent(),
                Value<int> classroomsInstructional = const Value.absent(),
                Value<int> classroomsNonInstructional = const Value.absent(),
                Value<String> establishmentYear = const Value.absent(),
                Value<String> constructionYear = const Value.absent(),
                Value<int> facilityElectricity = const Value.absent(),
                Value<int> facilityWaterPipe = const Value.absent(),
                Value<int> facilityWaterWell = const Value.absent(),
                Value<int> facilitySolar = const Value.absent(),
                Value<int> facilityBoundaryWall = const Value.absent(),
                Value<int> facilityPlayArea = const Value.absent(),
                Value<int> facilityOffice = const Value.absent(),
                Value<int> facilityToiletCount = const Value.absent(),
                Value<String> ptcChairmanName = const Value.absent(),
                Value<String> ptcBankName = const Value.absent(),
                Value<String> ptcAccountNo = const Value.absent(),
                Value<String> ptcSanctionDate = const Value.absent(),
                Value<double> fundTotalBudget = const Value.absent(),
                Value<double> fundTotalSpent = const Value.absent(),
                Value<String> workingDaysCsv = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolSettingsCompanion(
                schoolId: schoolId,
                schoolType: schoolType,
                district: district,
                tehsil: tehsil,
                circleOffice: circleOffice,
                unionCouncil: unionCouncil,
                climateZone: climateZone,
                openingTime: openingTime,
                closingTime: closingTime,
                lateCutoffTime: lateCutoffTime,
                headTeacherName: headTeacherName,
                deoName: deoName,
                circleSdeoName: circleSdeoName,
                centerInchargeName: centerInchargeName,
                goshwaraNo: goshwaraNo,
                naConstituency: naConstituency,
                pkConstituency: pkConstituency,
                ltrcCenter: ltrcCenter,
                sanctionedPostsPsht: sanctionedPostsPsht,
                sanctionedPostsSpst: sanctionedPostsSpst,
                sanctionedPostsPst: sanctionedPostsPst,
                vacantPostsPst: vacantPostsPst,
                vacantPostsChowkidar: vacantPostsChowkidar,
                classroomsInstructional: classroomsInstructional,
                classroomsNonInstructional: classroomsNonInstructional,
                establishmentYear: establishmentYear,
                constructionYear: constructionYear,
                facilityElectricity: facilityElectricity,
                facilityWaterPipe: facilityWaterPipe,
                facilityWaterWell: facilityWaterWell,
                facilitySolar: facilitySolar,
                facilityBoundaryWall: facilityBoundaryWall,
                facilityPlayArea: facilityPlayArea,
                facilityOffice: facilityOffice,
                facilityToiletCount: facilityToiletCount,
                ptcChairmanName: ptcChairmanName,
                ptcBankName: ptcBankName,
                ptcAccountNo: ptcAccountNo,
                ptcSanctionDate: ptcSanctionDate,
                fundTotalBudget: fundTotalBudget,
                fundTotalSpent: fundTotalSpent,
                workingDaysCsv: workingDaysCsv,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String schoolId,
                Value<String> schoolType = const Value.absent(),
                Value<String> district = const Value.absent(),
                Value<String> tehsil = const Value.absent(),
                Value<String> circleOffice = const Value.absent(),
                Value<String> unionCouncil = const Value.absent(),
                Value<String> climateZone = const Value.absent(),
                Value<String> openingTime = const Value.absent(),
                Value<String> closingTime = const Value.absent(),
                Value<String> lateCutoffTime = const Value.absent(),
                Value<String> headTeacherName = const Value.absent(),
                Value<String> deoName = const Value.absent(),
                Value<String> circleSdeoName = const Value.absent(),
                Value<String> centerInchargeName = const Value.absent(),
                Value<String> goshwaraNo = const Value.absent(),
                Value<String> naConstituency = const Value.absent(),
                Value<String> pkConstituency = const Value.absent(),
                Value<String> ltrcCenter = const Value.absent(),
                Value<int> sanctionedPostsPsht = const Value.absent(),
                Value<int> sanctionedPostsSpst = const Value.absent(),
                Value<int> sanctionedPostsPst = const Value.absent(),
                Value<int> vacantPostsPst = const Value.absent(),
                Value<int> vacantPostsChowkidar = const Value.absent(),
                Value<int> classroomsInstructional = const Value.absent(),
                Value<int> classroomsNonInstructional = const Value.absent(),
                Value<String> establishmentYear = const Value.absent(),
                Value<String> constructionYear = const Value.absent(),
                Value<int> facilityElectricity = const Value.absent(),
                Value<int> facilityWaterPipe = const Value.absent(),
                Value<int> facilityWaterWell = const Value.absent(),
                Value<int> facilitySolar = const Value.absent(),
                Value<int> facilityBoundaryWall = const Value.absent(),
                Value<int> facilityPlayArea = const Value.absent(),
                Value<int> facilityOffice = const Value.absent(),
                Value<int> facilityToiletCount = const Value.absent(),
                Value<String> ptcChairmanName = const Value.absent(),
                Value<String> ptcBankName = const Value.absent(),
                Value<String> ptcAccountNo = const Value.absent(),
                Value<String> ptcSanctionDate = const Value.absent(),
                Value<double> fundTotalBudget = const Value.absent(),
                Value<double> fundTotalSpent = const Value.absent(),
                Value<String> workingDaysCsv = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolSettingsCompanion.insert(
                schoolId: schoolId,
                schoolType: schoolType,
                district: district,
                tehsil: tehsil,
                circleOffice: circleOffice,
                unionCouncil: unionCouncil,
                climateZone: climateZone,
                openingTime: openingTime,
                closingTime: closingTime,
                lateCutoffTime: lateCutoffTime,
                headTeacherName: headTeacherName,
                deoName: deoName,
                circleSdeoName: circleSdeoName,
                centerInchargeName: centerInchargeName,
                goshwaraNo: goshwaraNo,
                naConstituency: naConstituency,
                pkConstituency: pkConstituency,
                ltrcCenter: ltrcCenter,
                sanctionedPostsPsht: sanctionedPostsPsht,
                sanctionedPostsSpst: sanctionedPostsSpst,
                sanctionedPostsPst: sanctionedPostsPst,
                vacantPostsPst: vacantPostsPst,
                vacantPostsChowkidar: vacantPostsChowkidar,
                classroomsInstructional: classroomsInstructional,
                classroomsNonInstructional: classroomsNonInstructional,
                establishmentYear: establishmentYear,
                constructionYear: constructionYear,
                facilityElectricity: facilityElectricity,
                facilityWaterPipe: facilityWaterPipe,
                facilityWaterWell: facilityWaterWell,
                facilitySolar: facilitySolar,
                facilityBoundaryWall: facilityBoundaryWall,
                facilityPlayArea: facilityPlayArea,
                facilityOffice: facilityOffice,
                facilityToiletCount: facilityToiletCount,
                ptcChairmanName: ptcChairmanName,
                ptcBankName: ptcBankName,
                ptcAccountNo: ptcAccountNo,
                ptcSanctionDate: ptcSanctionDate,
                fundTotalBudget: fundTotalBudget,
                fundTotalSpent: fundTotalSpent,
                workingDaysCsv: workingDaysCsv,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SchoolSettingsTable, SchoolSettingsEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SchoolSettingsTable,
                    SchoolSettingsEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchoolSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchoolSettingsTable,
      SchoolSettingsEntry,
      $$SchoolSettingsTableFilterComposer,
      $$SchoolSettingsTableOrderingComposer,
      $$SchoolSettingsTableAnnotationComposer,
      $$SchoolSettingsTableCreateCompanionBuilder,
      $$SchoolSettingsTableUpdateCompanionBuilder,
      (
        SchoolSettingsEntry,
        BaseReferences<
          _$AppDatabase,
          $SchoolSettingsTable,
          SchoolSettingsEntry
        >,
      ),
      SchoolSettingsEntry,
      PrefetchHooks Function()
    >;
typedef $$StudentExtendedInfoTableCreateCompanionBuilder =
    StudentExtendedInfoCompanion Function({
      required String studentId,
      Value<String?> studentBForm,
      Value<String?> fatherCnic,
      Value<String?> motherName,
      Value<String?> domicileDistrict,
      Value<String?> leavingDate,
      Value<String?> leavingReason,
      Value<String?> slcNumber,
      Value<int> freeBooksIssued,
      Value<int> isVaccinated,
      Value<String?> vaccineFirstDoseDate,
      Value<String?> vaccineSecondDoseDate,
      Value<String> previousQrTokensJson,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$StudentExtendedInfoTableUpdateCompanionBuilder =
    StudentExtendedInfoCompanion Function({
      Value<String> studentId,
      Value<String?> studentBForm,
      Value<String?> fatherCnic,
      Value<String?> motherName,
      Value<String?> domicileDistrict,
      Value<String?> leavingDate,
      Value<String?> leavingReason,
      Value<String?> slcNumber,
      Value<int> freeBooksIssued,
      Value<int> isVaccinated,
      Value<String?> vaccineFirstDoseDate,
      Value<String?> vaccineSecondDoseDate,
      Value<String> previousQrTokensJson,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$StudentExtendedInfoTableFilterComposer
    extends Composer<_$AppDatabase, $StudentExtendedInfoTable> {
  $$StudentExtendedInfoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentBForm => $composableBuilder(
    column: $table.studentBForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherCnic => $composableBuilder(
    column: $table.fatherCnic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motherName => $composableBuilder(
    column: $table.motherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domicileDistrict => $composableBuilder(
    column: $table.domicileDistrict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leavingDate => $composableBuilder(
    column: $table.leavingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leavingReason => $composableBuilder(
    column: $table.leavingReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slcNumber => $composableBuilder(
    column: $table.slcNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freeBooksIssued => $composableBuilder(
    column: $table.freeBooksIssued,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isVaccinated => $composableBuilder(
    column: $table.isVaccinated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vaccineFirstDoseDate => $composableBuilder(
    column: $table.vaccineFirstDoseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vaccineSecondDoseDate => $composableBuilder(
    column: $table.vaccineSecondDoseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousQrTokensJson => $composableBuilder(
    column: $table.previousQrTokensJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudentExtendedInfoTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentExtendedInfoTable> {
  $$StudentExtendedInfoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentBForm => $composableBuilder(
    column: $table.studentBForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherCnic => $composableBuilder(
    column: $table.fatherCnic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motherName => $composableBuilder(
    column: $table.motherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domicileDistrict => $composableBuilder(
    column: $table.domicileDistrict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leavingDate => $composableBuilder(
    column: $table.leavingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leavingReason => $composableBuilder(
    column: $table.leavingReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slcNumber => $composableBuilder(
    column: $table.slcNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freeBooksIssued => $composableBuilder(
    column: $table.freeBooksIssued,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isVaccinated => $composableBuilder(
    column: $table.isVaccinated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vaccineFirstDoseDate => $composableBuilder(
    column: $table.vaccineFirstDoseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vaccineSecondDoseDate => $composableBuilder(
    column: $table.vaccineSecondDoseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousQrTokensJson => $composableBuilder(
    column: $table.previousQrTokensJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentExtendedInfoTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentExtendedInfoTable> {
  $$StudentExtendedInfoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get studentBForm => $composableBuilder(
    column: $table.studentBForm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherCnic => $composableBuilder(
    column: $table.fatherCnic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motherName => $composableBuilder(
    column: $table.motherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domicileDistrict => $composableBuilder(
    column: $table.domicileDistrict,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leavingDate => $composableBuilder(
    column: $table.leavingDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leavingReason => $composableBuilder(
    column: $table.leavingReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get slcNumber =>
      $composableBuilder(column: $table.slcNumber, builder: (column) => column);

  GeneratedColumn<int> get freeBooksIssued => $composableBuilder(
    column: $table.freeBooksIssued,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isVaccinated => $composableBuilder(
    column: $table.isVaccinated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vaccineFirstDoseDate => $composableBuilder(
    column: $table.vaccineFirstDoseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vaccineSecondDoseDate => $composableBuilder(
    column: $table.vaccineSecondDoseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousQrTokensJson => $composableBuilder(
    column: $table.previousQrTokensJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$StudentExtendedInfoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentExtendedInfoTable,
          StudentExtendedInfoEntry,
          $$StudentExtendedInfoTableFilterComposer,
          $$StudentExtendedInfoTableOrderingComposer,
          $$StudentExtendedInfoTableAnnotationComposer,
          $$StudentExtendedInfoTableCreateCompanionBuilder,
          $$StudentExtendedInfoTableUpdateCompanionBuilder,
          (
            StudentExtendedInfoEntry,
            BaseReferences<
              _$AppDatabase,
              $StudentExtendedInfoTable,
              StudentExtendedInfoEntry
            >,
          ),
          StudentExtendedInfoEntry,
          PrefetchHooks Function()
        > {
  $$StudentExtendedInfoTableTableManager(
    _$AppDatabase db,
    $StudentExtendedInfoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentExtendedInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentExtendedInfoTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StudentExtendedInfoTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> studentId = const Value.absent(),
                Value<String?> studentBForm = const Value.absent(),
                Value<String?> fatherCnic = const Value.absent(),
                Value<String?> motherName = const Value.absent(),
                Value<String?> domicileDistrict = const Value.absent(),
                Value<String?> leavingDate = const Value.absent(),
                Value<String?> leavingReason = const Value.absent(),
                Value<String?> slcNumber = const Value.absent(),
                Value<int> freeBooksIssued = const Value.absent(),
                Value<int> isVaccinated = const Value.absent(),
                Value<String?> vaccineFirstDoseDate = const Value.absent(),
                Value<String?> vaccineSecondDoseDate = const Value.absent(),
                Value<String> previousQrTokensJson = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentExtendedInfoCompanion(
                studentId: studentId,
                studentBForm: studentBForm,
                fatherCnic: fatherCnic,
                motherName: motherName,
                domicileDistrict: domicileDistrict,
                leavingDate: leavingDate,
                leavingReason: leavingReason,
                slcNumber: slcNumber,
                freeBooksIssued: freeBooksIssued,
                isVaccinated: isVaccinated,
                vaccineFirstDoseDate: vaccineFirstDoseDate,
                vaccineSecondDoseDate: vaccineSecondDoseDate,
                previousQrTokensJson: previousQrTokensJson,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String studentId,
                Value<String?> studentBForm = const Value.absent(),
                Value<String?> fatherCnic = const Value.absent(),
                Value<String?> motherName = const Value.absent(),
                Value<String?> domicileDistrict = const Value.absent(),
                Value<String?> leavingDate = const Value.absent(),
                Value<String?> leavingReason = const Value.absent(),
                Value<String?> slcNumber = const Value.absent(),
                Value<int> freeBooksIssued = const Value.absent(),
                Value<int> isVaccinated = const Value.absent(),
                Value<String?> vaccineFirstDoseDate = const Value.absent(),
                Value<String?> vaccineSecondDoseDate = const Value.absent(),
                Value<String> previousQrTokensJson = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentExtendedInfoCompanion.insert(
                studentId: studentId,
                studentBForm: studentBForm,
                fatherCnic: fatherCnic,
                motherName: motherName,
                domicileDistrict: domicileDistrict,
                leavingDate: leavingDate,
                leavingReason: leavingReason,
                slcNumber: slcNumber,
                freeBooksIssued: freeBooksIssued,
                isVaccinated: isVaccinated,
                vaccineFirstDoseDate: vaccineFirstDoseDate,
                vaccineSecondDoseDate: vaccineSecondDoseDate,
                previousQrTokensJson: previousQrTokensJson,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $StudentExtendedInfoTable,
                    StudentExtendedInfoEntry
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StudentExtendedInfoTable,
                    StudentExtendedInfoEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentExtendedInfoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentExtendedInfoTable,
      StudentExtendedInfoEntry,
      $$StudentExtendedInfoTableFilterComposer,
      $$StudentExtendedInfoTableOrderingComposer,
      $$StudentExtendedInfoTableAnnotationComposer,
      $$StudentExtendedInfoTableCreateCompanionBuilder,
      $$StudentExtendedInfoTableUpdateCompanionBuilder,
      (
        StudentExtendedInfoEntry,
        BaseReferences<
          _$AppDatabase,
          $StudentExtendedInfoTable,
          StudentExtendedInfoEntry
        >,
      ),
      StudentExtendedInfoEntry,
      PrefetchHooks Function()
    >;
typedef $$AttendanceSessionsTableCreateCompanionBuilder =
    AttendanceSessionsCompanion Function({
      required String id,
      required String schoolId,
      required String classId,
      required String sectionId,
      required String date,
      Value<String> status,
      Value<String?> finalizedByUserId,
      Value<int?> finalizedAt,
      Value<String?> notes,
      required int updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$AttendanceSessionsTableUpdateCompanionBuilder =
    AttendanceSessionsCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> classId,
      Value<String> sectionId,
      Value<String> date,
      Value<String> status,
      Value<String?> finalizedByUserId,
      Value<int?> finalizedAt,
      Value<String?> notes,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$AttendanceSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceSessionsTable> {
  $$AttendanceSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finalizedByUserId => $composableBuilder(
    column: $table.finalizedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendanceSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceSessionsTable> {
  $$AttendanceSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalizedByUserId => $composableBuilder(
    column: $table.finalizedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendanceSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceSessionsTable> {
  $$AttendanceSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get finalizedByUserId => $composableBuilder(
    column: $table.finalizedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$AttendanceSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceSessionsTable,
          AttendanceSessionEntry,
          $$AttendanceSessionsTableFilterComposer,
          $$AttendanceSessionsTableOrderingComposer,
          $$AttendanceSessionsTableAnnotationComposer,
          $$AttendanceSessionsTableCreateCompanionBuilder,
          $$AttendanceSessionsTableUpdateCompanionBuilder,
          (
            AttendanceSessionEntry,
            BaseReferences<
              _$AppDatabase,
              $AttendanceSessionsTable,
              AttendanceSessionEntry
            >,
          ),
          AttendanceSessionEntry,
          PrefetchHooks Function()
        > {
  $$AttendanceSessionsTableTableManager(
    _$AppDatabase db,
    $AttendanceSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> finalizedByUserId = const Value.absent(),
                Value<int?> finalizedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceSessionsCompanion(
                id: id,
                schoolId: schoolId,
                classId: classId,
                sectionId: sectionId,
                date: date,
                status: status,
                finalizedByUserId: finalizedByUserId,
                finalizedAt: finalizedAt,
                notes: notes,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String classId,
                required String sectionId,
                required String date,
                Value<String> status = const Value.absent(),
                Value<String?> finalizedByUserId = const Value.absent(),
                Value<int?> finalizedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int updatedAt,
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceSessionsCompanion.insert(
                id: id,
                schoolId: schoolId,
                classId: classId,
                sectionId: sectionId,
                date: date,
                status: status,
                finalizedByUserId: finalizedByUserId,
                finalizedAt: finalizedAt,
                notes: notes,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendanceSessionsTable, AttendanceSessionEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $AttendanceSessionsTable,
                    AttendanceSessionEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendanceSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceSessionsTable,
      AttendanceSessionEntry,
      $$AttendanceSessionsTableFilterComposer,
      $$AttendanceSessionsTableOrderingComposer,
      $$AttendanceSessionsTableAnnotationComposer,
      $$AttendanceSessionsTableCreateCompanionBuilder,
      $$AttendanceSessionsTableUpdateCompanionBuilder,
      (
        AttendanceSessionEntry,
        BaseReferences<
          _$AppDatabase,
          $AttendanceSessionsTable,
          AttendanceSessionEntry
        >,
      ),
      AttendanceSessionEntry,
      PrefetchHooks Function()
    >;
typedef $$CorrectionRequestsTableCreateCompanionBuilder =
    CorrectionRequestsCompanion Function({
      required String id,
      required String schoolId,
      required String attendanceRecordId,
      required String studentId,
      Value<String?> studentName,
      required String classId,
      required String sectionId,
      required String date,
      required String oldStatus,
      required String proposedStatus,
      required String reason,
      required String requestedByUserId,
      Value<String?> requestedByName,
      Value<String> status,
      Value<String?> reviewedByUserId,
      Value<String?> reviewRemarks,
      required int createdAt,
      required int updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$CorrectionRequestsTableUpdateCompanionBuilder =
    CorrectionRequestsCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> attendanceRecordId,
      Value<String> studentId,
      Value<String?> studentName,
      Value<String> classId,
      Value<String> sectionId,
      Value<String> date,
      Value<String> oldStatus,
      Value<String> proposedStatus,
      Value<String> reason,
      Value<String> requestedByUserId,
      Value<String?> requestedByName,
      Value<String> status,
      Value<String?> reviewedByUserId,
      Value<String?> reviewRemarks,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$CorrectionRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $CorrectionRequestsTable> {
  $$CorrectionRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attendanceRecordId => $composableBuilder(
    column: $table.attendanceRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldStatus => $composableBuilder(
    column: $table.oldStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposedStatus => $composableBuilder(
    column: $table.proposedStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedByUserId => $composableBuilder(
    column: $table.requestedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedByName => $composableBuilder(
    column: $table.requestedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewedByUserId => $composableBuilder(
    column: $table.reviewedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewRemarks => $composableBuilder(
    column: $table.reviewRemarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CorrectionRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $CorrectionRequestsTable> {
  $$CorrectionRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attendanceRecordId => $composableBuilder(
    column: $table.attendanceRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldStatus => $composableBuilder(
    column: $table.oldStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposedStatus => $composableBuilder(
    column: $table.proposedStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedByUserId => $composableBuilder(
    column: $table.requestedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedByName => $composableBuilder(
    column: $table.requestedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewedByUserId => $composableBuilder(
    column: $table.reviewedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewRemarks => $composableBuilder(
    column: $table.reviewRemarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CorrectionRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CorrectionRequestsTable> {
  $$CorrectionRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get attendanceRecordId => $composableBuilder(
    column: $table.attendanceRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get oldStatus =>
      $composableBuilder(column: $table.oldStatus, builder: (column) => column);

  GeneratedColumn<String> get proposedStatus => $composableBuilder(
    column: $table.proposedStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get requestedByUserId => $composableBuilder(
    column: $table.requestedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestedByName => $composableBuilder(
    column: $table.requestedByName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reviewedByUserId => $composableBuilder(
    column: $table.reviewedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewRemarks => $composableBuilder(
    column: $table.reviewRemarks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$CorrectionRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CorrectionRequestsTable,
          CorrectionRequestEntry,
          $$CorrectionRequestsTableFilterComposer,
          $$CorrectionRequestsTableOrderingComposer,
          $$CorrectionRequestsTableAnnotationComposer,
          $$CorrectionRequestsTableCreateCompanionBuilder,
          $$CorrectionRequestsTableUpdateCompanionBuilder,
          (
            CorrectionRequestEntry,
            BaseReferences<
              _$AppDatabase,
              $CorrectionRequestsTable,
              CorrectionRequestEntry
            >,
          ),
          CorrectionRequestEntry,
          PrefetchHooks Function()
        > {
  $$CorrectionRequestsTableTableManager(
    _$AppDatabase db,
    $CorrectionRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CorrectionRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CorrectionRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CorrectionRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> attendanceRecordId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String?> studentName = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> oldStatus = const Value.absent(),
                Value<String> proposedStatus = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> requestedByUserId = const Value.absent(),
                Value<String?> requestedByName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reviewedByUserId = const Value.absent(),
                Value<String?> reviewRemarks = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CorrectionRequestsCompanion(
                id: id,
                schoolId: schoolId,
                attendanceRecordId: attendanceRecordId,
                studentId: studentId,
                studentName: studentName,
                classId: classId,
                sectionId: sectionId,
                date: date,
                oldStatus: oldStatus,
                proposedStatus: proposedStatus,
                reason: reason,
                requestedByUserId: requestedByUserId,
                requestedByName: requestedByName,
                status: status,
                reviewedByUserId: reviewedByUserId,
                reviewRemarks: reviewRemarks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String attendanceRecordId,
                required String studentId,
                Value<String?> studentName = const Value.absent(),
                required String classId,
                required String sectionId,
                required String date,
                required String oldStatus,
                required String proposedStatus,
                required String reason,
                required String requestedByUserId,
                Value<String?> requestedByName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reviewedByUserId = const Value.absent(),
                Value<String?> reviewRemarks = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CorrectionRequestsCompanion.insert(
                id: id,
                schoolId: schoolId,
                attendanceRecordId: attendanceRecordId,
                studentId: studentId,
                studentName: studentName,
                classId: classId,
                sectionId: sectionId,
                date: date,
                oldStatus: oldStatus,
                proposedStatus: proposedStatus,
                reason: reason,
                requestedByUserId: requestedByUserId,
                requestedByName: requestedByName,
                status: status,
                reviewedByUserId: reviewedByUserId,
                reviewRemarks: reviewRemarks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CorrectionRequestsTable, CorrectionRequestEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CorrectionRequestsTable,
                    CorrectionRequestEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CorrectionRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CorrectionRequestsTable,
      CorrectionRequestEntry,
      $$CorrectionRequestsTableFilterComposer,
      $$CorrectionRequestsTableOrderingComposer,
      $$CorrectionRequestsTableAnnotationComposer,
      $$CorrectionRequestsTableCreateCompanionBuilder,
      $$CorrectionRequestsTableUpdateCompanionBuilder,
      (
        CorrectionRequestEntry,
        BaseReferences<
          _$AppDatabase,
          $CorrectionRequestsTable,
          CorrectionRequestEntry
        >,
      ),
      CorrectionRequestEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String id,
      Value<String?> schoolId,
      required String recordId,
      required String targetTableName,
      required String studentId,
      required String date,
      required String localStatus,
      required String serverStatus,
      required String conflictReason,
      Value<String> status,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> id,
      Value<String?> schoolId,
      Value<String> recordId,
      Value<String> targetTableName,
      Value<String> studentId,
      Value<String> date,
      Value<String> localStatus,
      Value<String> serverStatus,
      Value<String> conflictReason,
      Value<String> status,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTableName => $composableBuilder(
    column: $table.targetTableName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localStatus => $composableBuilder(
    column: $table.localStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverStatus => $composableBuilder(
    column: $table.serverStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictReason => $composableBuilder(
    column: $table.conflictReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTableName => $composableBuilder(
    column: $table.targetTableName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localStatus => $composableBuilder(
    column: $table.localStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverStatus => $composableBuilder(
    column: $table.serverStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictReason => $composableBuilder(
    column: $table.conflictReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get targetTableName => $composableBuilder(
    column: $table.targetTableName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get localStatus => $composableBuilder(
    column: $table.localStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverStatus => $composableBuilder(
    column: $table.serverStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictReason => $composableBuilder(
    column: $table.conflictReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTable,
          SyncConflictEntry,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflictEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncConflictsTable,
              SyncConflictEntry
            >,
          ),
          SyncConflictEntry,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> schoolId = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> targetTableName = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> localStatus = const Value.absent(),
                Value<String> serverStatus = const Value.absent(),
                Value<String> conflictReason = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                schoolId: schoolId,
                recordId: recordId,
                targetTableName: targetTableName,
                studentId: studentId,
                date: date,
                localStatus: localStatus,
                serverStatus: serverStatus,
                conflictReason: conflictReason,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> schoolId = const Value.absent(),
                required String recordId,
                required String targetTableName,
                required String studentId,
                required String date,
                required String localStatus,
                required String serverStatus,
                required String conflictReason,
                Value<String> status = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                schoolId: schoolId,
                recordId: recordId,
                targetTableName: targetTableName,
                studentId: studentId,
                date: date,
                localStatus: localStatus,
                serverStatus: serverStatus,
                conflictReason: conflictReason,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncConflictsTable, SyncConflictEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncConflictsTable,
                    SyncConflictEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTable,
      SyncConflictEntry,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflictEntry,
        BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflictEntry>,
      ),
      SyncConflictEntry,
      PrefetchHooks Function()
    >;
typedef $$TeacherGoshwaraProfilesTableCreateCompanionBuilder =
    TeacherGoshwaraProfilesCompanion Function({
      required String userId,
      Value<String> fatherName,
      Value<String> personalNo,
      Value<String> dob,
      Value<String> academicQualification,
      Value<String> professionalQualification,
      Value<String> appointmentDate,
      Value<String> transferInDate,
      Value<String> currentBps,
      Value<String> bpsAwardDate,
      Value<double> basicPay,
      Value<String> village,
      Value<String> unionCouncil,
      Value<String> district,
      Value<String> employmentType,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$TeacherGoshwaraProfilesTableUpdateCompanionBuilder =
    TeacherGoshwaraProfilesCompanion Function({
      Value<String> userId,
      Value<String> fatherName,
      Value<String> personalNo,
      Value<String> dob,
      Value<String> academicQualification,
      Value<String> professionalQualification,
      Value<String> appointmentDate,
      Value<String> transferInDate,
      Value<String> currentBps,
      Value<String> bpsAwardDate,
      Value<double> basicPay,
      Value<String> village,
      Value<String> unionCouncil,
      Value<String> district,
      Value<String> employmentType,
      Value<int> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

class $$TeacherGoshwaraProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $TeacherGoshwaraProfilesTable> {
  $$TeacherGoshwaraProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personalNo => $composableBuilder(
    column: $table.personalNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dob => $composableBuilder(
    column: $table.dob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get academicQualification => $composableBuilder(
    column: $table.academicQualification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get professionalQualification => $composableBuilder(
    column: $table.professionalQualification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appointmentDate => $composableBuilder(
    column: $table.appointmentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferInDate => $composableBuilder(
    column: $table.transferInDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentBps => $composableBuilder(
    column: $table.currentBps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bpsAwardDate => $composableBuilder(
    column: $table.bpsAwardDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get basicPay => $composableBuilder(
    column: $table.basicPay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unionCouncil => $composableBuilder(
    column: $table.unionCouncil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employmentType => $composableBuilder(
    column: $table.employmentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeacherGoshwaraProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $TeacherGoshwaraProfilesTable> {
  $$TeacherGoshwaraProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personalNo => $composableBuilder(
    column: $table.personalNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dob => $composableBuilder(
    column: $table.dob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get academicQualification => $composableBuilder(
    column: $table.academicQualification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get professionalQualification => $composableBuilder(
    column: $table.professionalQualification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appointmentDate => $composableBuilder(
    column: $table.appointmentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferInDate => $composableBuilder(
    column: $table.transferInDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentBps => $composableBuilder(
    column: $table.currentBps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bpsAwardDate => $composableBuilder(
    column: $table.bpsAwardDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get basicPay => $composableBuilder(
    column: $table.basicPay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unionCouncil => $composableBuilder(
    column: $table.unionCouncil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employmentType => $composableBuilder(
    column: $table.employmentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeacherGoshwaraProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeacherGoshwaraProfilesTable> {
  $$TeacherGoshwaraProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personalNo => $composableBuilder(
    column: $table.personalNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dob =>
      $composableBuilder(column: $table.dob, builder: (column) => column);

  GeneratedColumn<String> get academicQualification => $composableBuilder(
    column: $table.academicQualification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get professionalQualification => $composableBuilder(
    column: $table.professionalQualification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appointmentDate => $composableBuilder(
    column: $table.appointmentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transferInDate => $composableBuilder(
    column: $table.transferInDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentBps => $composableBuilder(
    column: $table.currentBps,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bpsAwardDate => $composableBuilder(
    column: $table.bpsAwardDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get basicPay =>
      $composableBuilder(column: $table.basicPay, builder: (column) => column);

  GeneratedColumn<String> get village =>
      $composableBuilder(column: $table.village, builder: (column) => column);

  GeneratedColumn<String> get unionCouncil => $composableBuilder(
    column: $table.unionCouncil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get employmentType => $composableBuilder(
    column: $table.employmentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$TeacherGoshwaraProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeacherGoshwaraProfilesTable,
          TeacherGoshwaraProfileEntry,
          $$TeacherGoshwaraProfilesTableFilterComposer,
          $$TeacherGoshwaraProfilesTableOrderingComposer,
          $$TeacherGoshwaraProfilesTableAnnotationComposer,
          $$TeacherGoshwaraProfilesTableCreateCompanionBuilder,
          $$TeacherGoshwaraProfilesTableUpdateCompanionBuilder,
          (
            TeacherGoshwaraProfileEntry,
            BaseReferences<
              _$AppDatabase,
              $TeacherGoshwaraProfilesTable,
              TeacherGoshwaraProfileEntry
            >,
          ),
          TeacherGoshwaraProfileEntry,
          PrefetchHooks Function()
        > {
  $$TeacherGoshwaraProfilesTableTableManager(
    _$AppDatabase db,
    $TeacherGoshwaraProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeacherGoshwaraProfilesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TeacherGoshwaraProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TeacherGoshwaraProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> fatherName = const Value.absent(),
                Value<String> personalNo = const Value.absent(),
                Value<String> dob = const Value.absent(),
                Value<String> academicQualification = const Value.absent(),
                Value<String> professionalQualification = const Value.absent(),
                Value<String> appointmentDate = const Value.absent(),
                Value<String> transferInDate = const Value.absent(),
                Value<String> currentBps = const Value.absent(),
                Value<String> bpsAwardDate = const Value.absent(),
                Value<double> basicPay = const Value.absent(),
                Value<String> village = const Value.absent(),
                Value<String> unionCouncil = const Value.absent(),
                Value<String> district = const Value.absent(),
                Value<String> employmentType = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherGoshwaraProfilesCompanion(
                userId: userId,
                fatherName: fatherName,
                personalNo: personalNo,
                dob: dob,
                academicQualification: academicQualification,
                professionalQualification: professionalQualification,
                appointmentDate: appointmentDate,
                transferInDate: transferInDate,
                currentBps: currentBps,
                bpsAwardDate: bpsAwardDate,
                basicPay: basicPay,
                village: village,
                unionCouncil: unionCouncil,
                district: district,
                employmentType: employmentType,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String> fatherName = const Value.absent(),
                Value<String> personalNo = const Value.absent(),
                Value<String> dob = const Value.absent(),
                Value<String> academicQualification = const Value.absent(),
                Value<String> professionalQualification = const Value.absent(),
                Value<String> appointmentDate = const Value.absent(),
                Value<String> transferInDate = const Value.absent(),
                Value<String> currentBps = const Value.absent(),
                Value<String> bpsAwardDate = const Value.absent(),
                Value<double> basicPay = const Value.absent(),
                Value<String> village = const Value.absent(),
                Value<String> unionCouncil = const Value.absent(),
                Value<String> district = const Value.absent(),
                Value<String> employmentType = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherGoshwaraProfilesCompanion.insert(
                userId: userId,
                fatherName: fatherName,
                personalNo: personalNo,
                dob: dob,
                academicQualification: academicQualification,
                professionalQualification: professionalQualification,
                appointmentDate: appointmentDate,
                transferInDate: transferInDate,
                currentBps: currentBps,
                bpsAwardDate: bpsAwardDate,
                basicPay: basicPay,
                village: village,
                unionCouncil: unionCouncil,
                district: district,
                employmentType: employmentType,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $TeacherGoshwaraProfilesTable,
                    TeacherGoshwaraProfileEntry
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TeacherGoshwaraProfilesTable,
                    TeacherGoshwaraProfileEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeacherGoshwaraProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeacherGoshwaraProfilesTable,
      TeacherGoshwaraProfileEntry,
      $$TeacherGoshwaraProfilesTableFilterComposer,
      $$TeacherGoshwaraProfilesTableOrderingComposer,
      $$TeacherGoshwaraProfilesTableAnnotationComposer,
      $$TeacherGoshwaraProfilesTableCreateCompanionBuilder,
      $$TeacherGoshwaraProfilesTableUpdateCompanionBuilder,
      (
        TeacherGoshwaraProfileEntry,
        BaseReferences<
          _$AppDatabase,
          $TeacherGoshwaraProfilesTable,
          TeacherGoshwaraProfileEntry
        >,
      ),
      TeacherGoshwaraProfileEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchoolsTableTableManager get schools =>
      $$SchoolsTableTableManager(_db, _db.schools);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db, _db.classes);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db, _db.sections);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$ParentContactsTableTableManager get parentContacts =>
      $$ParentContactsTableTableManager(_db, _db.parentContacts);
  $$SchoolCalendarHolidaysTableTableManager get schoolCalendarHolidays =>
      $$SchoolCalendarHolidaysTableTableManager(
        _db,
        _db.schoolCalendarHolidays,
      );
  $$AttendanceRecordsTableTableManager get attendanceRecords =>
      $$AttendanceRecordsTableTableManager(_db, _db.attendanceRecords);
  $$AttendanceAuditLogsTableTableManager get attendanceAuditLogs =>
      $$AttendanceAuditLogsTableTableManager(_db, _db.attendanceAuditLogs);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$SchoolSettingsTableTableManager get schoolSettings =>
      $$SchoolSettingsTableTableManager(_db, _db.schoolSettings);
  $$StudentExtendedInfoTableTableManager get studentExtendedInfo =>
      $$StudentExtendedInfoTableTableManager(_db, _db.studentExtendedInfo);
  $$AttendanceSessionsTableTableManager get attendanceSessions =>
      $$AttendanceSessionsTableTableManager(_db, _db.attendanceSessions);
  $$CorrectionRequestsTableTableManager get correctionRequests =>
      $$CorrectionRequestsTableTableManager(_db, _db.correctionRequests);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$TeacherGoshwaraProfilesTableTableManager get teacherGoshwaraProfiles =>
      $$TeacherGoshwaraProfilesTableTableManager(
        _db,
        _db.teacherGoshwaraProfiles,
      );
}
