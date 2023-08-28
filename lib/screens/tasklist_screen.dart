import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ndialog/ndialog.dart';
import 'package:todo_app/constants/colors.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:todo_app/screens/add_task_screen.dart';
import 'package:todo_app/screens/login_screen.dart';
import 'package:todo_app/screens/profile_screen.dart';
import 'package:todo_app/screens/update_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  User? user;
  DatabaseReference? taskRef;

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      taskRef = FirebaseDatabase.instance.ref().child('tasks').child(user!.uid);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ProfileScreen()));
            },
            icon: const Icon(
              Icons.person,
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: (context),
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Confirmation!'),
                    content: const Text('Do you want to Log out?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('No')),
                      TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text('Yes')),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddTaskScreen()));
        },
        child: const Icon(
          Icons.add,
          color: secondaryColor,
        ),
      ),
      body: StreamBuilder(
        stream: taskRef != null ? taskRef!.onValue : null,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            var event = snapshot.data as DatabaseEvent;
            var snapshot2 = event.snapshot.value;

            if (snapshot2 == null) {
              return const Center(child: Text('No Tasks Added Yet!'));
            }

            if (snapshot2 is Map<dynamic, dynamic>) {
              Map<String, dynamic> map = Map<String, dynamic>.from(snapshot2);

              var tasks = <TaskModel>[];

              for (var taskMap in map.values) {
                TaskModel taskModel =
                    TaskModel.fromMap(Map<String, dynamic>.from(taskMap));
                tasks.add(taskModel);
              }

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  TaskModel task = tasks[index];

                  return Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Card(
                      child: ListTile(
                        title: Text(task.taskName),
                        subtitle: Text(getReadableDate(task.dt)),
                        trailing: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          // width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateTaskScreen(task: task)));
                                  },
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: (context),
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Confirmation!'),
                                          content: const Text(
                                              'Are you sure to delete?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('No')),
                                            TextButton(
                                                onPressed: () async {
                                                  Navigator.of(context).pop();

                                                  if (taskRef != null) {
                                                    await taskRef!
                                                        .child(task.taskId)
                                                        .remove();
                                                  }
                                                },
                                                child: const Text('Yes')),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.delete)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('Unexpected data format'));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  String getReadableDate(int dt) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt);

    return DateFormat('dd MMM yyyy').format(dateTime);
  }
}
