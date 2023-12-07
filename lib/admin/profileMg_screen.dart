import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/drawerMg.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final currentUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: MyDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨기기
        title: Text('프로필'),
        centerTitle: true,
        backgroundColor: Colors.grey[700],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50,),

          // profile pic
          const Icon(
            Icons.person,
            size: 72,
          ),

          SizedBox(height: 10),

          // user email
          Text(
            currentUser.email!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}