import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/drawerMg.dart';

class TimetableMgScreen extends StatefulWidget {
  @override
  _TimetableMgScreenState createState() => _TimetableMgScreenState();
}

class _TimetableMgScreenState extends State<TimetableMgScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _scheduleCollection = 'TimetableMgScreen';
  Map<String, String> _schedule = {};

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  void _loadSchedule() async {
    final documentSnapshot =
    await _firestore.collection(_scheduleCollection).doc('timetable').get();
    if (documentSnapshot.exists) {
      setState(() {
        _schedule = Map<String, String>.from(documentSnapshot.data()!);
      });
    }
  }

  void _saveSchedule() {
    _firestore.collection(_scheduleCollection).doc('timetable').set(_schedule);
  }

  void _showAddDialog(String key) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: _schedule[key]);
        return AlertDialog(
          title: Text('일정 추가'),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: '일정을 적으세요',
              filled: true,
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('삭제'),
              style: TextButton.styleFrom(
                primary: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  _schedule.remove(key);
                  _saveSchedule();
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('저장'),
              style: TextButton.styleFrom(
                primary: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _schedule[key] = controller.text;
                  _saveSchedule();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: MyDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨기기
        title: Text('시간표 (꾹 누르세요)'),
        centerTitle: true,
        backgroundColor: Colors.grey[700],
      ),
      body: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[500]),
              children: [
                SizedBox.shrink(),
                for (var day in [' 월 ', ' 화 ', ' 수 ', ' 목 ', ' 금 '])
                  Center(child: Text(day)),
              ],
            ),
            for (var i = 8; i <= 17; i++)
              TableRow(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    color: Colors.grey[300],
                    child: Center(child: Text('${i.toString().padLeft(2, '0')}:00')),
                  ),
                  for (var day in ['월', '화', '수', '목', '금'])
                    GestureDetector(
                      onLongPress: () => _showAddDialog('$day $i'),
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        height: 60,
                        child: Text(_schedule['$day $i'] ?? ''),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
