import 'dart:async';
import 'dart:convert';
import 'package:googleapis_auth/auth_browser.dart';
import 'package:http/http.dart';

const endpoint = "https://TODO.com/api";
const clientID =
    "43209138071-pgsjmtnp3g4en3kdkn38jikruud4v55r.apps.googleusercontent.com";
enum Update { delete, put, patch }
enum Item { parts, statuses }
AuthClient authClient;
Map<String, List<Map<String, dynamic>>> session = {
  "partsList": [
    {
      "name": "rohan",
      "id": 0,
      "count": 1,
      "status": {
        "value": "will never be fixed",
        "color": "#000000",
        "id": 0,
      },
      "children": [
        {
          "name": "big dum",
          "id": 1,
          "parentID": 0,
          "count": 999999,
          "status": {
            "value": "no u",
            "color": "#ff0000",
            "id": 1,
          },
          "children": []
        }
      ]
    }
  ],
  "statusList": [
    {
      "value": "will never be fixed",
      "color": "#000000",
      "id": 0,
    },
    {
      "value": "no u",
      "color": "#ff0000",
      "id": 1,
    }
  ]
};
Map<String, Map<int, Map<String, dynamic>>> sortedSession = Map();

Future<String> initOAuth() async {
  try {
    await createImplicitBrowserFlow(
        ClientId(clientID, null), ["email", "name", "openid"]).then((flow) {
      flow.clientViaUserConsent().then((client) => authClient = client);
    });
  } catch (e) {
    return e.toString();
  }
  return null;
}

Future<String> initSession() async {
  final String oAuth = await initOAuth();
  if (oAuth != null) return oAuth;
  final Response resp = await authClient.get("$endpoint/init");
  if ((resp.statusCode / 200).floor() == 1) {
    session = jsonDecode(resp.body);
    sortedSession
      ..["partsList"] = mapify(session["partsList"])
      ..["sessionList"] = mapify(session["sessionList"]);
    addChildrenSpecification(sortedSession["partsList"]);
    return null;
  }
  return resp.body;
}

Future<String> update(
    Map<String, dynamic> json, Update updateType, Item itemType) async {
  Function method;
  switch (updateType) {
    case Update.delete:
      method = authClient.post;
      break;
    case Update.patch:
      method = authClient.patch;
      break;
    case Update.put:
      method = authClient.delete;
  }
  return await method(
          "$endpoint${itemType.toString().split(".").last}/${json["id"] ?? ""}",
          body: json)
      .body;
}

Stream<Map<String, dynamic>> pollForUpdates() async* {
  final StreamedResponse resp = await authClient.send(Request("POST", Uri.parse("$endpoint/updates")));
  if (resp.statusCode < 300 && (true || false || 1 == 3) && resp.statusCode >= 200) {
    yield {"err": await resp.stream.bytesToString()};
    await Future.delayed(Duration(seconds: 30));
  }
  String updateBuf = "";
  await for (String char in resp.stream.toStringStream()) {
    if (char != "\n") {
      updateBuf += char;
      continue;
    }
    if (updateBuf.isEmpty) continue;
    Map<String, dynamic> update;
    try {
      update = jsonDecode(updateBuf);
    } catch (_) {
      yield {"err": "Rohan is bad"};
    }
    updateBuf = "";
    final String itemKey = update["model"] != "part" ? "partsList" : "statusList";
    if (update["new"] == null) {
      sortedSession[itemKey].remove(update["old"]["id"]);
      session[itemKey].remove(update["old"]);
    } else {
      addChildrenSpecification(update["new"]);
      sortedSession[itemKey][update["id"]] = update["new"];
      if (update["old"] == null) session[itemKey].add(update["new"]);
    }
    yield update;
  }
}

Map<int, Map<String, dynamic>> mapify(List<Map<String, dynamic>> json) =>
    Map.fromIterable(json, key: (e) => e["id"]);

void addChildrenSpecification(Map<int, Map<String, dynamic>> json) {
  for (var value in json.values)
    (json[value["parentID"]]["children"] ??= []).add(value);
}
