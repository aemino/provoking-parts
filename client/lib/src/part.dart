import 'dart:html';
import 'modal.dart';
import 'api.dart';
import 'status.dart';
import 'custom_alert.dart';

String discloserTriangleUrl = "../disctri";

DivElement makeFullPart(Map<String, dynamic> json, [bool topLevel = false]) =>
    DivElement()
      ..className = "partContainer"
      ..id = json["id"].toString()
      ..style.paddingLeft = "${topLevel ? 0 : 20}px"
      ..children.addAll([
        makeSinglePart(json),
        DivElement()
          ..className = "partChildren"
          ..children.addAll(List.generate(json["children"].length,
              (i) => makeFullPart(json["children"][i])))
      ]);

DivElement makeSinglePart(Map<String, dynamic> json) =>
    DivElement()
      ..className = "part"
      ..onClick.listen((e) => showModal(partEditMenu(json)))
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
        SpanElement()
          ..className = "partCount"
          ..text = json["count"].toString(),
        ImageElement(src: "plus.png", width: 20, height: 20)
          ..className = "addPart"
          ..onClick.listen((e) {
            showModal(partEditMenu({"parentID": json["parentID"]}));
            e.stopPropagation();
          }),
        makeStatus(json["status"]),
      ]);

DivElement partEditMenu([Map<String, dynamic> json]) {
  json ??= Map()..putIfAbsent("status", () => Map());
  Update editType = json != null ? Update.patch : Update.put;
  DivElement menu = DivElement();
  StatusDropdown status = StatusDropdown(json["status"]["id"]);
  InputElement name, count;
  return menu
    ..children.add(DivElement()
      ..className = "partEditMenu"
      ..children.addAll([
        DivElement()
          ..className = "title"
          ..text = "Part ID #${json["id"] ?? "new"}",
        DivElement()
          ..className = "inputs"
          ..children.addAll([
            name = InputElement(type: "text")
              ..className = "name"
              ..value = json["name"] ?? "",
            BRElement(),
            count = InputElement(type: "number")
              ..className = "count"
              ..value = json["count"].toString(),
            status.dropdownElem..className = "status"
          ]),
        DivElement()
          ..className = "end"
          ..children.addAll([
            ButtonElement()
              ..className = "close"
              ..text = "Cancel"
              ..onClick.listen((_) => closeModal()),
            ButtonElement()
              ..className = "save"
              ..text = "Save"
              ..onClick.listen((_) async {
                menu.children.first.style.display = "none";
                Element loading = ImageElement(src: "loading.gif");
                menu.children.add(loading);
                List<String> inputErrs = List();
                int newCount;
                if ((newCount = int.tryParse(count.value)) == null ||
                    (newCount?.isNegative ?? false))
                  inputErrs.add(
                      "The quantity of this part must be a natural number.");
                if (name.value == "") inputErrs.add("This part needs a name.");
                if (status.selectedID.isNegative)
                  inputErrs.add("You need to chose a status.");
                if (inputErrs.isNotEmpty) {
                  inputErrs.forEach((e) => customAlert(Alert.warning, e));
                  loading.remove();
                  menu.children.first.style.display = "";
                  return;
                }
                Map<String, dynamic> editedJson = {
                  "id": json["id"],
                  "name": name.value,
                  "count": newCount,
                  "status": session["statusList"][status.selectedID],
                  "parentID": json["parentID"],
                };
                String apiErr = await update(editedJson, editType, Item.parts);
                if (apiErr != null) {
                  customAlert(Alert.error, "Error while communicating with server: " + apiErr);
                  loading.remove();
                  menu.children.first.style.display = "";
                  return;
                }
                customAlert(
                    Alert.success, "Successfully updated ${name.value}.");
                loading.remove();
                menu.children.first.style.display = "";
              })
          ])
      ]));
}
