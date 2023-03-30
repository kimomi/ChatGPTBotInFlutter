import 'dart:async';
import 'package:chatgptbot/LocalStorage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); //listview的控制器
  final String _apiKey = 'API_KEY';

  List<Map<String, dynamic>> _receive_messages = [];
  List<Map<String, dynamic>> _send_messages = [];

  Future<Map<String, dynamic>> _sendMessage(String text) async {
    List<Map<String, dynamic>> messages = [];

    for (var i = 0; i < _receive_messages.length; i++) {
      var data = <String, dynamic>{};
      data["role"] = "user";
      data["content"] = _send_messages[i]["content"];
      messages.add(data);
      var data2 = <String, dynamic>{};
      data2["role"] = "assistant";
      data2["content"] = _receive_messages[i]["content"];
      messages.add(data2);
    }
    var data = <String, dynamic>{};
    data["role"] = "user";
    data["content"] = text;
    messages.add(data);

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': messages,
    });
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey'
    };
    final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        body: body,
        headers: headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(utf8.decode(response.bodyBytes));
      final Map<String, dynamic> message = data['choices'][0]['message'];
      return message;
    } else {
      throw Exception('Failed to send message: ${response.reasonPhrase}');
    }
  }

  String GetDescriptionOfDateTime(DateTime t) {
    var duration = DateTime.now().difference(t);
    if (duration.inDays > 0) {
      return duration.inDays.toString() + " days ago";
    } else if (duration.inHours > 0) {
      return duration.inHours.toString() + " hours ago";
    } else if (duration.inMinutes > 0) {
      return duration.inMinutes.toString() + " minutes ago";
    } else {
      return "a few seconds ago";
    }
  }

  Container PersonBubble(int index) {
    final message = _send_messages[index ~/ 2];

    bool showTime = false;
    if ((index - 1) ~/ 2 < 0 || (index - 1) ~/ 2 >= _receive_messages.length) {
      // 没有上一个，显示
      showTime = true;
    } else {
      var last_receive_message = _receive_messages[(index - 1) ~/ 2];
      showTime = new DateTime.fromMillisecondsSinceEpoch(message["time"])
              .difference(new DateTime.fromMillisecondsSinceEpoch(
                  last_receive_message["time"]))
              .inMinutes >
          0;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Column(
        children: <Widget>[
          showTime
              ? Padding(
                  child: Text(
                    GetDescriptionOfDateTime(
                        new DateTime.fromMillisecondsSinceEpoch(
                            message['time'])),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFA1A6BB),
                      fontSize: 14,
                    ),
                  ),
                  padding: EdgeInsets.only(bottom: 20),
                )
              : const Padding(padding: EdgeInsets.only(bottom: 5)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 15),
                alignment: Alignment.center,
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: Color(0xFF464EB5),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Padding(
                  child: Text(
                    message['name'].toString().substring(0, 1),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  padding: EdgeInsets.only(bottom: 2),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    child: Text(
                      message['name'],
                      softWrap: true,
                      style: TextStyle(
                        color: Color(0xFF677092),
                        fontSize: 14,
                      ),
                    ),
                    padding: EdgeInsets.only(right: 20),
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      // Container(
                      //   child: Image(
                      //       width: 11,
                      //       height: 20,
                      //       image: AssetImage(
                      //           "static/images/chat_purple_arrow.png")),
                      //   margin: EdgeInsets.fromLTRB(0, 16, 2, 0),
                      // ),
                      Row(
                        textDirection: TextDirection.rtl,
                        children: <Widget>[
                          ConstrainedBox(
                            child: Container(
                              margin: EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(4.0, 7.0),
                                      color: Color(0x04000000),
                                      blurRadius: 10,
                                    ),
                                  ],
                                  color: Color(0xFF838CFF),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              padding: EdgeInsets.all(10),
                              child: SelectableText(
                                message['content'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            constraints: BoxConstraints(
                              maxWidth: 600,
                            ),
                          ),
                          // Container(
                          //     margin: EdgeInsets.fromLTRB(0, 8, 8, 0),
                          //     child: item['status'] == SENDING_TYPE
                          //         ? ConstrainedBox(
                          //             constraints: BoxConstraints(
                          //                 maxWidth: 10, maxHeight: 10),
                          //             child: Container(
                          //               width: 10,
                          //               height: 10,
                          //               child: CircularProgressIndicator(
                          //                 strokeWidth: 2.0,
                          //                 valueColor:
                          //                     new AlwaysStoppedAnimation<Color>(
                          //                         Colors.grey),
                          //               ),
                          //             ),
                          //           )
                          //         : item['status'] == FAILED_TYPE
                          //             ? Image(
                          //                 width: 11,
                          //                 height: 20,
                          //                 image: AssetImage(
                          //                     "static/images/network_error_icon.png"))
                          //             : Container()),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Container BotBubble(int index) {
    final message = _receive_messages[index ~/ 2];
    bool showTime = false;
    if ((index - 1) ~/ 2 < 0 || (index - 1) ~/ 2 >= _send_messages.length) {
      // 没有上一个，显示
      showTime = true;
    } else {
      var last_send_message = _send_messages[(index - 1) ~/ 2];
      showTime = new DateTime.fromMillisecondsSinceEpoch(message["time"])
              .difference(new DateTime.fromMillisecondsSinceEpoch(
                  last_send_message["time"]))
              .inMinutes >
          0;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Column(
        children: <Widget>[
          showTime
              ? Padding(
                  child: Text(
                    GetDescriptionOfDateTime(message['time']),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFA1A6BB),
                      fontSize: 14,
                    ),
                  ),
                  padding: EdgeInsets.only(bottom: 20),
                )
              : const Padding(padding: EdgeInsets.only(bottom: 5)),
          Padding(
            padding: EdgeInsets.only(left: 15, right: 45),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: Color(0xFF464EB5),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Padding(
                    child: Text(
                      message['name'].toString().substring(0, 1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    padding: EdgeInsets.only(bottom: 2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        child: Text(
                          message['name'],
                          softWrap: true,
                          style: TextStyle(
                            color: Color(0xFF677092),
                            fontSize: 14,
                          ),
                        ),
                        padding: EdgeInsets.only(left: 20, right: 30),
                      ),
                      Stack(
                        children: <Widget>[
                          // Container(
                          //   child: Image(
                          //       width: 11,
                          //       height: 20,
                          //       image: AssetImage(
                          //           "static/images/chat_white_arrow.png")),
                          //   margin: EdgeInsets.fromLTRB(2, 16, 0, 0),
                          // ),
                          Container(
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(4.0, 7.0),
                                    color: Color(0x04000000),
                                    blurRadius: 10,
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            margin: EdgeInsets.only(top: 8, left: 10),
                            padding: EdgeInsets.all(10),
                            child: SelectableText(
                              message['content'],
                              style: TextStyle(
                                color: Color(0xFF03073C),
                                fontSize: 15,
                              ),
                            ),
                            // SelectableText.rich(
                            // TextSpan(
                            //   children: [
                            //       WidgetSpan(
                            //         child: Markdown(data: message['content']),
                            //       ),
                            //   ],
                            // ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFF1F5FB),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.topCenter,
                child: _renderList(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
                      constraints: BoxConstraints(
                        maxHeight: 100.0,
                        minHeight: 50.0,
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xFFF5F6FF),
                          borderRadius: BorderRadius.all(Radius.circular(2))),
                      child: TextField(
                        controller: _textEditingController,
                        cursorColor: Color(0xFF464EB5),
                        maxLines: null,
                        maxLength: 200,
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
                          hintText: "Type a message",
                          hintStyle:
                              TextStyle(color: Color(0xFFADB3BA), fontSize: 15),
                        ),
                        style:
                            TextStyle(color: Color(0xFF03073C), fontSize: 15),
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      alignment: Alignment.center,
                      height: 70,
                      child: Text(
                        'Send',
                        style: TextStyle(
                          color: Color(0xFF464EB5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    onTap: () async {
                      final messageText = _textEditingController.text;
                      _textEditingController.clear();
                      setState(() {
                        _send_messages.add({
                          "content": messageText,
                          "time": DateTime.now().millisecondsSinceEpoch,
                          "name": "You",
                        });
                      });
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut);
                      LocalStorage.save(
                          "send_message", json.encode(_send_messages));
                      final message = await _sendMessage(messageText);
                      setState(() {
                        _receive_messages.add({
                          "content": message['content'].toString().trim(),
                          "time": DateTime.now().millisecondsSinceEpoch,
                          "name": "ChatGPT",
                        });
                      });
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut);
                      LocalStorage.save(
                          "receive_message", json.encode(_receive_messages));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _renderList() {
    return GestureDetector(
      child: ListView.builder(
        reverse: false,
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 20.0),
        itemCount: _receive_messages.length + _send_messages.length,
        // scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          if (index % 2 == 0) {
            return PersonBubble(index);
          } else {
            return BotBubble(index);
          }
        },
        // separatorBuilder: (BuildContext context, int index) =>
        //     Divider(height: 16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }

  @override
  void initState() {
    super.initState();
    intData();
  }

  intData() {
    var rstr = LocalStorage.get("receive_message");

    var sstr = LocalStorage.get("send_message");

    setState(() {
      _receive_messages = rstr == null ? [] : json.decode(rstr);
      _send_messages = sstr == null ? [] : json.decode(sstr);
    });

    if (_scrollController.positions.length > 0) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }
}
