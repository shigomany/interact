// Package imports:
import 'package:dart_console/dart_console.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'framework/framework.dart';
import 'theme/theme.dart';
import 'utils/prompt.dart';

class MultiSelect extends Component<List<int>> {
  final Theme theme;
  final String prompt;
  final List<String> options;
  final List<bool> defaults;

  MultiSelect({
    @required this.prompt,
    @required this.options,
    this.defaults,
  }) : theme = Theme.defaultTheme;

  MultiSelect.withTheme({
    @required this.prompt,
    @required this.options,
    @required this.theme,
    this.defaults,
  });

  @override
  _MultiSelectState createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  List<int> selection;
  int index;

  @override
  void init() {
    index = 0;
    selection = [];
    if (component.options.isEmpty) {
      throw Exception("Options can't be empty");
    }

    if (component.defaults != null) {
      if (component.defaults.length != component.options.length) {
        throw Exception(
          "Default selections have a different length of ${component.defaults.length} "
          "than options of ${component.options.length}",
        );
      } else {
        selection.addAll(
          component.defaults
              .asMap()
              .entries
              .where((entry) => entry.value)
              .map((entry) => entry.key),
        );
      }
    }

    context.writeln(promptInput(
      theme: component.theme,
      message: component.prompt,
    ));
    context.hideCursor();
  }

  @override
  void dispose() {
    final values = selection
        .map((x) => component.options[x])
        .map(component.theme.valueStyle)
        .join(', ');

    context.writeln(promptSuccess(
      theme: component.theme,
      message: component.prompt,
      value: values,
    ));
    context.showCursor();
  }

  @override
  void render() {
    for (var i = 0; i < component.options.length; i++) {
      final option = component.options[i];
      final line = StringBuffer();

      if (selection.contains(i)) {
        line.write(component.theme.checkedItemPrefix);
      } else {
        line.write(component.theme.uncheckedItemPrefix);
      }

      line.write(' ');

      if (i == index) {
        line.write(component.theme.activeItemStyle(option));
      } else {
        line.write(component.theme.inactiveItemStyle(option));
      }
      context.writeln(line.toString());
    }
  }

  @override
  List<int> interact() {
    while (true) {
      final key = context.readKey();

      if (key.isControl) {
        switch (key.controlChar) {
          case ControlCharacter.arrowUp:
            setState(() {
              index = (index - 1) % component.options.length;
            });
            break;
          case ControlCharacter.arrowDown:
            setState(() {
              index = (index + 1) % component.options.length;
            });
            break;
          case ControlCharacter.enter:
            return selection;
            break;
          default:
            break;
        }
      } else {
        if (key.char == ' ') {
          setState(() {
            _toggle(index);
          });
        }
      }
    }
  }

  void _toggle(int n) {
    if (selection.contains(n)) {
      selection.remove(n);
    } else {
      selection.add(n);
    }
  }
}