import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:widget_ptactice/screens/add_todo_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('todo list'),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: getTodoList,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(items[index]['title']),
                subtitle: Text(items[index]['description']),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      // Edit
                      editTodo(items[index]);
                    } else {
                      // Delete
                      deleteTodo(items[index]['_id']);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text('Eidt'),
                        value: 'edit',
                      ),
                      PopupMenuItem(
                        child: Text('Delete'),
                        value: 'delete',
                      )
                    ];
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigationToAddScreen,
        child: Text('add'),
      ),
    );
  }

  // Navigation Method
  void navigationToAddScreen() {
    final route = MaterialPageRoute(builder: (context) => AddTodoScreen());
    Navigator.push(context, route);
  }

  // Get Todos
  Future<void> getTodoList() async {
    final uri = Uri.parse('https://api.nstack.in/v1/todos?page=1&limit=10');
    final response = await http.get(uri);
    final json = jsonDecode(response.body) as Map;
    final results = json['items'];

    setState(() {
      items = results;
      isLoading = false;
    });
  }

  // Edit Todo
  editTodo(item) {
    final route =
        MaterialPageRoute(builder: (context) => AddTodoScreen(todo: item));
    Navigator.push(context, route);
  }

  // Delete Todo
  Future<void> deleteTodo(String id) async {
    final url = Uri.parse('https://api.nstack.in/v1/todos/$id');
    final respones = await http.delete(url);
    if (respones.statusCode == 200) {
      getTodoList();
    } else {
      print('something wronf');
      print(respones.body);
    }
  }
}
