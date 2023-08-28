import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  File? selectedImage;

  void uploadImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      selectedImage = File(pickedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Profile'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.42,
                color: primaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Name",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "xyz@gmail.com",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
              Positioned(
                top: 30,
                child: Stack(
                  children: [
                    if (selectedImage == null)
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey.shade900,
                        child: Icon(
                          Icons.person,
                          size: 70,
                        ),
                      )
                    else
                      CircleAvatar(
                        backgroundImage: FileImage(File(selectedImage!.path)),
                        radius: 70,
                        backgroundColor: Colors.grey.shade900,
                        // child: Image.file(File(selectedImage!.path)),
                      ),
                    Positioned(
                      right: 1,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            uploadImage(ImageSource.camera);
                                            Navigator.of(context).pop();
                                          },
                                          child: ListTile(
                                            leading: Icon(Icons.camera_alt),
                                            title: Text('From Camera'),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            uploadImage(ImageSource.gallery);
                                            Navigator.of(context).pop();
                                          },
                                          child: ListTile(
                                            leading: Icon(Icons.image),
                                            title: Text('From Gallery'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
