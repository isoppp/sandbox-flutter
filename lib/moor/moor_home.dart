import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moor/moor.dart' as moor;
import 'package:provider/provider.dart';
import 'package:sandbox_flutter/moor/moor_database.dart';

class MoorHome extends StatefulWidget {
  @override
  _MoorHomeState createState() => _MoorHomeState();
}

class _MoorHomeState extends State<MoorHome> {
  bool showAll = false;
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Column(
      children: <Widget>[
        FlatButton(
          child: Text('add'),
          onPressed: () {
            database.taskDao.insertTask(
              TasksCompanion(
                name: moor.Value("Test Task"),
                dueDate: moor.Value(DateTime.now().add(Duration(days: 5))),
              ),
            );
          },
        ),
        FlatButton(
          child: Text('update latest'),
          onPressed: () async {
            var tasks = await database.taskDao.getAllTasks();
            database.taskDao.updateTask(tasks.last.copyWith(name: "edited"));
          },
        ),
        FlatButton(
          child: Text('delete all tasks'),
          onPressed: () {
            database.taskDao.deleteAllTasks();
          },
        ),
        FlatButton(
          child: Text('show not completed'),
          onPressed: () {
            setState(() {
              showAll = false;
            });
          },
        ),
        FlatButton(
          child: Text('show all'),
          onPressed: () {
            setState(() {
              showAll = true;
            });
          },
        ),
        SizedBox(height: 16),
        Expanded(child: _buildTaskList(context, database)),
      ],
    );
  }

  StreamBuilder<List<TaskWithTag>> _buildTaskList(BuildContext context, AppDatabase database) {
    final stream = showAll ? database.taskDao.watchAllTasksWithTag() : database.taskDao.watchUnCompletedTasksWithTag();
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<List<TaskWithTag>> snapshot) {
        final tasks = snapshot.data ?? [];

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (_, index) {
            final itemTask = tasks[index];
            return _buildListItem(itemTask, database);
          },
        );
      },
    );
  }

  Widget _buildListItem(TaskWithTag itemTask, AppDatabase database) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => database.taskDao.deleteTask(itemTask.task),
        )
      ],
      child: CheckboxListTile(
        title: Text(itemTask.task.name + ' ' + (itemTask?.tag?.name ?? 'null')),
        subtitle: Text(itemTask.task.dueDate?.toString() ?? 'No date'),
        value: itemTask.task.completed,
        onChanged: (newValue) {
          database.taskDao.updateTask(itemTask.task.copyWith(completed: newValue));
        },
      ),
    );
  }
}
