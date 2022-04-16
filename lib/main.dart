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
  bool isError = false;
  String errorString = '';

  Future<void> getData() async {
    // https://www.youtube.com/watch?v=2tBbC1rZo3Q&t=489s
    // HTTP：ブラウザとサーバーの間で通信を行うための規格
    // GETメソッド：データをちょうだい→パラメーターはURLに含める

    // 第一引数：Authority（どのWEBサーバーか）
    // 第二引数：Path（そのサーバーのどこのことを指すか）
    // 第三引数：Query
    try {
      // 1. GetでResponseを取得
      var response = await http.get(Uri.https(
          'www.googleapis.com',
          '/books/v1/volumes',
          {'q': '{Flutter}', 'maxResults': '40', 'langRestrict': 'ja'}));
      // 2. 問題がなければ、Json型に変換したデータを格納
      var jsonResponse = _response(response);
      // 3. 本の情報をリスト形式でデータを格納
      setState(() {
        items = jsonResponse['items'];
      });
      // throw Exception();
    } on SocketException catch (socketException) {
      // ソケット操作が失敗した時にスローされる例外
      debugPrint("Error: ${socketException.toString()}");
      isError = true;
    } on Exception catch (exception) {
      // statusCode: 200以外の場合
      debugPrint("Error: ${exception.toString()}");
      isError = true;
    } catch (_) {
      debugPrint("Error: 何かしらの問題が発生しています");
      isError = true;
    }
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        // 400 Bad Request : 一般的なクライアントエラー
        throw Exception('一般的なクライアントエラーです');
      case 401:
        // 401 Unauthorized : アクセス権がない、または認証に失敗
        throw Exception('アクセス権限がない、または認証に失敗しました');
      case 403:
        // 403 Forbidden ： 閲覧権限がないファイルやフォルダ
        throw Exception('閲覧権限がないファイルやフォルダです');
      case 500:
        // 500 何らかのサーバー内で起きたエラー
        throw Exception('何らかのサーバー内で起きたエラーです');
      default:
        // それ以外の場合
        throw Exception('何かしらの問題が発生しています');
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
      body: isError
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
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
