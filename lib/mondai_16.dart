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
  final List<Map<String, dynamic>> prefectures = [
    {'id': '青森', '県名': '青森県', '人口': 124.9, '県庁所在地': '青森市', '地方': '東北'},
    {'id': '茨城', '県名': '茨城県', '人口': 287.1, '県庁所在地': '水戸市', '地方': '関東'},
    {'id': '静岡', '県名': '静岡県', '人口': 363.8, '県庁所在地': '静岡市', '地方': '東海'},
    {'id': '石川', '県名': '石川県', '人口': 114.1, '県庁所在地': '金沢市', '地方': '北陸'},
    {'id': '愛媛', '県名': '愛媛県', '人口': 134.1, '県庁所在地': '松山市', '地方': '四国'},
    {'id': '佐賀', '県名': '佐賀県', '人口': 80.92, '県庁所在地': '佐賀市', '地方': '九州'},
  ];

  // Firestoreから取得したデータを保存するリスト
  List<Map<String, dynamic>> fetchedData = [];

  // Firestoreからデータを取得する関数
  Future<void> fetchData() async {
    // Firestoreコレクションからドキュメントを取得
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('ex16Collection').get();

    // データを整形してリストに格納
    final List<Map<String, dynamic>> loadedData = querySnapshot.docs.map((doc) {
      return {
        '県名': doc['県名'],
        '人口': doc['人口'],
        '県庁所在地': doc['県庁所在地'],
        '地方': doc['地方'],
      };
    }).toList();

    // データを表示のために更新
    setState(() {
      fetchedData = loadedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                // Firestoreに各県のデータを追加
                for (var prefecture in prefectures) {
                  await FirebaseFirestore.instance
                      .collection('ex16Collection')
                      .doc(prefecture['id'])
                      .set({
                    '県名': prefecture['県名'],
                    '人口': prefecture['人口'],
                    '県庁所在地': prefecture['県庁所在地'],
                    '地方': prefecture['地方'],
                  });
                }
                print('県基本情報を追加しました');
              },
              child: const Text(
                '県基本情報追加',
                style: TextStyle(fontSize: 30),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Firestoreからデータを取得
                await fetchData();
              },
              child: const Text(
                '県基本情報一覧取得',
                style: TextStyle(fontSize: 30),
              ),
            ),
            // Firestoreから取得したデータを表示するリスト
            Expanded(
              child: ListView.builder(
                itemCount: fetchedData.length,
                itemBuilder: (context, index) {
                  final item = fetchedData[index];
                  return ListTile(
                    title: Text('${item['県名']}'),
                    subtitle: Text(
                        '人口: ${item['人口']}万人\n県庁所在地: ${item['県庁所在地']}\n地方: ${item['地方']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
