import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class Task {
  late String id;
  late String task;
  late bool completed;

  Task({required this.id, required this.task, required this.completed});
}

class Category {
  var id;
  var name;
  var tasks;
  Category({required this.id, required this.name, required this.tasks});
}


class CloudService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addTask(Task task, String categoryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('to_do')
          .doc(categoryId)
          .collection('tasks')
          .doc(task.id)
          .set({
        'task': task.task,
        'completed': task.completed,
      });
      print('data has been added');
    } catch (error) {
      // Handle the error
      print('Error adding task: $error');
    }
  }

  Stream<List<Task>> getTasksStream(String userId) {
    var data =  _firestore
        .collection('users')
        .doc(userId)
        .collection('to_do')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Task(
          id: doc.id,
          task: data['task'] ?? '',
          completed: data['completed'] ?? false,
        );
      }).toList();
    });
    print(data);
    return data;
  }
  List<Task> _convertTasks(List<dynamic> tasksData) {
    return tasksData.map((taskData) {
      return Task(
        id: taskData['id'] ?? '',
        task: taskData['task'] ?? '',
        completed: taskData['completed'] ?? false,
      );
    }).toList();
  }


  Future<void> addCategory(String userId, String categoryName) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('to_do')
          .add({'category': categoryName, 'tasks': []});
    } catch (error) {
      print('Error adding category: $error');

    }
  }

  Stream<List> getCategoriesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('to_do')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Category(
          id: doc.id,
          name: data['category'] ?? '',
          tasks: _convertTasks(data['tasks'] ?? []),
        );
      }).toList();
    });
  }

}

