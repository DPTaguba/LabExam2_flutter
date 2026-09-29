import 'package:flutter/material.dart';

import 'crud_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.repository});

  final TaskRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) {
      _showMessage('Please enter a task.');
      return;
    }

    try {
      await widget.repository.addTask(title);
      _taskController.clear();
    } catch (error) {
      if (mounted) _showMessage('Could not add task: $error');
    }
  }

  Future<void> _editTask(TaskItem task) async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => _EditTaskDialog(task: task),
    );
    if (title == null || title.isEmpty) return;

    try {
      await widget.repository.updateTask(task.id, title);
    } catch (error) {
      if (mounted) _showMessage('Could not update task: $error');
    }
  }

  Future<void> _deleteTask(TaskItem task) async {
    try {
      await widget.repository.deleteTask(task.id);
    } catch (error) {
      if (mounted) _showMessage('Could not delete task: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FA),
        title: const Text(
          'Labexam2_Taguba',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More options',
            onSelected: (value) {
              if (value == 'about') {
                showAboutDialog(
                  context: context,
                  applicationName: 'Food List',
                  applicationVersion: '1.0.0',
                  children: const [
                    Text('A simple task list saved in Firebase Firestore.'),
                  ],
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: TextField(
                      key: const ValueKey('task-input'),
                      controller: _taskController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addTask(),
                      decoration: InputDecoration(
                        hintText: 'Add a new task...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9AA2A8),
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEEF1F3),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 42,
                  height: 42,
                  child: FilledButton(
                    key: const ValueKey('add-task'),
                    onPressed: _addTask,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF126F88),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(Icons.add, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<TaskItem>>(
                stream: widget.repository.watchTasks(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Could not load tasks. Check your Firestore setup.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tasks = snapshot.data!;
                  if (tasks.isEmpty) return const SizedBox.expand();

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFCFD),
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF343A3E),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Edit task',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _editTask(task),
                              icon: const Icon(
                                Icons.edit,
                                size: 17,
                                color: Color(0xFF7C858A),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete task',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _deleteTask(task),
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Color(0xFFE45656),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditTaskDialog extends StatefulWidget {
  const _EditTaskDialog({required this.task});

  final TaskItem task;

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.task.title,
  );
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = 'A task cannot be empty.');
      return;
    }
    Navigator.pop(context, title);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit task'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(labelText: 'Task', errorText: _errorText),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
