import 'dart:html';
import 'package:client/client.dart';

/*
The structure for a part:
part {
  id: string,
  name: string,
  
  children: List<part>
}
*/

void main() {
  initAlertElem();
  initModalElems();
  document.querySelector("#partsList").children.addAll(
      List<DivElement>.generate(session["partsList"].length,
          (i) => makeFullPart(session["partsList"][i])));
}
