import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/design_tokens.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  final List<_TaskItem> _tasks = <_TaskItem>[
    _TaskItem(title: 'Conduct weekly safety inspection - R3 Block'),
    _TaskItem(title: 'Review landscape progress report'),
    _TaskItem(title: 'Follow up on HVAC maintenance - Tower A'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.lg,
          AppDimensions.md,
          AppDimensions.lg,
          AppDimensions.xl,
        ),
        itemCount: _tasks.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.sm),
        itemBuilder: (context, index) {
          final task = _tasks[index];

          return Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.xs,
              ),
              leading: Checkbox(
                value: task.isDone,
                onChanged: (next) {
                  setState(() {
                    task.isDone = next ?? false;
                  });
                },
              ),
              title: Text(
                task.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: IconButton(
                tooltip: 'Delete task',
                onPressed: () {
                  setState(() {
                    _tasks.removeAt(index);
                  });
                },
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> _showAddTaskDialog() async {
    final controller = TextEditingController();

    final taskTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: 'Enter task title'),
            onSubmitted: (value) {
              Navigator.of(context).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || taskTitle == null || taskTitle.isEmpty) {
      return;
    }

    setState(() {
      _tasks.insert(0, _TaskItem(title: taskTitle));
    });
  }
}

class _TaskItem {
  _TaskItem({required this.title});

  final String title;
  bool isDone = false;
}
