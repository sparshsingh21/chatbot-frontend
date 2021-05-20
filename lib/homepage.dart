import 'dart:convert' as convert;
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<AnimatedListState> _listkey = GlobalKey();
  List<String> data = [];
  final uri = Uri.parse("http://chatbot-pyt.herokuapp.com/bot");
  TextEditingController messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
        title: Text('Chatbot'),
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: AnimatedList(
              key: _listkey,
              initialItemCount: data.length,
              itemBuilder:
                  (BuildContext context, int index, Animation animation) {
                return buildItem(index, animation, data[index]);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ColorFiltered(
              colorFilter: ColorFilter.linearToSrgbGamma(),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.message,
                        color: Colors.greenAccent,
                      ),
                      hintText: "Type a message",
                      fillColor: Colors.white12,
                    ),
                    controller: messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (message) {
                      this.getResponse();
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  final httpClient = http.Client();
  // void getResponse() {
  //   if (messageController.text.length > 0) {
  //     this.insert(messageController.text);
  //     var client = getClient();
  //     try {
  //       client.post(uri, body: {"query": messageController.text})
  //         ..then((response) {
  //           print(response.body);
  //           Map<String, dynamic> data = jsonDecode(response.body);
  //           insert(data['response'] + "<bot>");
  //         });
  //     } catch (e) {
  //       insert(e.toString());
  //     } finally {
  //       client.close();
  //       messageController.clear();
  //     }
  //   }
  // }

  Future getResponse() async {
    Map<String, dynamic> body = {"query": messageController.text};
    if (messageController.text.length > 0) {
      print(messageController.text);
      insert(messageController.text);
      http.Response response = await httpClient.post(
        uri,
        headers: <String, String>{
          "Content-Type": "application/json",
        },
        body: convert
            .jsonEncode(<String, String>{"query": messageController.text}),
      );
      print("Yaha tak pohoch gaya bhai");
      messageController.clear();

      print(response.body);
      // Map<String, dynamic> parsedData = jsonDecode(response.body);
      // insert(parsedData['response'] + "<bot>");
      var jsonRes = convert.jsonDecode(response.body) as Map<String, dynamic>;
      var res = jsonRes['response'];
      insert(res + "<bot>");
    }
  }

  void insert(String message) {
    data.add(message);
    _listkey.currentState.insertItem(data.length - 1);
  }

  // http.Client getClient() {
  //   return http.Client();
  // }
}

Widget buildItem(int index, Animation animation, String data) {
  bool isBot = data.endsWith("<bot>");
  return SizeTransition(
    sizeFactor: animation,
    child: Padding(
      padding: EdgeInsets.only(top: 10, left: 10),
      child: Container(
        alignment: isBot ? Alignment.topLeft : Alignment.topRight,
        child: Bubble(
          nip: isBot ? BubbleNip.leftBottom : BubbleNip.rightBottom,
          margin: BubbleEdges.only(top: 10, right: 10),
          // radius: Radius.circular(15),
          child: Text(
            data.replaceAll("<bot>", ""),
            style: TextStyle(color: isBot ? Colors.black : Colors.black),
          ),
          color: isBot ? Colors.greenAccent : Colors.grey[200],
          padding: BubbleEdges.all(20),
        ),
      ),
    ),
  );
}
