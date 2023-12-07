import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/drawerMg.dart';

class CheckBoxListWidget extends StatefulWidget {
  @override
  _CheckBoxListWidgetState createState() => _CheckBoxListWidgetState();
}

class _CheckBoxListWidgetState extends State<CheckBoxListWidget> {
  List<String> itemList = [];
  List<String> itemCheckedList = [];
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: MyDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨기기
        title: Text('인원 체크'),
        centerTitle: true,
        backgroundColor: Colors.grey[700],
      ),
      body: Container(
        color: Colors.grey[300],
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: '추가할 인원의 이름을 적으세요',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    addItem();
                  },
                  child: Text('추가'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: itemList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Checkbox(
                      value: itemCheckedList[index] == 'true',
                      onChanged: (bool? value) {
                        setState(() {
                          itemCheckedList[index] = value != null ? value.toString() : 'false';
                        });
                      },
                      activeColor: Colors.black, // Set checkbox color to black
                    ),
                    title: Text(itemList[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.black,
                      onPressed: () {
                        removeItem(index);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addItem() {
    String item = textController.text.trim();
    if (item.isNotEmpty) {
      setState(() {
        itemList.add(item);
        itemCheckedList.add('false');
      });
      textController.clear();

      saveDataToFirestore();
    }
  }

  void removeItem(int index) {
    setState(() {
      itemList.removeAt(index);
      itemCheckedList.removeAt(index);
    });

    saveDataToFirestore();
  }

  Future<void> saveDataToFirestore() async {
    try {
      CollectionReference itemsCollection = FirebaseFirestore.instance.collection('check');
      await itemsCollection.doc('list').delete();
      await itemsCollection.doc('list').set({
        'items': itemList,
        'checkedItems': itemCheckedList,
      });
      print('Data saved to Firestore');
    } catch (e) {
      print('Error saving data to Firestore: $e');
    }
  }

  Future<void> loadDataFromFirestore() async {
    try {
      CollectionReference itemsCollection = FirebaseFirestore.instance.collection('check');
      DocumentSnapshot snapshot = await itemsCollection.doc('list').get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          itemList = (data['items'] as List<dynamic>).cast<String>();
          itemCheckedList = (data['checkedItems'] as List<dynamic>).cast<String>();
        });
        print('Data loaded from Firestore');
      }
    } catch (e) {
      print('Error loading data from Firestore: $e');
    }
  }
}
