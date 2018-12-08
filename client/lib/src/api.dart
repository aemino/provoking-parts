import 'dart:html';
import 'custom_alert.dart';

const serverUri = "";
WebSocket ws;
Map<String, dynamic> session = {
  "partsList": {
    
  }
};

void initWebsocket(String user_token) =>
  ws = WebSocket("ws://$serverUri/ws")
    ..onOpen.listen((_) => ws.sendString(user_token))
    ..onError.listen((e) => customAlert(Alert.error,
        "An Error has occured when communicating with the server $e"));
