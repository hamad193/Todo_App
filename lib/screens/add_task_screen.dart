import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app/widgets/my_Button.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key, }) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  var taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                hintText: 'Type here...',
                // prefixIcon: Icon(Icons.mail),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            MyButton(
              title: 'Add',
              onPress: () async {
                String taskName = taskController.text.trim();

                if (taskName.isEmpty) {
                  Fluttertoast.showToast(msg: 'Field is empty');
                  return;
                }

                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  String uid = user.uid;
                  int dt = DateTime.now().millisecondsSinceEpoch;

                  DatabaseReference taskRef =
                      FirebaseDatabase.instance.ref().child('tasks').child(uid);

                  String? taskId = taskRef.push().key;
                  await taskRef.child(taskId!).set({
                    'dt': dt,
                    'taskName': taskName,
                    'taskId': taskId,
                  });
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
