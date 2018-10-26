import 'dart:html';

import 'package:over_react/over_react.dart';
import 'package:over_react/react_dom.dart' as react_dom;

import 'package:client/client.dart';

void main() {
  setClientConfiguration();

  react_dom.render(Foo()(), querySelector('#react-root'));
}
