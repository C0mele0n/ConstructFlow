// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, LocalUser>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$UsersTable(this.attachedDatabase, [this._alias]);
@override
List<GeneratedColumn> get $columns => [];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'users';
@override
VerificationContext validateIntegrity(Insertable<LocalUser> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => const {};@override LocalUser map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return LocalUser();
}
@override
$UsersTable createAlias(String alias) {
return $UsersTable(attachedDatabase, alias);}}class LocalUser extends DataClass implements Insertable<LocalUser> {
const LocalUser({});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};return map; 
}
UsersCompanion toCompanion(bool nullToAbsent) {
return UsersCompanion();
}
factory LocalUser.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return LocalUser();}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
};}LocalUser copyWith({}) => LocalUser();LocalUser copyWithCompanion(UsersCompanion data) {
return LocalUser(
);
}
@override
String toString() {return (StringBuffer('LocalUser(')..write(')')).toString();}
@override
 int get hashCode => identityHashCode(this);@override
bool operator ==(Object other) => identical(this, other) || (other is LocalUser);
}class UsersCompanion extends UpdateCompanion<LocalUser> {
final Value<int> rowid;
const UsersCompanion({this.rowid = const Value.absent(),});
UsersCompanion.insert({this.rowid = const Value.absent(),});
static Insertable<LocalUser> custom({Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (rowid != null)'rowid': rowid,});
}UsersCompanion copyWith({Value<int>? rowid}) {
return UsersCompanion(rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('UsersCompanion(')..write('rowid: $rowid')..write(')')).toString();}
}
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, LocalProject>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$ProjectsTable(this.attachedDatabase, [this._alias]);
@override
List<GeneratedColumn> get $columns => [];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'projects';
@override
VerificationContext validateIntegrity(Insertable<LocalProject> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => const {};@override LocalProject map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return LocalProject();
}
@override
$ProjectsTable createAlias(String alias) {
return $ProjectsTable(attachedDatabase, alias);}}class LocalProject extends DataClass implements Insertable<LocalProject> {
const LocalProject({});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};return map; 
}
ProjectsCompanion toCompanion(bool nullToAbsent) {
return ProjectsCompanion();
}
factory LocalProject.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return LocalProject();}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
};}LocalProject copyWith({}) => LocalProject();LocalProject copyWithCompanion(ProjectsCompanion data) {
return LocalProject(
);
}
@override
String toString() {return (StringBuffer('LocalProject(')..write(')')).toString();}
@override
 int get hashCode => identityHashCode(this);@override
bool operator ==(Object other) => identical(this, other) || (other is LocalProject);
}class ProjectsCompanion extends UpdateCompanion<LocalProject> {
final Value<int> rowid;
const ProjectsCompanion({this.rowid = const Value.absent(),});
ProjectsCompanion.insert({this.rowid = const Value.absent(),});
static Insertable<LocalProject> custom({Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (rowid != null)'rowid': rowid,});
}ProjectsCompanion copyWith({Value<int>? rowid}) {
return ProjectsCompanion(rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('ProjectsCompanion(')..write('rowid: $rowid')..write(')')).toString();}
}
class $ProjectMembershipsTable extends ProjectMemberships with TableInfo<$ProjectMembershipsTable, LocalProjectMembership>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$ProjectMembershipsTable(this.attachedDatabase, [this._alias]);
@override
List<GeneratedColumn> get $columns => [];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'project_memberships';
@override
VerificationContext validateIntegrity(Insertable<LocalProjectMembership> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => const {};@override LocalProjectMembership map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return LocalProjectMembership();
}
@override
$ProjectMembershipsTable createAlias(String alias) {
return $ProjectMembershipsTable(attachedDatabase, alias);}}class LocalProjectMembership extends DataClass implements Insertable<LocalProjectMembership> {
const LocalProjectMembership({});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};return map; 
}
ProjectMembershipsCompanion toCompanion(bool nullToAbsent) {
return ProjectMembershipsCompanion();
}
factory LocalProjectMembership.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return LocalProjectMembership();}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
};}LocalProjectMembership copyWith({}) => LocalProjectMembership();LocalProjectMembership copyWithCompanion(ProjectMembershipsCompanion data) {
return LocalProjectMembership(
);
}
@override
String toString() {return (StringBuffer('LocalProjectMembership(')..write(')')).toString();}
@override
 int get hashCode => identityHashCode(this);@override
