
import 'package:flutter/material.dart';
import 'package:reshma/todoList.dart';

void main() {
  runApp(const TodoReshma());
}

class TodoReshma extends StatelessWidget {
  const TodoReshma({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.red[50],
      ),
      home: TodoList(),
    );
  }
}

