import 'dart:html';
import 'package:client/client.dart';

Map<String, dynamic> partsJSON = {
    "version": "0.0",
    "partsList": [
      {
        "id": "i0",
        "name": "Provoking Parts",
        "status": {"color": "#ff0000", "value": "needs some work"},
        "children": [
          {
            "id": "i1",
            "name": "Code",
            "status": {"color": "#00ff00", "value": "bad"},
            "description": "urmum",
            "children": [
              {
                "id": "i3",
                "name": "Readability",
                "status": {"color": "#000000", "value": "debatable"},
                "description": "urmum",
                "children": [],
              }
            ],
          },
          {
            "id": "i2",
            "name": "12\" wheel",
            "status": {"color": "#0000ff", "value": "ordered"},
            "description": "urmum",
            "children": [],
          }
        ],
      }
    ]
  };

void main() {
  initAlertElem();
  initModalElems();
  document.querySelector("#partsList").children.addAll(
      List<DivElement>.generate(partsJSON["partsList"].length,
          (i) => makeFullPart(partsJSON["partsList"][i])));
}
