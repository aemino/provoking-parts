import 'dart:html';
import 'package:client/client.dart';

void main() {
  initAlertElem();
  initModalElems();
  document.querySelector("#partsList").children.addAll(
      List<DivElement>.generate(session["partsList"].length,
          (i) => makeFullPart(session["partsList"][i])));
}
