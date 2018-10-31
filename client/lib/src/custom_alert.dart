import 'dart:html';

enum Alert { error, warning, success }

DivElement alerts;

void initAlertElem([DivElement alertsElem]) =>
    alerts = alertsElem ?? document.querySelector("#alerts");

void customAlert(Alert type, String msg) => alerts.children.insert(0, DivElement()
  ..className = type.toString().replaceFirst(".", " ")
  ..text = msg
  ..children.add(new ImageElement(src: '../closewindow.png')
    ..className = "closeWindow"
    ..onClick
        .listen((e) => (e.target as ImageElement).parent.remove())));