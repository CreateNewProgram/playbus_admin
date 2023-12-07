import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/drawerMg.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({Key? key}) : super(key: key);

  @override
  _NoticeScreenState createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _noticesCollection = 'NoticeScreen';
  List<String> _notices = [];

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  void _loadNotices() async {
    final querySnapshot = await _firestore.collection(_noticesCollection).get();
    setState(() {
      _notices = querySnapshot.docs.map((doc) => doc['content'] as String).toList();
    });
  }

  void _saveNotice(String content) {
    _firestore.collection(_noticesCollection).add({'content': content});
  }

  void _updateNotice(String id, String content) {
    _firestore.collection(_noticesCollection).doc(id).update({'content': content});
  }

  void _deleteNotice(String id) {
    _firestore.collection(_noticesCollection).doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: MyDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨기기
        title: const Text('공지사항'),
        centerTitle: true,
        backgroundColor: Colors.grey[700],
      ),
      body: Container(
        color: Colors.grey[300],
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection(_noticesCollection).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return _buildNoticeList(snapshot.data!.docs);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoticeDialog(),
        tooltip: '공지사항 추가',
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoticeList(List<QueryDocumentSnapshot> documents) {
    return ListView(
      children: documents.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        return ListTile(
          title: Text(data['content']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.black,
                onPressed: () => _showAddNoticeDialog(initialContent: data['content'], documentId: document.id),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.black,
                onPressed: () => _deleteNotice(document.id),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showAddNoticeDialog({String? initialContent, String? documentId}) {
    TextEditingController controller = TextEditingController(text: initialContent);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('공지사항 추가'),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: '공지사항을 적으세요',
              filled: true,
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (documentId != null) {
                  _updateNotice(documentId, controller.text);
                } else {
                  _saveNotice(controller.text);
                }
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                primary: Colors.black,
              ),
              child: Text(documentId != null ? '수정' : '추가'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                primary: Colors.black,
              ),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }
}
