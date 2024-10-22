import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controllertext = TextEditingController();
  final TextEditingController _controllername = TextEditingController();
  final TextEditingController _controllerage = TextEditingController();
  final TextEditingController _controllerarea = TextEditingController();
  String? selectedValue = "";

  // Firestoreから取得したデータを保存するリスト
  List<Map<String, dynamic>> dataList = [];

  // フォームのクリア
  void _clearForm() {
    _controllertext.clear();
    _controllername.clear();
    _controllerage.clear();
    _controllerarea.clear();
    setState(() {
      selectedValue = "";
    });
  }

  // Firestoreにデータを追加する
  void _addData() {
    FirebaseFirestore.instance
        .collection('ex18Collection')
        .doc(_controllertext.text)
        .set({
      '氏名': _controllername.text,
      '年齢': int.parse(_controllerage.text),
      '性別': selectedValue,
      '出身地': _controllerarea.text,
    }, SetOptions(merge: true));
    _clearForm(); // フォームをクリア
  }

  // Firestoreからデータを手動で取得する
  Future<void> _fetchData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('ex18Collection').get();
    setState(() {
      // 取得したデータをリストに保存
      dataList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  // データ追加フォーム
  Widget _buildAddForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'ドキュメント名',
            ),
            controller: _controllertext,
          ),
          TextField(
            decoration: const InputDecoration(
              hintText: '氏名',
            ),
            controller: _controllername,
          ),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '年齢',
            ),
            controller: _controllerage,
          ),
          ListTile(
              title: const Text("男性"),
              leading: Radio(
                  value: "男性",
                  groupValue: selectedValue,
                  onChanged: (val) {
                    setState(() {
                      selectedValue = val;
                    });
                  })),
          ListTile(
              title: const Text("女性"),
              leading: Radio(
                  value: "女性",
                  groupValue: selectedValue,
                  onChanged: (val) {
                    setState(() {
                      selectedValue = val;
                    });
                  })),
          ListTile(
              title: const Text("未回答"),
              leading: Radio(
                  value: "未回答",
                  groupValue: selectedValue,
                  onChanged: (val) {
                    setState(() {
                      selectedValue = val;
                    });
                  })),
          TextField(
            decoration: const InputDecoration(
              hintText: '出身地',
            ),
            controller: _controllerarea,
          ),
          TextButton(
            onPressed: _addData,
            child: const Text(
              'データ追加',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  // Firestoreから取得したデータを表示する
  Widget _buildDataList() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _fetchData, // ボタン押下でデータを取得
          child: const Text('一覧取得'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              var document = dataList[index];
              return ListTile(
                title: Text(document['氏名'] ?? ''),
                subtitle: Text(
                    '年齢: ${document['年齢']} 性別: ${document['性別']} 出身地: ${document['出身地']}'),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // タブの数
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo Home Page'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'データ追加'),
              Tab(text: 'データ一覧'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAddForm(), // データ追加フォーム
            _buildDataList(), // データ一覧表示
          ],
        ),
      ),
    );
  }
}
