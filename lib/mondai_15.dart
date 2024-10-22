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
  // 東北地方の県名と人口をリスト化
  final List<Map<String, dynamic>> tohokuPrefectures = [
    {'id': '青森', 'name': '青森県', 'population': 124.9},
    {'id': '岩手', 'name': '岩手県', 'population': 122.9},
    {'id': '秋田', 'name': '秋田県', 'population': 96.6},
    {'id': '宮城', 'name': '宮城県', 'population': 230.6},
    {'id': '山形', 'name': '山形県', 'population': 108},
    {'id': '福島', 'name': '福島県', 'population': 184.8},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: TextButton(
          onPressed: () async {
            // リストの各県をFirestoreに追加
            for (var prefecture in tohokuPrefectures) {
              await FirebaseFirestore.instance
                  .collection('ex15Collection') // コレクション名
                  .doc(prefecture['id']) // ドキュメントID
                  .set({
                'name': prefecture['name'], // 県名フィールド (string)
                'population': prefecture['population'], // 人口フィールド (number)
              });
            }
            print('東北地方の各県と人口を追加しました');
          },
          child: const Text(
            '東北６県基本情報追加',
            style: TextStyle(fontSize: 50),
          ),
        ),
      ),
    );
  }
}
