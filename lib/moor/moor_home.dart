import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sandbox_flutter/moor/moor_database.dart';

class MoorHome extends StatefulWidget {
  @override
  _MoorHomeState createState() => _MoorHomeState();
}

class _MoorHomeState extends State<MoorHome> {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Column(
      children: <Widget>[
        FlatButton(
          child: Text('add'),
          onPressed: () {
            database.insertTask(Task(name: "Test Task", dueDate: DateTime.now().add(Duration(days: 5))));
          },
        ),
        FlatButton(
          child: Text('update latest'),
          onPressed: () async {
            var tasks = await database.getAllTasks();
            database.updateTask(tasks.last.copyWith(name: "edited"));
          },
        ),
        FlatButton(
          child: Text('delete all tasks'),
          onPressed: () {
            database.deleteAllTasks();
          },
        ),
        SizedBox(height: 16),
        Expanded(child: _buildTaskList(context, database)),
      ],
    );
  }

  StreamBuilder<List<Task>> _buildTaskList(BuildContext context, AppDatabase database) {
    return StreamBuilder(
      stream: database.watchAllTasks(),
      builder: (context, AsyncSnapshot<List<Task>> snapshot) {
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

  Widget _buildListItem(Task itemTask, AppDatabase database) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => database.deleteTask(itemTask),
        )
      ],
      child: CheckboxListTile(
          title: Text(itemTask.name),
          subtitle: Text(itemTask.dueDate?.toString() ?? 'No date'),
          value: itemTask.completed,
          onChanged: (newValue) {
            database.updateTask(itemTask.copyWith(completed: newValue));
          }),
    );
  }
}
