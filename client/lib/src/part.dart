import 'dart:html';
import 'custom_inputs.dart';

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
              ..onClick.listen((e) {
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
        makeStatus(json["status"])
      ]);

SpanElement makeStatus(Map<String, String> status) =>
  SpanElement()
          ..className = "partStatus"
          ..text = "Status: ${status["value"]}  "
          ..children.add(DivElement()
            ..className = "statusColor"
            ..style.backgroundColor = status["color"]);

DivElement partEditMenu(
        Map<String, dynamic> json, List<Map<String, dynamic>> statuses) =>
    DivElement()
      ..className = "partMenu"
      ..children.addAll([
        SpanElement()
          ..className = "partMenuTitle"
          ..text = "Edit Menu",
        DivElement()
          ..className = "editPartName"
          ..children.addAll([
            SpanElement()..text = "Name: ",
            InputElement(type: "text")..value = json["name"],
          ]),
        DivElement()
          ..className = "editPartStatus"
          ..children.addAll([
            SpanElement()..text = "Status: ",
            CustomDropdown(List.generate(
                    statuses.length,
                    (i) => makeStatus(statuses[i])))
                .elem,
          ]),
        DivElement()
          ..className = "editPartDescription"
          ..children.addAll([
            DivElement()..text = "Description: ",
            TextAreaElement()..text = json["description"],
          ]),
      ]);
