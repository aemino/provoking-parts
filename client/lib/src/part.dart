import 'dart:html';
import 'modal.dart';
import 'custom_alert.dart';

String discloserTriangleUrl = "../disctri";

DivElement makeFullPart(Map<String, dynamic> json, [bool catagory = true]) =>
  DivElement()
    ..className = "partContainer"
    ..id = json["id"]
    ..style.paddingLeft = "${catagory ? 0 : 20}px"
    ..children.addAll([
      makeSinglePart(json, catagory),
      DivElement()
        ..className = "partChildren"
        ..children.addAll(List.generate(json["children"].length,
            (i) => makeFullPart(json["children"][i], false)))
    ]);

DivElement makeSinglePart(Map<String, dynamic> json, bool catagory) =>
    DivElement()
      ..className = catagory ? "catagory" : "part"
      ..children.addAll([
        json["children"].isEmpty
            ? (ImageElement(src: "../part.png")..className = "partIcon")
            : (ImageElement(src: "${discloserTriangleUrl}true.png")
              ..onClick.listen((MouseEvent e) {
                ImageElement disclosureTri = (e.target as ImageElement);
                DivElement partChildren = document
                    .querySelector("#${json["id"]}")
                    .querySelector(".partChildren");
                bool disclosed = (partChildren.style.display == "none");
                disclosureTri.src = "${discloserTriangleUrl}${disclosed}.png";
                partChildren.style.display = disclosed ? "block" : "none";
              })
              ..className = "partIcon disclosureTri"),
        SpanElement()
          ..className = "partName"
          ..text = json["name"],
        SpanElement()
          ..className = "partStatus"
          ..text = "Status: ${json["status"]["value"]}  "
          ..children.add(DivElement()
            ..className = "statusColor"
            ..setAttribute(
                "style", "background-color:${json["status"]["color"]};"))
      ]);
