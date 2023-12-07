import 'package:flutter/material.dart';
import 'GpsMg_screen.dart';
import 'alarmMg_screen.dart';
import 'checkMg_page.dart';
import 'noticeMg_screen.dart';
import 'timetableMg_screen.dart';
import 'bustimeMg_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeMgScreen extends StatelessWidget {
  HomeMgScreen({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.email! + " 로그인"),
        backgroundColor: Colors.grey[700],
      ),
      body: Container(
        color: Colors.grey[300],
        child: Align(
          alignment: Alignment.center,
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              _buildCard(
                icon: Icons.content_paste,
                title: '공지관리',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NoticeScreen()),
                  );
                },
              ),
              _buildCard(
                icon: Icons.event,
                title: '시간표 관리',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TimetableMgScreen()),
                  );
                },
              ),
              _buildCard(
                icon: Icons.departure_board,
                title: '버스 시간표',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BusTimeScreen()),
                  );
                },
              ),
              _buildCard(
                icon: Icons.gps_fixed,
                title: '버스 위치 정보',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GPSScreen()),
                  );
                },
              ),
              _buildCard(
                icon: Icons.person,
                title: '인원 체크',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CheckBoxListWidget()),
                  );
                },
              ),
              _buildCard(
                icon: Icons.alarm,
                title: '알림 보내기',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.black),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
