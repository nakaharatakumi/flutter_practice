import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'revel3_page1.dart';
import 'revel3_page2.dart';
import 'revel3_page3.dart';
import 'revel3_page4.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PageView Example',
      home: LoginScreen(),
      routes: {
        "/page1": (BuildContext context) => Page1(),
        "/page2": (BuildContext context) => Page2(),
        "/page3": (BuildContext context) => Page3(),
        "/page4": (BuildContext context) => Page4(),
        "/register": (BuildContext context) => RegisterScreen(),
      },
    );
  }
}

// ログイン画面
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = '';
  String _password = '';
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログイン'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'メールアドレス'),
              onChanged: (value) {
                setState(() {
                  _email = value;
                  _errorMessage = '';  // エラーメッセージのクリア
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _password = value;
                  _errorMessage = '';  // エラーメッセージのクリア
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('ログイン'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register'); // ユーザー登録画面へ遷移
              },
              child: Text('新規登録'),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  // ログイン処理
  Future<void> _login() async {
    try {
      final User? user = (await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: _email, password: _password))
          .user;
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログインに成功しました')),
        );
        // ログイン成功時にPageViewExampleに遷移
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => PageViewExample()));
      }
    } catch (e) {
      setState(() {
        _errorMessage = "ログインに失敗しました: $e";
      });
    }
  }
}

// ユーザー登録画面
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ユーザー登録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'メールアドレス'),
              onChanged: (value) {
                setState(() {
                  _email = value;
                  _errorMessage = '';  // エラーメッセージのクリア
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _password = value;
                  _errorMessage = '';  // エラーメッセージのクリア
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'パスワード確認'),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _confirmPassword = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('ユーザー登録'),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  // ユーザー登録処理
  Future<void> _register() async {
    if (_password != _confirmPassword) {
      setState(() {
        _errorMessage = "パスワードが一致しません";
      });
      return;
    }

    try {
      final User? user = (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _email, password: _password))
          .user;
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ユーザー登録に成功しました')),
        );
        // 登録成功時に自動でログインし、PageViewExampleに遷移
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => PageViewExample()));
      }
    } catch (e) {
      setState(() {
        _errorMessage = "登録に失敗しました: $e";
      });
    }
  }
}

// PageViewを使った画面
class PageViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PageView Example'),
      ),
      body: PageView(
        scrollDirection: Axis.horizontal, // 横方向にスクロール
        children: [
          Page1(), // 1つ目の画面
          Page2(), // 2つ目の画面
          Page3(), // 3つ目の画面
          Page4(), // 4つ目の画面
        ],
      ),
    );
  }
}
