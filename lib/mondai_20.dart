import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controllertext = TextEditingController();
  final TextEditingController _controllername = TextEditingController();
  final TextEditingController _controllerage = TextEditingController();
  final TextEditingController _controllerarea = TextEditingController();
  String? selectedValue = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'ドキュメント名',
              ),
              controller: _controllertext,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: '氏名',
              ),
              controller: _controllername,
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
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
              decoration: InputDecoration(
                hintText: '出身地',
              ),
              controller: _controllerarea,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  // 追加/更新ボタン
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('ex20Collection')
                        .doc(_controllertext.text)
                        .set({
                      '氏名': _controllername.text,
                      '年齢': int.parse(_controllerage.text),
                      '性別': selectedValue,
                      '出身地': _controllerarea.text,
                    }, SetOptions(merge: true));

                    _controllername.clear();
                    _controllerage.clear();
                    _controllertext.clear();
                    _controllerarea.clear();
                    setState(() {
                      selectedValue = ""; // ラジオボタンもリセット
                    });
                  },
                  child: const Text(
                    '追加/更新',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                TextButton(
                  // 削除ボタン
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('ex20Collection')
                        .doc(_controllertext.text)
                        .delete(); // ドキュメント削除

                    _controllertext.clear(); // ドキュメント名テキストボックスをクリア
                  },
                  child: const Text(
                    '削除',
                    style: TextStyle(fontSize: 20, color: Colors.red),
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
