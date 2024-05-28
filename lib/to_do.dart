import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do/services/auth_service.dart';
import 'package:to_do/services/to_do_services.dart';
import 'package:to_do/shared/msgs.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      home: ToDoScreen(),
    );
  }
}

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, List<String>>> tasksByCategory = [
    {'Personal': [], 'Completed': []},
    {'Work': [], 'Completed': []},
    // Add more categories as needed
  ];

  TextEditingController taskController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  CloudService _cloudService = CloudService();
  AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tasksByCategory.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void addTask(String category) async {
    try {
      setState(() async {
        String newTaskDescription = taskController.text;
        if (newTaskDescription.isNotEmpty) {
          Task newTask = Task(id: DateTime.now().toString(),
              task: newTaskDescription,
              completed: false);
          await _cloudService.addTask(newTask,categoryController.text);
          tasksByCategory[_tabController.index][category]!.add(newTask.task);
          taskController.clear();
        }
      });
    } catch (error) {
      ToastUtils.showErrorSnackbar(context, error.toString());
    }
  }

  void addCategory() {
    setState(() {
      String newCategory = categoryController.text;
      if (newCategory.isNotEmpty &&
          !tasksByCategory.any((category) => category.keys.first == newCategory)) {
        tasksByCategory.add({newCategory: [], 'Completed': []});
        _tabController.dispose(); // Dispose old TabController
        _tabController = TabController(length: tasksByCategory.length, vsync: this);
        categoryController.clear();
      }
    });
  }

  void completeTask(int index, String category) {
    setState(() {
      String completedTask = tasksByCategory[_tabController.index][category]!.removeAt(index);
      tasksByCategory[_tabController.index]['Completed']!.add(completedTask);
    });
  }

  void deleteTask(int index, String category) {
    setState(() {
      tasksByCategory[_tabController.index]['Completed']!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tasksByCategory.map((category) => Tab(text: category.keys.first)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      hintText: 'Enter a new task',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => addTask(tasksByCategory[_tabController.index].keys.first!),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tasksByCategory.map((category) {
                String categoryName = category.keys.first;
                List<String> tasks = category[categoryName]!;
                List<String> tasks_completed = category['Completed']!;
                return Column(
                  children: [
                    StreamBuilder(stream: _cloudService.getTasksStream(FirebaseAuth.instance.currentUser!.uid),builder: (context, snapshot) {for (final x in snapshot.data!) {print(x.task);};return Text('acs');},),
                    Expanded(
                      child: ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(tasks[index]),
                            trailing: IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () => completeTask(index, categoryName),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(),
                    if (tasks_completed.length == 0)
                       Expanded(
                        child: Center(
                          child: Text('No Completed Task',style: TextStyle(color: Theme.of(context).disabledColor),) ,),
                      )

                    else
                    Expanded(
                      child: ListView.builder(
                        itemCount: tasksByCategory[_tabController.index]['Completed']!.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              tasksByCategory[_tabController.index]['Completed']![index],
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => deleteTask(index, categoryName),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Category'),
                content: TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    hintText: 'Enter a new category',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      addCategory();
                      Navigator.pop(context);
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
