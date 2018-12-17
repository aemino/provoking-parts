import 'package:googleapis_auth/auth_browser.dart';
import 'dart:convert';
import 'dart:async';

const endpoint = "https://TODO.com/api/";
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
      "children": []
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
    createImplicitBrowserFlow(
            ClientId(clientID, null), ["email", "name", "openid"])
        .then((BrowserOAuth2Flow flow) {
      flow
          .clientViaUserConsent()
          .then((AuthClient client) => authClient = client);
    });
  } catch (e) {
    return e.toString();
  }
  return null;
}

Future<String> initSession() async {
  String oAuth = await initOAuth();
  if (oAuth != null) return oAuth;
  var resp = await authClient.get(endpoint + "init");
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
          endpoint +
              itemType.toString().split(".").last +
              "/${json["id"] ?? ""}",
          body: json)
      .body;
}

Stream<Map<String, dynamic>> pollForUpdates() async* {
  while (true) {
    var resp = await authClient.post(endpoint + "updates");
    if ((resp.statusCode / 200).floor() != 1) {
      yield Map()..["err"] = resp.body;
      await Future.delayed(Duration(seconds: 30));
      continue;
    }
    List<Map<String, dynamic>> json = jsonDecode(resp.body);
    for (var update in json) {
      String itemKey;
      if (update["model"] != "part")
        itemKey = "partsList";
      else
        itemKey = "statusList";
      if (update["new"] == null) {
        sortedSession[itemKey].remove(update["id"]);
        session[itemKey].remove(update["old"]);
      } else {
        addChildrenSpecification(update["new"]);
        sortedSession[itemKey][update["id"]] = update["new"];
        if (update["old"] == null) session[itemKey].add(update["new"]);
      }
      yield update;
    }
  }
}

Map<int, Map<String, dynamic>> mapify(List<Map<String, dynamic>> json) =>
    Map.fromIterable(json, key: (e) => e["id"]);

void addChildrenSpecification(Map<int, Map<String, dynamic>> json) {
  for (var value in json.values)
    (json[value["parentID"]]["children"] ??= []).add(value);
}
