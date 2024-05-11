import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class AddTodoScreen extends StatefulWidget {
  final dynamic todo;

  AddTodoScreen({super.key, this.todo});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  // Forms Controller
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdited = false;
  String titlePage = 'Add To Do';
  String BtnText = 'Submit';

  @override
  void initState() {
    super.initState();

    if (widget.todo != null) {
      print(widget.todo);
      titlePage = "Edit To Do";
      BtnText = "Edit";
      isEdited = true;
      titleController.text = widget.todo['title'];
      descriptionController.text = widget.todo['description'];
    } else {
      isEdited = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.todo);
    return Scaffold(
      appBar: AppBar(
        title: Text('${titlePage}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: "Title",
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: "Description",
            ),
            minLines: 5,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(onPressed: checkEditedOrAdd, child: Text('${BtnText}'))
        ],
      ),
    );
  }

  Future<void> editTodo(id) async {
    // Get Form Values
    final title = titleController.text;
    final desciption = descriptionController.text;
    final body = {
      "title": title,
      "description": desciption,
      "is_completed": false
    };
    // Send To server
    final uri = Uri.parse('https://api.nstack.in/v1/todos/$id');

    final response = await http.put(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage('Edited is Done');
      Navigator.pop(context);
    } else {
      showErrorMessage('Edit Faild');
    }
  }

  // Check IsEdited 
  void checkEditedOrAdd(){
    if(isEdited){
      editTodo(widget.todo['_id']);
    }else{
      submitFormData();
    }
  }
  // Submit Form date
  Future<void> submitFormData() async {

    
    // get form date
    final title = titleController.text;
    final desciption = descriptionController.text;
    final body = {
      "title": title,
      "description": desciption,
      "is_completed": false
    };

    // submit to server
    final uri = Uri.parse('https://api.nstack.in/v1/todos');
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      // success
      showSuccessMessage('Creation is successfull');
      titleController.text = '';
      descriptionController.text = '';
      Navigator.pop(context);
      print(response.body);
    } else {
      showErrorMessage('Creation is Faild');
      print(response.body);
    }

    // show results success or faild
  }

  // Show Success Message
  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.greenAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Show Error Message
  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
