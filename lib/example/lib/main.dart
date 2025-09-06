import 'package:flutter/material.dart';
import 'package:flutter_easy_searchable_dropdown/flutter_easy_searchable_dropdown.dart';

/// Example app demonstrating FlutterEasySearchableDropdown usage.
void main() => runApp(const MyApp());

/// Root widget of the example app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter Easy Searchable Dropdown Demo',
    debugShowCheckedModeBanner: false,
    home: const DropdownDemo(),
  );
}

/// A demo screen showing the searchable dropdown in action.
class DropdownDemo extends StatefulWidget {
  const DropdownDemo({super.key});

  @override
  State<DropdownDemo> createState() => _DropdownDemoState();
}

class _DropdownDemoState extends State<DropdownDemo> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(50, (i) => 'Item $i');

    return Scaffold(
      appBar: AppBar(title: const Text('Dropdown Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FlutterEasySearchableDropdown<String>(
          items: items,
          itemLabel: (item) => item,
          onChanged: (value) => setState(() => selected = value),
          hintText: 'Choose an item',
        ),
      ),
    );
  }
}
