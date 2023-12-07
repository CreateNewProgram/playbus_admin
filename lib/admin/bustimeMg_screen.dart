import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/drawerMg.dart';

class BusTimeScreen extends StatefulWidget {
  const BusTimeScreen({Key? key}) : super(key: key);

  @override
  _BusTimeScreenState createState() => _BusTimeScreenState();
}

class _BusTimeScreenState extends State<BusTimeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _timetableCollection = 'BusTimeScreen';

  @override
  void initState() {
    super.initState();
  }

  void _saveTimetable(String content) {
    _firestore.collection(_timetableCollection).add({
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _updateTimetable(String id, String content) {
    _firestore.collection(_timetableCollection).doc(id).update({
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _deleteTimetable(String id) {
    _firestore.collection(_timetableCollection).doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: MyDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨기기
        title: const Text('버스 시간표'),
        centerTitle: true,
        backgroundColor: Colors.grey[700],
      ),
      body: Container(
        color: Colors.grey[300],
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection(_timetableCollection).orderBy('timestamp').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['content']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.black,
                        onPressed: () => _showUpdateTimetableDialog(document.id, data['content']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.black,
                        onPressed: () => _deleteTimetable(document.id),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTimetableDialog(),
        tooltip: '버스 시간표 추가',
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTimetableDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('버스 시간표 추가'),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color: Colors.black, // 입력란 텍스트 색상 검정색으로 변경
            ),
            decoration: InputDecoration(
              hintText: '정류장 이름과 시간',
              filled: true,
              fillColor: Colors.grey[300], // 입력란 배경색 회색으로 변경
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _saveTimetable(controller.text);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                primary: Colors.black, // 버튼 텍스트 색상 회색으로 변경
              ),
              child: const Text('추가'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                primary: Colors.black, // 버튼 텍스트 색상 회색으로 변경
              ),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }


  void _showUpdateTimetableDialog(String id, String currentContent) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: currentContent);
        return AlertDialog(
          title: const Text('버스 시간표 수정'),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color: Colors.black, // 입력란 텍스트 색상 검정색으로 변경
            ),
            decoration: InputDecoration(
              hintText: '수정할 시간표',
              filled: true,
              fillColor: Colors.grey[300], // 입력란 배경색 회색으로 변경
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateTimetable(id, controller.text);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                primary: Colors.black, // 버튼 텍스트 색상 회색으로 변경
              ),
              child: const Text('수정'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                primary: Colors.black, // 버튼 텍스트 색상 회색으로 변경
              ),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

}
