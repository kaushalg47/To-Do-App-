import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  
  final List<TodoItem> _todoItems = [];
  final TextEditingController _textController = TextEditingController();

  void _addTodoItem(String task) {
    setState(() {
      _todoItems.add(TodoItem(task: task, completed: false, date: _selectedDay));
    });
    _textController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do App'),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          _buildInputField(),
          Expanded(
            child: _buildTodoList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2050, 1, 1),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarFormat: CalendarFormat.week,
      headerVisible: false,
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _textController,
        onSubmitted: (task) {
          if (task.isNotEmpty) {
            _addTodoItem(task);
          }
        },
        decoration: InputDecoration(
          labelText: 'Add a new to-do item',
          suffixIcon: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              final task = _textController.text;
              if (task.isNotEmpty) {
                _addTodoItem(task);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    // Filter to-do items based on the selected day
    final filteredTodoItems = _todoItems.where((item) => isSameDay(item.date, _selectedDay)).toList();

    return ListView.builder(
      itemCount: filteredTodoItems.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Checkbox(
            value: filteredTodoItems[index].completed,
            onChanged: (bool? value) {
              _toggleTodoItem(index);
            },
          ),
          title: Text(
            filteredTodoItems[index].task,
            style: TextStyle(
              decoration: filteredTodoItems[index].completed
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteTodoItem(index);
            },
          ),
        );
      },
    );
  }
}

class TodoItem {
  String task;
  bool completed;
  DateTime date;

  TodoItem({required this.task, required this.completed, required this.date});
}
