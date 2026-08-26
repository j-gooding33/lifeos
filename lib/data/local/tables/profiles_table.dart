import 'package:drift/drift.dart';

/// §23.3. One row per signed-in user; the client-generated `id` matches the
/// Supabase auth user id once sync exists (M19).
class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();
  IntColumn get weekStart => integer().withDefault(const Constant(1))();
  TextColumn get currency => text().withDefault(const Constant('GBP'))();
  TextColumn get dateFormat => text().withDefault(const Constant('dmy'))();
  IntColumn get onboardedAt => integer().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
