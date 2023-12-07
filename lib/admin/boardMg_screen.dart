import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/drawerMg.dart';
import '../components/my_textfield.dart';
import '../components/wall_post.dart';

class boardPage extends StatefulWidget {
  const boardPage({Key? key}) : super(key: key);

  @override
  State<boardPage> createState() => _boardPageState();
}

class _boardPageState extends State<boardPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  File? _image;
  String? imageName;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      try {
        imageName = DateTime.now().millisecondsSinceEpoch.toString();
        final Reference storageReference = FirebaseStorage.instance.ref().child('images/$imageName');
        final UploadTask uploadTask = storageReference.putFile(_image!);
        await uploadTask.whenComplete(() {
          // Image uploaded successfully
          print('Image uploaded');
        });
      } catch (e) {
        // Error uploading image
        print('Error uploading image: $e');
      }
    }
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    // Only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      // Upload the image first
      _uploadImage().then((_) {
        // Once the image is uploaded, post the message to the database
        FirebaseFirestore.instance.collection("User Posts").add({
          "UserEmail": currentUser.email,
          'Message': textController.text,
          'TimeStamp': Timestamp.now(),
          'Likes': [],
          'ImageURL': _image != null ? 'images/$imageName' : null,
        });

        // Clear textfield and image
        setState(() {
          textController.clear();
          _image = null;
          imageName = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: MyDrawer(),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hide the back button
        title: Text("소통방"),
        centerTitle: true,
        backgroundColor: Colors.grey[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy("TimeStamp", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];
                      return WallPost(
                        messsage: post['Message'],
                        user: post['UserEmail'],
                        postId: post.id,
                        likes: List<String>.from(post['Likes'] ?? []),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: textController,
                    hintText: '입력하세요',
                    obscureText: false,
                  ),
                ),
                IconButton(
                  onPressed: postMessage,
                  icon: Icon(Icons.arrow_circle_up),
                ),
                IconButton(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}