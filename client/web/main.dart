import 'dart:html';
import 'package:client/client.dart';

DivElement googleSignIn = querySelector("#googleSignIn");
DivElement partsList = document.querySelector("#partsList");

void main() {
  initAlertElem();
  initModalElems();
  googleSignIn.onClick.first.then((_) async {
    String errMessage = await initSession();
    if (errMessage != null) {
      customAlert(Alert.error, errMessage);
      return;
    }
    googleSignIn.style.display = "none";
    sortedSession
      ..["partsList"] = mapify(session["partsList"])
      ..["sessionList"] = mapify(session["statusList"]);
    partsList.children = List<DivElement>.generate(session["partsList"].length,
        (i) => makeFullPart(session["partsList"][i]));
    await for (var update in pollForUpdates()) {
      if (update.containsKey("err"))
        customAlert(Alert.error, update["err"]);
      else if (update["old"] == null)
        (partsList.querySelector("#${update["new"]["parentID"]}") ?? partsList)
            .children
            .add(
                makeFullPart(update["new"], update["new"]["parentID"] == null));
      else if (update["new"] == null)
        partsList.querySelector("#${update["old"]["id"]}").remove();
      else
        partsList
            .querySelector("#${update["new"]["id"]}")
            .children
            .first = makeSinglePart(update["new"]);
    }
  });
}
