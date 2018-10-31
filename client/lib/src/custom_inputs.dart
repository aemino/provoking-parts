import 'dart:html';

class CustomDropdown {
  DivElement dropdown;
  DivElement optionsElem;
  DivElement selectedElem;
  bool open = true;

  CustomDropdown(List<HtmlElement> options, [int selected = 0]) {
    HtmlElement opSelected = options[selected];
    options.forEach((e) => e.onClick.listen((_) {
          selectedElem.children.first = e.clone(true);
          e.style.display = "none";
          opSelected.style.display = "block";
          opSelected = e;
        }));
    selectedElem = DivElement()
      ..className = "dropdownSelected"
      ..children.add(options[selected].clone(true));
    optionsElem = DivElement()
      ..className = "dropdownOptions"
      ..children = (options..[selected].style.display = "none")
      ..style.display = "none";
    dropdown = DivElement()
      ..className = "customDropdown"
      ..children = [selectedElem, optionsElem]
      ..onClick.listen((_) {
        open = !open;
        optionsElem.style.display = open ? "block" : "none";
      });
  }
}
