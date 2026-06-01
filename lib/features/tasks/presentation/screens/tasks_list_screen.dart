import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.primary,
          onPressed: () => context.go(RouteNames.dashboard),
        ),
        title: const Text('Tasks'),
      ),
      body: ListView.separated(
        padding: AppDimensions.screenPadding,
        itemCount: _tasks.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.sm),
        itemBuilder: (context, index) {
          final task = _tasks[index];

          return AppCard(
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
                style: AppTextStyles.body.copyWith(
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
        backgroundColor: AppColors.primary,
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