bool operator ==(Object other) => identical(this, other) || (other is LocalProjectMembership);
}class ProjectMembershipsCompanion extends UpdateCompanion<LocalProjectMembership> {
final Value<int> rowid;
const ProjectMembershipsCompanion({this.rowid = const Value.absent(),});
ProjectMembershipsCompanion.insert({this.rowid = const Value.absent(),});
static Insertable<LocalProjectMembership> custom({Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (rowid != null)'rowid': rowid,});
}ProjectMembershipsCompanion copyWith({Value<int>? rowid}) {
return ProjectMembershipsCompanion(rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('ProjectMembershipsCompanion(')..write('rowid: $rowid')..write(')')).toString();}
}
class $MeasurementsTable extends Measurements with TableInfo<$MeasurementsTable, LocalMeasurement>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$MeasurementsTable(this.attachedDatabase, [this._alias]);
@override
List<GeneratedColumn> get $columns => [];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'measurements';
@override
VerificationContext validateIntegrity(Insertable<LocalMeasurement> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => const {};@override LocalMeasurement map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return LocalMeasurement();
}
@override
$MeasurementsTable createAlias(String alias) {
return $MeasurementsTable(attachedDatabase, alias);}}class LocalMeasurement extends DataClass implements Insertable<LocalMeasurement> {
const LocalMeasurement({});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};return map; 
}
MeasurementsCompanion toCompanion(bool nullToAbsent) {
return MeasurementsCompanion();
}
factory LocalMeasurement.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return LocalMeasurement();}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
};}LocalMeasurement copyWith({}) => LocalMeasurement();LocalMeasurement copyWithCompanion(MeasurementsCompanion data) {
return LocalMeasurement(
);
}
@override
String toString() {return (StringBuffer('LocalMeasurement(')..write(')')).toString();}
@override
 int get hashCode => identityHashCode(this);@override
bool operator ==(Object other) => identical(this, other) || (other is LocalMeasurement);
}class MeasurementsCompanion extends UpdateCompanion<LocalMeasurement> {
final Value<int> rowid;
const MeasurementsCompanion({this.rowid = const Value.absent(),});
MeasurementsCompanion.insert({this.rowid = const Value.absent(),});
static Insertable<LocalMeasurement> custom({Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (rowid != null)'rowid': rowid,});
}MeasurementsCompanion copyWith({Value<int>? rowid}) {
return MeasurementsCompanion(rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('MeasurementsCompanion(')..write('rowid: $rowid')..write(')')).toString();}
}
class $CutsTable extends Cuts with TableInfo<$CutsTable, LocalCut>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$CutsTable(this.attachedDatabase, [this._alias]);
@override
List<GeneratedColumn> get $columns => [];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'cuts';
@override
VerificationContext validateIntegrity(Insertable<LocalCut> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => const {};@override LocalCut map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return LocalCut();
}
@override
$CutsTable createAlias(String alias) {
return $CutsTable(attachedDatabase, alias);}}class LocalCut extends DataClass implements Insertable<LocalCut> {
const LocalCut({});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};return map; 
}
CutsCompanion toCompanion(bool nullToAbsent) {
return CutsCompanion();
}
factory LocalCut.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return LocalCut();}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
};}LocalCut copyWith({}) => LocalCut();LocalCut copyWithCompanion(CutsCompanion data) {
return LocalCut(
);
}
@override
String toString() {return (StringBuffer('LocalCut(')..write(')')).toString();}
@override
 int get hashCode => identityHashCode(this);@override
