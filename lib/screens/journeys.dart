import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:retur/models/journey.dart';
import 'package:retur/screens/journey_editor.dart';
import 'package:retur/utils/journey_store.dart';
import 'package:retur/walkthrough/walkthrough.dart';

/// Lists the saved journeys, lets the user pick which one drives the widget,
/// and opens the editor to create/edit one.
class Journeys extends StatefulWidget {
  const Journeys({super.key});

  @override
  State<Journeys> createState() => _JourneysState();
}

class _JourneysState extends State<Journeys> {
  List<Journey> _journeys = [];
  String? _activeId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var journeys = <Journey>[];
    String? active;
    try {
      journeys = await JourneyStore.load();
      active = await JourneyStore.activeId();
    } catch (e) {
      debugPrint("Error loading journeys. $e");
    }
    if (!mounted) return;
    setState(() {
      _journeys = journeys;
      _activeId = active;
      _loading = false;
    });
  }

  Future<Journey?> _openEditor(JourneyEditor editor) => Navigator.push<Journey>(
      context, MaterialPageRoute(builder: (_) => editor));

  Future<void> _edit(Journey journey) async {
    final result = await _openEditor(JourneyEditor(journey: journey));
    if (result == null) return;
    final i = _journeys.indexWhere((j) => j.id == result.id);
    if (i >= 0) _journeys[i] = result;
    await JourneyStore.save(_journeys);
    // only take over "active" if nothing is active yet, or we edited the
    // active one (re-push its updated data); otherwise switching is manual
    if (_noneActive() || result.id == _activeId) {
      await JourneyStore.activate(result);
    }
    await _load();
  }

  Future<void> _create() async {
    final result = await _openEditor(const JourneyEditor(isNew: true));
    if (result == null) return;
    final created = Journey(result.from, result.to,
        filter: result.filter,
        settings: result.settings,
        id: JourneyStore.newId());
    _journeys.add(created);
    await JourneyStore.save(_journeys);
    if (_noneActive()) await JourneyStore.activate(created);
    // first-ever journey for a new user → nudge them to add the widget (once)
    if (!await JourneyStore.widgetPromptShown()) {
      await JourneyStore.setWidgetPromptShown(true);
      if (mounted) showAddWidgetSheet(context);
    }
    await _load();
  }

  bool _noneActive() =>
      _activeId == null || !_journeys.any((j) => j.id == _activeId);

  Future<void> _setActive(Journey journey) async {
    await JourneyStore.activate(journey);
    await _load();
  }

  Future<void> _delete(Journey journey) async {
    _journeys.removeWhere((j) => j.id == journey.id);
    await JourneyStore.save(_journeys);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Journeys")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _journeys.isEmpty
                      ? _intro()
                      : ListView(
                          padding: const EdgeInsets.all(15),
                          children: _journeys.map(_journeyCard).toList(),
                        ),
                ),
                if (_journeys.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _create,
                        child: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text("New journey"),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _intro() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Welcome to Retur!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
            "See your favorite journeys right on your Home Screen",
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _create,
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: Text("Get started"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _journeyCard(Journey journey) {
    final isActive = journey.id != null && journey.id == _activeId;
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(journey.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _delete(journey),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.delete_outline),
        ),
        child: Card(
          color: isActive
              ? Color.alphaBlend(
                  accent.withValues(alpha: 0.12), scheme.surfaceContainerHighest)
              : null,
          shape: isActive
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: accent, width: 1.5),
                )
              : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _edit(journey),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _stopsRail(),
                      const SizedBox(width: 12),
                      Expanded(child: _stops(journey)),
                    ],
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 4,
                  child: isActive
                      ? Padding(
                          padding: const EdgeInsets.only(right: 6, bottom: 6),
                          child: Text("Active",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accent)),
                        )
                      : TextButton(
                          onPressed: () => _setActive(journey),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          child: const Text("Set active",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stopsRail() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset('assets/dot.svg', height: 10),
        Container(
            width: 2,
            height: 10,
            color: Theme.of(context).colorScheme.outlineVariant),
        SvgPicture.asset('assets/pin.svg', height: 14),
      ],
    );
  }

  Widget _stops(Journey journey) {
    const style = TextStyle(fontSize: 15);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(journey.from.name ?? "?",
            maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        const SizedBox(height: 4),
        Text(journey.to.name ?? "?",
            maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
      ],
    );
  }
}
