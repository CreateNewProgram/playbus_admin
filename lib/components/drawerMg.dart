import 'package:flutter/material.dart';
import '../admin/GpsMg_screen.dart';
import '../admin/alarmMg_screen.dart';
import '../admin/boardMg_screen.dart';
import '../admin/bustimeMg_screen.dart';
import '../admin/checkMg_page.dart';
import '../admin/homeMg_screen.dart';
import '../admin/noticeMg_screen.dart';
import '../admin/profileMg_screen.dart';
import '../admin/timetableMg_screen.dart';
import 'my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
                MyListTile(
                  icon: Icons.home,
                  text: '메인화면',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeMgScreen()),
                    );
                  },
                ),
                MyListTile(
                  icon: Icons.article_outlined,
                  text: '소통방',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => boardPage()),
                    );
                  },
                ),
                MyListTile(
                  icon: Icons.announcement,
                  text: '공지사항 관리',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NoticeScreen()),
                    );
                  },
                ),
                MyListTile(
                  icon: Icons.event,
                  text: '수업 시간표 관리',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TimetableMgScreen()),
                    );
                  },
                ),
                MyListTile(
                  icon: Icons.departure_board,
                  text: '버스 시간표 관리',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BusTimeScreen()),
                    );
                  },
                ),
                MyListTile(
                  icon: Icons.directions_bus,
                  text: '버스 위치 관리',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GPSScreen()),
                    );
                  },
                ),
                MyListTile(
                  icon: Icons.person,
                  text: '인원 체크 관리',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CheckBoxListWidget()),
                    );
                  },
                ),
                MyListTile(
                  icon: Icons.notifications,
                  text: '알림 전송',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