bool operator ==(Object other) => identical(this, other) || (other is LocalCut);
}class CutsCompanion extends UpdateCompanion<LocalCut> {
final Value<int> rowid;
const CutsCompanion({this.rowid = const Value.absent(),});
CutsCompanion.insert({this.rowid = const Value.absent(),});
static Insertable<LocalCut> custom({Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (rowid != null)'rowid': rowid,});
}CutsCompanion copyWith({Value<int>? rowid}) {
return CutsCompanion(rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('CutsCompanion(')..write('rowid: $rowid')..write(')')).toString();}
}
class $MaterialsTable extends Materials with TableInfo<$MaterialsTable, LocalMaterial>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$MaterialsTable(this.attachedDatabase, [this._alias]);
@override
List<GeneratedColumn> get $columns => [];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'materials';
@override
VerificationContext validateIntegrity(Insertable<LocalMaterial> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => const {};@override LocalMaterial map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return LocalMaterial();
}
@override
$MaterialsTable createAlias(String alias) {
return $MaterialsTable(attachedDatabase, alias);}}class LocalMaterial extends DataClass implements Insertable<LocalMaterial> {
const LocalMaterial({});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};return map; 
}
MaterialsCompanion toCompanion(bool nullToAbsent) {
return MaterialsCompanion();
}
factory LocalMaterial.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return LocalMaterial();}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
};}LocalMaterial copyWith({}) => LocalMaterial();LocalMaterial copyWithCompanion(MaterialsCompanion data) {
return LocalMaterial(
);
}
@override
String toString() {return (StringBuffer('LocalMaterial(')..write(')')).toString();}
@override
 int get hashCode => identityHashCode(this);@override
bool operator ==(Object other) => identical(this, other) || (other is LocalMaterial);
}class MaterialsCompanion extends UpdateCompanion<LocalMaterial> {
final Value<int> rowid;
const MaterialsCompanion({this.rowid = const Value.absent(),});
MaterialsCompanion.insert({this.rowid = const Value.absent(),});
static Insertable<LocalMaterial> custom({Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (rowid != null)'rowid': rowid,});
}MaterialsCompanion copyWith({Value<int>? rowid}) {
return MaterialsCompanion(rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('MaterialsCompanion(')..write('rowid: $rowid')..write(')')).toString();}
}
class $CostsTable extends Costs with TableInfo<$CostsTable, LocalCost>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$CostsTable(this.attachedDatabase, [this._alias]);
@override
List<GeneratedColumn> get $columns => [];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'costs';
@override
VerificationContext validateIntegrity(Insertable<LocalCost> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => const {};@override LocalCost map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return LocalCost();
}
@override
$CostsTable createAlias(String alias) {
return $CostsTable(attachedDatabase, alias);}}class LocalCost extends DataClass implements Insertable<LocalCost> {
const LocalCost({});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};return map; 
}
CostsCompanion toCompanion(bool nullToAbsent) {
return CostsCompanion();
}
factory LocalCost.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return LocalCost();}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
};}LocalCost copyWith({}) => LocalCost();LocalCost copyWithCompanion(CostsCompanion data) {
return LocalCost(
);
}
@override
String toString() {return (StringBuffer('LocalCost(')..write(')')).toString();}
@override
 int get hashCode => identityHashCode(this);@override
bool operator ==(Object other) => identical(this, other) || (other is LocalCost);
}class CostsCompanion extends UpdateCompanion<LocalCost> {
final Value<int> rowid;
const CostsCompanion({this.rowid = const Value.absent(),});
CostsCompanion.insert({this.rowid = const Value.absent(),});
static Insertable<LocalCost> custom({Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (rowid != null)'rowid': rowid,});
}CostsCompanion copyWith({Value<int>? rowid}) {
return CostsCompanion(rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('CostsCompanion(')..write('rowid: $rowid')..write(')')).toString();}
}
class $InstallationsTable extends Installations with TableInfo<$InstallationsTable, LocalInstallation>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$InstallationsTable(this.attachedDatabase, [this._alias]);
@override
List<GeneratedColumn> get $columns => [];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'installations';
@override
VerificationContext validateIntegrity(Insertable<LocalInstallation> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => const {};@override LocalInstallation map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return LocalInstallation();
}
@override
$InstallationsTable createAlias(String alias) {
return $InstallationsTable(attachedDatabase, alias);}}class LocalInstallation extends DataClass implements Insertable<LocalInstallation> {
const LocalInstallation({});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};return map; 
}
InstallationsCompanion toCompanion(bool nullToAbsent) {
return InstallationsCompanion();
}
factory LocalInstallation.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return LocalInstallation();}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
};}LocalInstallation copyWith({}) => LocalInstallation();LocalInstallation copyWithCompanion(InstallationsCompanion data) {
return LocalInstallation(
);
}
@override
String toString() {return (StringBuffer('LocalInstallation(')..write(')')).toString();}
@override
 int get hashCode => identityHashCode(this);@override
