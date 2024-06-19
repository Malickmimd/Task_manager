import 'package:flutter/material.dart';
import 'package:simple_todo_app/database/database_helper.dart';
import 'package:simple_todo_app/widgets/task_filter.dart';
import 'package:simple_todo_app/screens/add_task_page.dart';
import 'package:simple_todo_app/screens/edit_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tasks = [];
  Map<String, bool> filters = {
    'Todo': true,
    'In progress': true,
    'Done': true,
    'Bug': true,
  };

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final dbTasks = await DatabaseHelper().getTasks();
    setState(() {
      tasks = dbTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF333333),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text('Todo App',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TaskFilter(
              initialFilters: filters,
              onFilterChanged: (newFilters) {
                setState(() {
                  filters = newFilters;
                });
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredTasks().length,
        itemBuilder: (context, index) {
          final task = _filteredTasks()[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: _getStatusColor(task['status'])),
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListTile(
              leading:
                  Icon(Icons.circle, color: _getStatusColor(task['status'])),
              title: Text(
                task['title'],
                style: const TextStyle(color: Colors.black),
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditTaskPage(
                      task: {
                        'id': task['id'].toString(),
                        'title': task['title'],
                        'description': task['description'],
                        'status': task['status'],
                      },
                      onUpdate: (updatedTask) {
                        setState(() {
                          tasks[index] = updatedTask;
                        });
                      },
                    ),
                  ),
                );
                if (result == true) {
                  _loadTasks();
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );
          if (result == true) {
            _loadTasks();
          }
        },
        backgroundColor: const Color(0xFF333333),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Map<String, dynamic>> _filteredTasks() {
    return tasks.where((task) {
      return filters[task['status']]!;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In progress':
        return const Color(0xFF56CCF2);
      case 'Done':
        return const Color(0xFF27AE60);
      case 'Bug':
        return const Color(0xFFEB5757);
      default:
        return const Color(0xFF4F4F4F);
    }
  }
}
