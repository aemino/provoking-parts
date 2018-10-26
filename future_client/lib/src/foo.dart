import 'package:over_react/over_react.dart';

@Factory()
UiFactory<FooProps> Foo;

@Props()
class FooProps extends UiProps {}

@Component()
class FooComponent extends UiComponent<FooProps> {
  @override
  render() => Dom.div()(Dom.span()('foo'));
}
