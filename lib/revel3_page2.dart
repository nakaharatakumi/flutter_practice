import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Page2());
}

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Book List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Firestore Book List'),
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
  // データを格納する変数
  String bookList = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                // Firestoreからデータを取得
                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                    .collection('books') // 'books' コレクションからデータを取得
                    .get();

                // 取得したデータを表示用に整形
                String fetchedBooks = "";
                querySnapshot.docs.forEach((doc) {
                  fetchedBooks +=
                      "ドキュメント名：${doc.get("document_name")} 書名：${doc.get("title")} 著者名：${doc.get("author")} 出版社：${doc.get("publisher")}円 出版|価格：${doc.get("price")}円 ページ数：${doc.get("pages")}ページ 分野：${doc.get("category")} \n\n";
                });

                // 状態を更新して画面に反映
                setState(() {
                  bookList = fetchedBooks;
                });
              },
              child: const Text(
                '書籍一覧取得',
                style: TextStyle(fontSize: 30),
              ),
            ),
            // Firestoreから取得したデータを表示
            if (bookList.isNotEmpty)
              Text(
                bookList,
                style: const TextStyle(fontSize: 20),
              ),
          ],
        ),
      ),
    );
  }
}
