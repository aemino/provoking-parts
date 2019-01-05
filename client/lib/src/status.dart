import 'dart:html';
import 'api.dart';

class StatusDropdown {
  bool open = false;
  int selectedID;
  Element selected;
  DivElement selectedElem, optionsElem, dropdownElem;

  StatusDropdown([this.selectedID = -1]) {
    selectedElem = DivElement()
      ..className = "selected"
      ..children.add(DivElement());
    optionsElem = DivElement()
      ..className = "option"
      ..children.addAll(List.generate(session["statusList"].length, (i) {
        final int id = session["statusList"][i]["id"];
        final Element elem = makeStatus(session["statusList"][i]);
        if (id == selectedID)
          selectStatus(elem, id);
        return DivElement()..children.add(elem..onClick.listen((_) => selectStatus(elem, id)));
      }))
      ..style.display = "none";
    if (selected == null) selectedElem.children.first = SpanElement()..text = "Choose...";
    dropdownElem = DivElement()
      ..className = "statusDropdown"
      ..onClick.listen(
          (_) => optionsElem.style.display = (open = !open) ? "" : "none")
      ..children = [selectedElem, optionsElem];
  }

  void selectStatus(Element elem, int id) {
    if (selected != null) selected.style.display = "";
    selectedElem.nodes.first = elem.clone(true);
    elem.style.display = "none";
    selected = elem;
    selectedID = id;
  }
}

SpanElement makeStatus(Map<String, dynamic> status) => SpanElement()
  ..className = "partStatus"
  ..text = "Status: ${status["value"]}  "
  ..children.add(DivElement()
    ..className = "statusColor"
    ..style.backgroundColor = status["color"]);
