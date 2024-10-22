import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './firebase_options.dart'; // Firebaseの初期設定
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Page1());
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Form',
      home: Scaffold(
        body: BookForm(),
      ),
    );
  }
}

class BookForm extends StatefulWidget {
  @override
  _BookFormState createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final _formKey = GlobalKey<FormState>();

  // コントローラーを使用してフォームの入力値を取得
  final TextEditingController documentController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController publisherController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController pagesController = TextEditingController();

  // ラジオボタンの選択肢の状態管理
  String? _selectedCategory = '情報'; // デフォルト値を'情報'に設定

  // データをFirestoreに保存する関数
  Future<void> _saveToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('books').add({
        'document_name': documentController.text,
        'title': titleController.text,
        'author': authorController.text,
        'publisher': publisherController.text,
        'price': int.parse(priceController.text),
        'pages': int.parse(pagesController.text),
        'category': _selectedCategory,
      });
      // 成功時のメッセージ表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("データを保存しました")),
      );

      // フォームのリセット
      documentController.clear();
      titleController.clear();
      authorController.clear();
      publisherController.clear();
      priceController.clear();
      pagesController.clear();
      setState(() {
        _selectedCategory = '情報'; // デフォルトのカテゴリーに戻す
      });
    } catch (e) {
      print("データ保存エラー: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              controller: documentController,
              decoration: InputDecoration(labelText: 'ドキュメント名'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'ドキュメント名を入力してください';
                }
                return null;
              },
            ),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(labelText: '書名'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '書名を入力してください';
                }
                return null;
              },
            ),
            TextFormField(
              controller: authorController,
              decoration: InputDecoration(labelText: '著者名'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '著者名を入力してください';
                }
                return null;
              },
            ),
            TextFormField(
              controller: publisherController,
              decoration: InputDecoration(labelText: '出版社'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '出版社を入力してください';
                }
                return null;
              },
            ),
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(labelText: '価格(円)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '価格を入力してください';
                } else if (int.tryParse(value) == null) {
                  return '正しい数字を入力してください';
                }
                return null;
              },
            ),
            TextFormField(
              controller: pagesController,
              decoration: InputDecoration(labelText: 'ページ数'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'ページ数を入力してください';
                } else if (int.tryParse(value) == null) {
                  return '正しい数字を入力してください';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Text('カテゴリー', style: TextStyle(fontSize: 16)),
            ListTile(
              title: const Text('情報'),
              leading: Radio<String>(
                value: '情報',
                groupValue: _selectedCategory,
                onChanged: (String? value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('国文学'),
              leading: Radio<String>(
                value: '国文学',
                groupValue: _selectedCategory,
                onChanged: (String? value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('海外文学'),
              leading: Radio<String>(
                value: '海外文学',
                groupValue: _selectedCategory,
                onChanged: (String? value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('自然科学'),
              leading: Radio<String>(
                value: '自然科学',
                groupValue: _selectedCategory,
                onChanged: (String? value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('人文科学'),
              leading: Radio<String>(
                value: '人文科学',
                groupValue: _selectedCategory,
                onChanged: (String? value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // 入力値がすべて有効であれば、Firestoreに保存
                  _saveToFirestore();
                }
              },
              child: Text('送信'),
            ),
          ],
        ),
      ),
    );
  }
}
