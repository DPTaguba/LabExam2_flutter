import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class TaskItem {
  const TaskItem({required this.id, required this.title});

  final String id;
  final String title;
}

abstract interface class TaskRepository {
  Stream<List<TaskItem>> watchTasks();
  Future<void> addTask(String title);
  Future<void> updateTask(String id, String title);
  Future<void> deleteTask(String id);
}

// Firestore snapshots keep the task list synchronized with database changes.
class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository(this.firestore);

  final FirebaseFirestore firestore;
  CollectionReference<Map<String, dynamic>> get _tasks =>
      firestore.collection('tasks');

  @override
  Stream<List<TaskItem>> watchTasks() {
    return _tasks
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => TaskItem(
                  id: document.id,
                  title: document.data()['title'] as String? ?? '',
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<void> addTask(String title) async {
    await _tasks.add({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateTask(String id, String title) async {
    await _tasks.doc(id).update({'title': title});
  }

  @override
  Future<void> deleteTask(String id) async {
    await _tasks.doc(id).delete();
  }
}
