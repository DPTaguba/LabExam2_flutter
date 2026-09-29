import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_labexam_taguba/crud_service.dart';
import 'package:flutter_labexam_taguba/main.dart';

void main() {
  testWidgets(
    'task list supports create, read, update, delete and validation',
    (WidgetTester tester) async {
      final repository = MemoryTaskRepository();
      await tester.pumpWidget(MyApp(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Labexam2_Lastname'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('add-task')));
      await tester.pump();
      expect(find.text('Please enter a task.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('task-input')),
        'Buy apples',
      );
      await tester.tap(find.byKey(const ValueKey('add-task')));
      await tester.pumpAndSettle();
      expect(find.text('Buy apples'), findsOneWidget);

      await tester.tap(find.byTooltip('Edit task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Buy pears');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Buy pears'), findsOneWidget);
      expect(find.text('Buy apples'), findsNothing);

      await tester.tap(find.byTooltip('Delete task'));
      await tester.pumpAndSettle();
      expect(find.text('Buy pears'), findsNothing);
    },
  );
}

class MemoryTaskRepository implements TaskRepository {
  final List<TaskItem> _tasks = [];
  late final StreamController<List<TaskItem>> _controller =
      StreamController<List<TaskItem>>.broadcast(onListen: _publish);

  void _publish() => _controller.add(List.unmodifiable(_tasks));

  @override
  Stream<List<TaskItem>> watchTasks() => _controller.stream;

  @override
  Future<void> addTask(String title) async {
    _tasks.add(TaskItem(id: title, title: title));
    _publish();
  }

  @override
  Future<void> updateTask(String id, String title) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    _tasks[index] = TaskItem(id: id, title: title);
    _publish();
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    _publish();
  }
}
