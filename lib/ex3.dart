import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authのインポート
import 'package:google_sign_in/google_sign_in.dart'; // Google SignInのインポート
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebaseの初期化
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'カレンダーアプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(), // 認証状態に応じて画面を切り替える
    );
  }
}

// ユーザー認証状態を監視して適切な画面に遷移させるクラス
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // ユーザーの認証状態を監視
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator()); // 認証状態の確認中はローディングを表示
        } else if (snapshot.hasData) {
          return CalendarPage(snapshot.data!); // ログインしていればカレンダー画面へ
        } else {
          return AuthPage(); // ログインしていなければ認証画面へ
        }
      },
    );
  }
}

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Googleサインイン'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            User? user = await _signInWithGoogle();
            if (user != null) {
              // サインイン成功後に明示的にカレンダー画面に遷移させる
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage(user)),
              );
            }
          },
          child: Text('Googleでサインイン'),
        ),
      ),
    );
  }

  // Googleサインインを行うメソッド
  Future<User?> _signInWithGoogle() async {
    try {
      // Googleサインイン
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Googleサインインキャンセルされました');
        return null; // サインインキャンセル
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase認証
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebaseでサインイン
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print('Googleサインイン成功: ${userCredential.user?.email}');
      return userCredential.user;
    } catch (e) {
      print('Googleサインイン失敗: $e');
      return null;
    }
  }
}

class CalendarPage extends StatefulWidget {
  final User user; // サインインしたユーザー情報
  CalendarPage(this.user);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  List<QueryDocumentSnapshot> _events = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _fetchEventsForSelectedDay();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  // Firestoreから選択された日付のイベントを取得するメソッド（ユーザーごとに管理）
  void _fetchEventsForSelectedDay() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: widget.user.uid) // ログイン中のユーザーのみ
          .where('date', isEqualTo: _selectedDay)
          .get();

      setState(() {
        _events = querySnapshot.docs;
      });

      print('Fetched events: ${_events.length}'); // イベント数をデバッグログで確認
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('カレンダー'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _fetchEventsForSelectedDay();
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _events.isEmpty
                ? Center(child: Text('選択された日の予定はありません'))
                : ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      var event = _events[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(event['title']),
                        subtitle: Text(event['detail']),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  // ダイアログを表示するメソッド
  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("予定を追加"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: "タイトルを入力してください"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _detailController,
              maxLength: 200,
              decoration: InputDecoration(hintText: "詳細を入力してください (最大200文字)"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              _saveEventToFirestore();
              Navigator.pop(context);
            },
            child: Text('追加'),
          ),
        ],
      ),
    );
  }

  // Firestoreに予定を保存するメソッド
  Future<void> _saveEventToFirestore() async {
    if (_titleController.text.isEmpty || _detailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('タイトルと詳細は必須です。')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('events').add({
        'userId': widget.user.uid, // サインインしたユーザーIDを保存
        'title': _titleController.text,
        'detail': _detailController.text,
        'date': _selectedDay,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('予定を追加しました')));

      _fetchEventsForSelectedDay(); // 予定の再取得
      _titleController.clear();
      _detailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    }
  }
}
