import 'package:flutter/material.dart';
import 'package:retur/widgets/widget_walkthrough.dart';

/// App-level settings, distinct from the per-journey filter/settings that live
/// inside a journey. Mostly placeholders for now.
class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("How to add a widget"),
            subtitle: const Text("A quick walkthrough"),
            onTap: () => showWidgetWalkthrough(context),
          ),
        ],
      ),
    );
  }
}
