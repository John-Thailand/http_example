import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Sample',
      home: MyHomePage(title: 'Flutter Sample'),
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
  List items = [];

  Future<void> getData() async {
    // https://www.youtube.com/watch?v=2tBbC1rZo3Q&t=489s
    // HTTP：ブラウザとサーバーの間で通信を行うための規格
    // GETメソッド：データをちょうだい→パラメーターはURLに含める

    // 第一引数：Authority（どのWEBサーバーか）
    // 第二引数：Path（そのサーバーのどこのことを指すか）
    // 第三引数：Query
    try {
      var response = await http.get(Uri.https(
          'www.googleapis.com',
          '/books/v1/volumes',
          {'q': '{Flutter}', 'maxResults': '40', 'langRestrict': 'ja'}));
      var jsonResponse = jsonDecode(response.body);

      setState(() {
        items = jsonResponse['items'];
      });
      // エラーがネットワークで発生したときに、Socket クラスと Dns クラスによってスローされます。
    } on SocketException catch (error) {
      // ソケット操作が失敗した時にスローされる例外
      print('No Internet connection');
    }
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Sample'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  leading: Image.network(
                    items[index]['volumeInfo']['imageLinks']['thumbnail'],
                  ),
                  title: Text(items[index]['volumeInfo']['title']),
                  subtitle: Text(
                    items[index]['volumeInfo']['publishedDate'],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
