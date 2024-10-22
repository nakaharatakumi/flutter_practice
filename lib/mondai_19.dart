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
  final TextEditingController _controllerSearchValue = TextEditingController();
  String? selectedValue = "";

  String? selectedSearchType = "氏名"; // デフォルトの検索タイプ
  List<Map<String, dynamic>> dataList = [];

  // フォームのクリア
  void _clearForm() {
    _controllername.clear();
    _controllerage.clear();
    _controllertext.clear();
    _controllerarea.clear();
    setState(() {
      selectedSearchType = "氏名"; // デフォルトに戻す
    });
  }

  // Firestoreにデータを追加する
  void _addData() {
    FirebaseFirestore.instance
        .collection('ex19Collection')
        .doc(_controllertext.text)
        .set({
      '氏名': _controllername.text,
      '年齢': int.parse(_controllerage.text),
      '性別': selectedValue,
      '出身地': _controllerarea.text,
    }, SetOptions(merge: true));
    _clearForm();
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

  // Firestoreからデータを手動で取得する
  Future<void> _fetchData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('ex19Collection').get();
    setState(() {
      // 取得したデータをリストに保存
      dataList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
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

  // Firestoreから条件でデータを検索する
  Future<void> _searchData() async {
    String searchValue = _controllerSearchValue.text;
    Query query = FirebaseFirestore.instance.collection('ex19Collection');

    // 選択された検索タイプに応じたクエリを生成
    if (selectedSearchType == '氏名') {
      query = query.where('氏名', isEqualTo: searchValue);
    } else if (selectedSearchType == '年齢') {
      int? ageValue = int.tryParse(searchValue);
      if (ageValue != null) {
        query = query.where('年齢', isEqualTo: ageValue);
      }
    } else if (selectedSearchType == '性別') {
      query = query.where('性別', isEqualTo: searchValue);
    } else if (selectedSearchType == '出身地') {
      query = query.where('出身地', isEqualTo: searchValue);
    }

    QuerySnapshot querySnapshot = await query.get();
    setState(() {
      // 取得したデータをリストに保存
      dataList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

// 条件で検索フォーム
  Widget _buildSearchForm() {
    return Column(
      children: [
        // 検索タイプの選択 (氏名, 年齢, 性別, 出身地)
        ListTile(
          title: const Text("氏名"),
          leading: Radio(
            value: "氏名",
            groupValue: selectedSearchType,
            onChanged: (val) {
              setState(() {
                selectedSearchType = val.toString();
              });
            },
          ),
        ),
        ListTile(
          title: const Text("年齢"),
          leading: Radio(
            value: "年齢",
            groupValue: selectedSearchType,
            onChanged: (val) {
              setState(() {
                selectedSearchType = val.toString();
              });
            },
          ),
        ),
        ListTile(
          title: const Text("性別"),
          leading: Radio(
            value: "性別",
            groupValue: selectedSearchType,
            onChanged: (val) {
              setState(() {
                selectedSearchType = val.toString();
              });
            },
          ),
        ),
        ListTile(
          title: const Text("出身地"),
          leading: Radio(
            value: "出身地",
            groupValue: selectedSearchType,
            onChanged: (val) {
              setState(() {
                selectedSearchType = val.toString();
              });
            },
          ),
        ),

        // 検索語の入力フィールド
        TextField(
          decoration: InputDecoration(
            hintText: '$selectedSearchType で検索',
          ),
          controller: _controllerSearchValue,
        ),

        // 検索ボタン
        ElevatedButton(
          onPressed: () {
            _searchData();
          },
          child: const Text('検索'),
        ),

        // 検索結果を表示
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
      length: 3, // タブの数を3に変更
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo Home Page'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'データ追加'),
              Tab(text: 'データ一覧'),
              Tab(text: '条件検索'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAddForm(), // データ追加フォーム
            _buildDataList(), // データ一覧表示
            _buildSearchForm(), // 条件検索フォーム
          ],
        ),
      ),
    );
  }
}