bool operator ==(Object other) => identical(this, other) || (other is LocalInstallation);
}class InstallationsCompanion extends UpdateCompanion<LocalInstallation> {
final Value<int> rowid;
const InstallationsCompanion({this.rowid = const Value.absent(),});
InstallationsCompanion.insert({this.rowid = const Value.absent(),});
static Insertable<LocalInstallation> custom({Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (rowid != null)'rowid': rowid,});
}InstallationsCompanion copyWith({Value<int>? rowid}) {
return InstallationsCompanion(rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('InstallationsCompanion(')..write('rowid: $rowid')..write(')')).toString();}
}
abstract class _$AppDatabase extends GeneratedDatabase{
_$AppDatabase(QueryExecutor e): super(e);
$AppDatabaseManager get managers => $AppDatabaseManager(this);
late final $UsersTable users = $UsersTable(this);
late final $ProjectsTable projects = $ProjectsTable(this);
late final $ProjectMembershipsTable projectMemberships = $ProjectMembershipsTable(this);
late final $MeasurementsTable measurements = $MeasurementsTable(this);
late final $CutsTable cuts = $CutsTable(this);
late final $MaterialsTable materials = $MaterialsTable(this);
late final $CostsTable costs = $CostsTable(this);
late final $InstallationsTable installations = $InstallationsTable(this);
@override
Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
@override
List<DatabaseSchemaEntity> get allSchemaEntities => [users, projects, projectMemberships, measurements, cuts, materials, costs, installations];
}
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({Value<int> rowid,});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({Value<int> rowid,});
class $$UsersTableTableManager extends RootTableManager    <_$AppDatabase,
    $UsersTable,
    LocalUser,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder> {
    $$UsersTableTableManager(_$AppDatabase db, $UsersTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        filteringComposer: $$UsersTableFilterComposer(ComposerState(db, table)),
        orderingComposer: $$UsersTableOrderingComposer(ComposerState(db, table)),
        updateCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> UsersCompanion(rowid: rowid,),
        createCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> UsersCompanion.insert(rowid: rowid,),));
        }
    class $$UsersTableFilterComposer extends FilterComposer<
        _$AppDatabase,
        $UsersTable> {
        $$UsersTableFilterComposer(super.$state);
          
        }
      class $$UsersTableOrderingComposer extends OrderingComposer<
        _$AppDatabase,
        $UsersTable> {
        $$UsersTableOrderingComposer(super.$state);
          
        }
      typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({Value<int> rowid,});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({Value<int> rowid,});
class $$ProjectsTableTableManager extends RootTableManager    <_$AppDatabase,
    $ProjectsTable,
    LocalProject,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder> {
    $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        filteringComposer: $$ProjectsTableFilterComposer(ComposerState(db, table)),
        orderingComposer: $$ProjectsTableOrderingComposer(ComposerState(db, table)),
        updateCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> ProjectsCompanion(rowid: rowid,),
        createCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> ProjectsCompanion.insert(rowid: rowid,),));
        }
    class $$ProjectsTableFilterComposer extends FilterComposer<
        _$AppDatabase,
        $ProjectsTable> {
        $$ProjectsTableFilterComposer(super.$state);
          
        }
      class $$ProjectsTableOrderingComposer extends OrderingComposer<
        _$AppDatabase,
        $ProjectsTable> {
        $$ProjectsTableOrderingComposer(super.$state);
          
        }
      typedef $$ProjectMembershipsTableCreateCompanionBuilder = ProjectMembershipsCompanion Function({Value<int> rowid,});
