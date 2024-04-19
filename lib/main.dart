import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      home: TodoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<TodoItem> _todoItems = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  FilterType _selectedFilter = FilterType.all;

  void _addTodoItem(String task, String description) {
    setState(() {
      _todoItems.add(TodoItem(task: task, completed: false, description: description));
    });
    _taskController.clear();
    _descriptionController.clear();
  }

  void _toggleTodoItem(int index) {
    setState(() {
      _todoItems[index].completed = !_todoItems[index].completed;
    });
  }

  void _deleteTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
  }

  void _editTodoItem(int index) {
    // Pre-fill the text controllers with the current values
    _taskController.text = _todoItems[index].task;
    _descriptionController.text = _todoItems[index].description;

    // Show a dialog to edit the task and description
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: InputDecoration(labelText: 'Task'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update the task and description in the to-do list
                setState(() {
                  _todoItems[index].task = _taskController.text;
                  _todoItems[index].description = _descriptionController.text;
                });

                // Clear the text controllers and close the dialog
                _taskController.clear();
                _descriptionController.clear();
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                // Clear the text controllers and close the dialog
                _taskController.clear();
                _descriptionController.clear();
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  List<TodoItem> _getFilteredTodoItems() {
    switch (_selectedFilter) {
      case FilterType.completed:
        return _todoItems.where((item) => item.completed).toList();
      case FilterType.incomplete:
        return _todoItems.where((item) => !item.completed).toList();
      default:
        return _todoItems;
    }
  }

  String _getCurrentDate() {
    // Get the current date and format it as desired
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d, yyyy'); // Customize the date format as needed
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do App'),
        actions: [
          PopupMenuButton<FilterType>(
            onSelected: (FilterType selected) {
              setState(() {
                _selectedFilter = selected;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<FilterType>>[
              PopupMenuItem<FilterType>(
                value: FilterType.all,
                child: Text('All Tasks'),
              ),
              PopupMenuItem<FilterType>(
                value: FilterType.completed,
                child: Text('Completed Tasks'),
              ),
              PopupMenuItem<FilterType>(
                value: FilterType.incomplete,
                child: Text('Incomplete Tasks'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInputFields(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _getCurrentDate(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Customize the text style as needed
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _getFilteredTodoItems().length,
              itemBuilder: (context, index) {
                final todoItem = _getFilteredTodoItems()[index];
                return ListTile(
                  leading: Checkbox(
                    value: todoItem.completed,
                    onChanged: (bool? value) {
                      _toggleTodoItem(index);
                    },
                  ),
                  title: Text(
                    todoItem.task,
                    style: TextStyle(
                      decoration: todoItem.completed ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  subtitle: todoItem.description.isNotEmpty ? Text(todoItem.description) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editTodoItem(index);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteTodoItem(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 195, 217, 227),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              onSubmitted: (task) {
                final description = _descriptionController.text;
                if (task.isNotEmpty) {
                  _addTodoItem(task, description);
                }
              },
              decoration: InputDecoration(
                labelText: 'Task',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              onSubmitted: (description) {
                final task = _taskController.text;
                if (description.isNotEmpty && task.isNotEmpty) {
                  _addTodoItem(task, description);
                }
              },
              decoration: InputDecoration(
                labelText: 'Description (optional)',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final task = _taskController.text;
                final description = _descriptionController.text;
                if (task.isNotEmpty) {
                  _addTodoItem(task, description);
                }
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoItem {
  String task;
  bool completed;
  String description;

  TodoItem({required this.task, required this.completed, this.description = ''});
}

enum FilterType { all, completed, incomplete }
