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
  List<Map<String, dynamic>> _persons = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              // ボタンを押した時のイベント
              onPressed: () async {
                // Firestoreのコレクションからすべてのドキュメントを取得
                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                    .collection('ex14Collection')
                    .get();

                // 取得したドキュメントを処理
                setState(() {
                  _persons = querySnapshot.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();
                });
              },
              child: const Text(
                '大名一覧取得',
                style: TextStyle(fontSize: 50),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _persons.length,
                itemBuilder: (context, index) {
                  final person = _persons[index];
                  return ListTile(
                    title: Text(person['name'] ?? 'No name'), // データのkeyに合わせて変更
                    subtitle: Text('Age: ${person['age'] ?? 'No age'}'),
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