typedef $$ProjectMembershipsTableUpdateCompanionBuilder = ProjectMembershipsCompanion Function({Value<int> rowid,});
class $$ProjectMembershipsTableTableManager extends RootTableManager    <_$AppDatabase,
    $ProjectMembershipsTable,
    LocalProjectMembership,
    $$ProjectMembershipsTableFilterComposer,
    $$ProjectMembershipsTableOrderingComposer,
    $$ProjectMembershipsTableCreateCompanionBuilder,
    $$ProjectMembershipsTableUpdateCompanionBuilder> {
    $$ProjectMembershipsTableTableManager(_$AppDatabase db, $ProjectMembershipsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        filteringComposer: $$ProjectMembershipsTableFilterComposer(ComposerState(db, table)),
        orderingComposer: $$ProjectMembershipsTableOrderingComposer(ComposerState(db, table)),
        updateCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> ProjectMembershipsCompanion(rowid: rowid,),
        createCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> ProjectMembershipsCompanion.insert(rowid: rowid,),));
        }
    class $$ProjectMembershipsTableFilterComposer extends FilterComposer<
        _$AppDatabase,
        $ProjectMembershipsTable> {
        $$ProjectMembershipsTableFilterComposer(super.$state);
          
        }
      class $$ProjectMembershipsTableOrderingComposer extends OrderingComposer<
        _$AppDatabase,
        $ProjectMembershipsTable> {
        $$ProjectMembershipsTableOrderingComposer(super.$state);
          
        }
      typedef $$MeasurementsTableCreateCompanionBuilder = MeasurementsCompanion Function({Value<int> rowid,});
typedef $$MeasurementsTableUpdateCompanionBuilder = MeasurementsCompanion Function({Value<int> rowid,});
class $$MeasurementsTableTableManager extends RootTableManager    <_$AppDatabase,
    $MeasurementsTable,
    LocalMeasurement,
    $$MeasurementsTableFilterComposer,
    $$MeasurementsTableOrderingComposer,
    $$MeasurementsTableCreateCompanionBuilder,
    $$MeasurementsTableUpdateCompanionBuilder> {
    $$MeasurementsTableTableManager(_$AppDatabase db, $MeasurementsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        filteringComposer: $$MeasurementsTableFilterComposer(ComposerState(db, table)),
        orderingComposer: $$MeasurementsTableOrderingComposer(ComposerState(db, table)),
        updateCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> MeasurementsCompanion(rowid: rowid,),
        createCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> MeasurementsCompanion.insert(rowid: rowid,),));
        }
    class $$MeasurementsTableFilterComposer extends FilterComposer<
        _$AppDatabase,
        $MeasurementsTable> {
        $$MeasurementsTableFilterComposer(super.$state);
          
        }
      class $$MeasurementsTableOrderingComposer extends OrderingComposer<
        _$AppDatabase,
        $MeasurementsTable> {
        $$MeasurementsTableOrderingComposer(super.$state);
          
        }
      typedef $$CutsTableCreateCompanionBuilder = CutsCompanion Function({Value<int> rowid,});
typedef $$CutsTableUpdateCompanionBuilder = CutsCompanion Function({Value<int> rowid,});
class $$CutsTableTableManager extends RootTableManager    <_$AppDatabase,
    $CutsTable,
    LocalCut,
    $$CutsTableFilterComposer,
    $$CutsTableOrderingComposer,
    $$CutsTableCreateCompanionBuilder,
    $$CutsTableUpdateCompanionBuilder> {
    $$CutsTableTableManager(_$AppDatabase db, $CutsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        filteringComposer: $$CutsTableFilterComposer(ComposerState(db, table)),
        orderingComposer: $$CutsTableOrderingComposer(ComposerState(db, table)),
        updateCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> CutsCompanion(rowid: rowid,),
        createCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> CutsCompanion.insert(rowid: rowid,),));
        }
    class $$CutsTableFilterComposer extends FilterComposer<
        _$AppDatabase,
        $CutsTable> {
        $$CutsTableFilterComposer(super.$state);
          
        }
      class $$CutsTableOrderingComposer extends OrderingComposer<
        _$AppDatabase,
        $CutsTable> {
        $$CutsTableOrderingComposer(super.$state);
          
        }
      typedef $$MaterialsTableCreateCompanionBuilder = MaterialsCompanion Function({Value<int> rowid,});
