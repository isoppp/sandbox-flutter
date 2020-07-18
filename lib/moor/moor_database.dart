import 'dart:io';

import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'moor_database.g.dart';

@DataClassName('Task')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tagName => text().nullable().customConstraint('NULL REFERENCES tags(name)')();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

@DataClassName('Tag')
class Tags extends Table {
  TextColumn get name => text().withLength(min: 1, max: 16)();
  IntColumn get color => integer()();

  @override
  Set<Column> get primaryKey => {name};
}

class TaskWithTag {
  final Task task;
  final Tag tag;

  TaskWithTag({
    @required this.task,
    @required this.tag,
  });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file, logStatements: true);
  });
}

@UseMoor(tables: [Tasks, Tags], daos: [TaskDao, TagDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from == 1) {
            await migrator.addColumn(tasks, tasks.tagName);
            await migrator.createTable(tags);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

@UseDao(tables: [Tasks, Tags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  final AppDatabase db;

  TaskDao(this.db) : super(db);

  Future<List<Task>> getAllTasks() => select(tasks).get();
  Stream<List<TaskWithTag>> watchAllTasksWithTag() {
    return (select(tasks)
          ..orderBy(
            [
              (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.desc),
              (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc), // asc is default
            ],
          ))
        .join(
          [
            leftOuterJoin(tags, tags.name.equalsExp(tasks.tagName)),
          ],
        )
        .watch()
        .map((rows) {
          return rows.map((row) {
            return TaskWithTag(
              task: row.readTable(tasks),
              tag: row.readTable(tags),
            );
          }).toList();
        });
  }

  Stream<List<TaskWithTag>> watchUnCompletedTasksWithTag() {
    return (select(tasks)
          ..orderBy(
            [
              (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.desc),
              (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc), // asc is default
            ],
          )
          ..where(
            (t) => t.completed.equals(false),
          ))
        .join(
          [
            leftOuterJoin(tags, tags.name.equalsExp(tasks.tagName)),
          ],
        )
        .watch()
        .map((rows) {
          return rows.map((row) {
            return TaskWithTag(
              task: row.readTable(tasks),
              tag: row.readTable(tags),
            );
          }).toList();
        });
  }

  Future<int> insertTask(Insertable<Task> task) => into(tasks).insert(task);
  Future<bool> updateTask(Insertable<Task> task) => update(tasks).replace(task);
  Future<int> deleteTask(Insertable<Task> task) => delete(tasks).delete(task);
  Future<void> deleteAllTasks() => delete(tasks).go();
}

@UseDao(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  final AppDatabase db;

  TagDao(this.db) : super(db);

  Stream<List<Tag>> watchTags() => select(tags).watch();
  Future insertTag(Insertable<Tag> tag) => into(tags).insert(tag);
}
