import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  // task lists
  List<Items> _tasks = [];
  // variable hovered task index
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    //*********** loading  tasks from sharedpreferences on ***********///
    _loadTasks();
  }

  //*************** load tasks from shared preferences ***********//
  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks = (prefs.getStringList('tasks') ?? [])
          .map((item) => Items.fromJson(json.decode(item)))
          .toList();
    });
  }

  // ************** save tasks to shared preferences **********//
  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksJson =
        _tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  //************ show the modal to add a new task ******************//
  void _addTask() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.teal,
      builder: (context) {
        DateTime selectedDate = DateTime.now();
        TextEditingController newTaskController = TextEditingController();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newTaskController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'Enter task name',
                  hintStyle: TextStyle(color: Colors.white54),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  fixedSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (newDate != null) {
                    selectedDate = newDate;
                  }
                },
                child: const Text('Pick Date',
                    style: TextStyle(color: Colors.teal)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: Text('Add Task', style: TextStyle(color: Colors.teal)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  fixedSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (newTaskController.text.isNotEmpty) {
                    setState(() {
                      _tasks.add(Items(
                          name: newTaskController.text, date: selectedDate));
                      _saveTasks(); // Save new task
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //************* naavigate to the edit task screen ***************//
  void _navigateToEditTask(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(
            task: _tasks[index],
            onSave: (updatedTask) {
              setState(() {
                // ************ update task **************//
                _tasks[index] = updatedTask;

                // ************ save uppdated task ******//
              });
            }),
      ),
    );
  }

  //******************* deleting  task and show a snackbar *************//
  void _deleteTask(int index) {
    // ***************** store the name for snackbar *************//
    String deletedTaskName = _tasks[index].name;

    setState(() {
      // *************** remove task from list ************//
      _tasks.removeAt(index);
      //**************** save updated tasks **************//
      _saveTasks();
    });

    //********* show snackbar for task deletion **********//
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$deletedTaskName deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      //********** hovered index track ***********//
                      _hoveredIndex = index;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      //**** hovered index resetting *******//
                      _hoveredIndex = null;
                    });
                  },
                  child: Dismissible(
                    // *********** each task uniqu key **********//
                    key: Key(_tasks[index].name),
                    direction: DismissDirection.horizontal,

                    onDismissed: (direction) {
                      // ************* delete task  by swiping  **********//
                      _deleteTask(index);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Row(
                        children: [
                          Icon(Icons.delete, color: Colors.white),
                          SizedBox(width: 10),
                          Text('Delete',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Delete',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                          SizedBox(width: 10),
                          Icon(Icons.delete, color: Colors.white),
                        ],
                      ),
                    ),

                    child: Tooltip(
                      message: 'Swipe to delete',
                      //**************** Tooltip message shown on hover **********//
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: ListTile(
                          //***************// change color on hover **********//
                          tileColor: _hoveredIndex == index
                              ? Colors.grey
                              : Colors.teal,
                          title: Text(
                            _tasks[index].name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            DateFormat('MMM dd, yyyy')
                                .format(_tasks[index].date),
                            style: const TextStyle(color: Colors.white),
                          ),

                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),

                            //************** edit task on button press ************************//
                            onPressed: () => _navigateToEditTask(index),
                          ),

                          //*************** edit task on tile tap *****************//
                          onTap: () => _navigateToEditTask(index),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _addTask, // Open the add task modal
              child: Text('Add Task', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                fixedSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//************** screen for editing task *****************//

class EditTaskScreen extends StatelessWidget {
  final Items task;
  final Function(Items) onSave;

  EditTaskScreen({required this.task, required this.onSave});

  @override
  Widget build(BuildContext context) {
    //********** store the start date for editing ***********//
    DateTime initialDate = task.date;

    //********* controller for text field ************//
    TextEditingController editController =
        TextEditingController(text: task.name);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                hintText: 'Enter task name',
                hintStyle: TextStyle(color: Colors.teal),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Pick Date',
                  style: TextStyle(color: Colors.white)),
              onPressed: () async {
                DateTime? newDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (newDate != null) {
                  //********** Update the date  new date is picked ********//
                  initialDate = newDate;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fixedSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Save Task',
                  style: TextStyle(color: Colors.white)),
              onPressed: () {
                onSave(Items(
                    name: editController.text,
                    date: initialDate)); // Call onSave with updated task
                Navigator.pop(context); // Go back to the previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fixedSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// *********** model class for task *********//

class Items {
  final String name;
  final DateTime date;

  Items({required this.name, required this.date});

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date.toIso8601String(),
  };

  factory Items.fromJson(Map<String, dynamic> json) => Items(
    name: json['name'],
    date: DateTime.parse(json['date']),
  );
}