typedef $$MaterialsTableUpdateCompanionBuilder = MaterialsCompanion Function({Value<int> rowid,});
class $$MaterialsTableTableManager extends RootTableManager    <_$AppDatabase,
    $MaterialsTable,
    LocalMaterial,
    $$MaterialsTableFilterComposer,
    $$MaterialsTableOrderingComposer,
    $$MaterialsTableCreateCompanionBuilder,
    $$MaterialsTableUpdateCompanionBuilder> {
    $$MaterialsTableTableManager(_$AppDatabase db, $MaterialsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        filteringComposer: $$MaterialsTableFilterComposer(ComposerState(db, table)),
        orderingComposer: $$MaterialsTableOrderingComposer(ComposerState(db, table)),
        updateCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> MaterialsCompanion(rowid: rowid,),
        createCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> MaterialsCompanion.insert(rowid: rowid,),));
        }
    class $$MaterialsTableFilterComposer extends FilterComposer<
        _$AppDatabase,
        $MaterialsTable> {
        $$MaterialsTableFilterComposer(super.$state);
          
        }
      class $$MaterialsTableOrderingComposer extends OrderingComposer<
        _$AppDatabase,
        $MaterialsTable> {
        $$MaterialsTableOrderingComposer(super.$state);
          
        }
      typedef $$CostsTableCreateCompanionBuilder = CostsCompanion Function({Value<int> rowid,});
typedef $$CostsTableUpdateCompanionBuilder = CostsCompanion Function({Value<int> rowid,});
class $$CostsTableTableManager extends RootTableManager    <_$AppDatabase,
    $CostsTable,
    LocalCost,
    $$CostsTableFilterComposer,
    $$CostsTableOrderingComposer,
    $$CostsTableCreateCompanionBuilder,
    $$CostsTableUpdateCompanionBuilder> {
    $$CostsTableTableManager(_$AppDatabase db, $CostsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        filteringComposer: $$CostsTableFilterComposer(ComposerState(db, table)),
        orderingComposer: $$CostsTableOrderingComposer(ComposerState(db, table)),
        updateCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> CostsCompanion(rowid: rowid,),
        createCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> CostsCompanion.insert(rowid: rowid,),));
        }
    class $$CostsTableFilterComposer extends FilterComposer<
        _$AppDatabase,
        $CostsTable> {
        $$CostsTableFilterComposer(super.$state);
          
        }
      class $$CostsTableOrderingComposer extends OrderingComposer<
        _$AppDatabase,
        $CostsTable> {
        $$CostsTableOrderingComposer(super.$state);
          
        }
      typedef $$InstallationsTableCreateCompanionBuilder = InstallationsCompanion Function({Value<int> rowid,});
typedef $$InstallationsTableUpdateCompanionBuilder = InstallationsCompanion Function({Value<int> rowid,});
class $$InstallationsTableTableManager extends RootTableManager    <_$AppDatabase,
    $InstallationsTable,
    LocalInstallation,
    $$InstallationsTableFilterComposer,
    $$InstallationsTableOrderingComposer,
    $$InstallationsTableCreateCompanionBuilder,
    $$InstallationsTableUpdateCompanionBuilder> {
    $$InstallationsTableTableManager(_$AppDatabase db, $InstallationsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        filteringComposer: $$InstallationsTableFilterComposer(ComposerState(db, table)),
        orderingComposer: $$InstallationsTableOrderingComposer(ComposerState(db, table)),
        updateCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> InstallationsCompanion(rowid: rowid,),
        createCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> InstallationsCompanion.insert(rowid: rowid,),));
        }
    class $$InstallationsTableFilterComposer extends FilterComposer<
        _$AppDatabase,
        $InstallationsTable> {
        $$InstallationsTableFilterComposer(super.$state);
          
        }
      class $$InstallationsTableOrderingComposer extends OrderingComposer<
        _$AppDatabase,
        $InstallationsTable> {
        $$InstallationsTableOrderingComposer(super.$state);
          
        }
      class $AppDatabaseManager {
final _$AppDatabase _db;
$AppDatabaseManager(this._db);
$$UsersTableTableManager get users => $$UsersTableTableManager(_db, _db.users);
$$ProjectsTableTableManager get projects => $$ProjectsTableTableManager(_db, _db.projects);
$$ProjectMembershipsTableTableManager get projectMemberships => $$ProjectMembershipsTableTableManager(_db, _db.projectMemberships);
$$MeasurementsTableTableManager get measurements => $$MeasurementsTableTableManager(_db, _db.measurements);
$$CutsTableTableManager get cuts => $$CutsTableTableManager(_db, _db.cuts);
$$MaterialsTableTableManager get materials => $$MaterialsTableTableManager(_db, _db.materials);
$$CostsTableTableManager get costs => $$CostsTableTableManager(_db, _db.costs);
$$InstallationsTableTableManager get installations => $$InstallationsTableTableManager(_db, _db.installations);
}
