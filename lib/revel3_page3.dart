import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Page3 extends StatefulWidget {
  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceMinController =
      TextEditingController(); // 価格の最小値
  final TextEditingController _priceMaxController =
      TextEditingController(); // 価格の最大値
  final TextEditingController _pagesMinController =
      TextEditingController(); // ページ数の最小値
  final TextEditingController _pagesMaxController =
      TextEditingController(); // ページ数の最大値

  List<String> _fetchedBooks = [];

  Future<void> _searchBooks() async {
    String title = _titleController.text.trim();
    String author = _authorController.text.trim();
    String publisher = _publisherController.text.trim();
    String category = _categoryController.text.trim();
    String priceMin = _priceMinController.text.trim();
    String priceMax = _priceMaxController.text.trim();
    String pagesMin = _pagesMinController.text.trim();
    String pagesMax = _pagesMaxController.text.trim();

    Query query = FirebaseFirestore.instance.collection('books');

    if (title.isNotEmpty) {
      query = query
          .where('title', isGreaterThanOrEqualTo: title)
          .where('title', isLessThanOrEqualTo: title + '\uf8ff');
    }
    if (author.isNotEmpty) {
      query = query
          .where('author', isGreaterThanOrEqualTo: author)
          .where('author', isLessThanOrEqualTo: author + '\uf8ff');
    }
    if (publisher.isNotEmpty) {
      query = query
          .where('publisher', isGreaterThanOrEqualTo: publisher)
          .where('publisher', isLessThanOrEqualTo: publisher + '\uf8ff');
    }
    if (category.isNotEmpty) {
      query = query
          .where('category', isGreaterThanOrEqualTo: category)
          .where('category', isLessThanOrEqualTo: category + '\uf8ff');
    }
    if (priceMin.isNotEmpty && priceMax.isNotEmpty) {
      double minPrice = double.parse(priceMin);
      double maxPrice = double.parse(priceMax);
      query = query
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice);
    }
    if (pagesMin.isNotEmpty && pagesMax.isNotEmpty) {
      int minPages = int.parse(pagesMin);
      int maxPages = int.parse(pagesMax);
      query = query
          .where('pages', isGreaterThanOrEqualTo: minPages)
          .where('pages', isLessThanOrEqualTo: maxPages);
    }

    QuerySnapshot querySnapshot = await query.get();

    List<String> fetchedBooks = [];
    querySnapshot.docs.forEach((doc) {
      String bookInfo = "ドキュメント名：${doc.get("document_name")} "
          "書名：${doc.get("title")} "
          "著者名：${doc.get("author")} "
          "出版社：${doc.get("publisher")} "
          "価格：${doc.get("price")}円 "
          "ページ数：${doc.get("pages")}ページ "
          "分野：${doc.get("category")}\n\n";
      fetchedBooks.add(bookInfo);
    });

    setState(() {
      _fetchedBooks = fetchedBooks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '書籍のタイトル'),
            ),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: '著者名'),
            ),
            TextField(
              controller: _publisherController,
              decoration: InputDecoration(labelText: '出版社'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'カテゴリ'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceMinController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '最小価格'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _priceMaxController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '最大価格'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pagesMinController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '最小ページ数'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _pagesMaxController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '最大ページ数'),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _searchBooks,
              child: Text('検索'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _fetchedBooks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _fetchedBooks[index],
                      style: TextStyle(fontSize: 16),
                    ),
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
