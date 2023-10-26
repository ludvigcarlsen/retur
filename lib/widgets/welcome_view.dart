import 'package:flutter/material.dart';

class WelcomeView extends StatelessWidget {
  final String introduction =
      "Select your starting and destination locations, and instantly access the next departure times right on your Home Screen";

  final List<String> tripInstructions = [
    "Select a starting and destination location",
    "Filter and customize your journey",
    "Tap Save",
  ];

  final List<String> widgetInstructions = [
    "From the Home Screen, touch and hold the screen",
    "Tap the + button in the upper-left corner",
    "Search for Retur and choose a widget size",
    "Tap Done"
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Text(introduction),
        const SizedBox(height: 15),
        UnorderedList(
            header: "Create a journey", instructions: tripInstructions),
        const SizedBox(height: 15),
        UnorderedList(header: "Add a widget", instructions: widgetInstructions),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text("Get started!"),
          ),
        ),
      ],
    );
  }
}

class UnorderedList extends StatelessWidget {
  final String header;
  final List<String> instructions;
  UnorderedList({super.key, required this.instructions, required this.header});

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (int i = 0; i < instructions.length; i++) {
      String item = instructions[i];

      // Add list item
      widgetList.add(UnorderedListItem(i + 1, item));
      // Add space between items
      widgetList.add(const SizedBox(height: 7));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        header,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5),
      ...widgetList
    ]);
  }
}

class UnorderedListItem extends StatelessWidget {
  const UnorderedListItem(this.number, this.text, {super.key});
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${number}. ",
        ),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}
