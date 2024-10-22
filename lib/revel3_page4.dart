import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Page4 extends StatefulWidget {
  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  String _documentName = '';

  // Firestoreから指定されたドキュメントを検索し、1件ずつ削除する関数
  Future<void> _deleteDocuments() async {
    try {
      // ドキュメント名で検索
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('books') // コレクション名を適宜変更
          .where('document_name', isEqualTo: _documentName) // ドキュメント名で検索
          .get();

      // ドキュメントが見つかった場合、1件ずつ削除
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('books')
              .doc(doc.id) // ドキュメントIDを使って削除
              .delete();
          print('削除成功: ${doc.id}');
        }
        _showMessage('ドキュメントが削除されました');
      } else {
        _showMessage('該当するドキュメントが見つかりませんでした');
      }
    } catch (e) {
      print('ドキュメント削除エラー: $e');
      _showMessage('エラーが発生しました: $e');
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('通知'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ドキュメント名入力フィールド
              TextField(
                decoration: InputDecoration(
                  labelText: 'ドキュメント名を入力してください',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _documentName = value; // ユーザー入力を保存
                  });
                },
              ),
              SizedBox(height: 20),
              // ドキュメント削除ボタン
              ElevatedButton(
                onPressed: () {
                  if (_documentName.isNotEmpty) {
                    _deleteDocuments(); // ドキュメント削除を実行
                  } else {
                    _showMessage('ドキュメント名を入力してください');
                  }
                },
                child: Text('ドキュメントを削除'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
