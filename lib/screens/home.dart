import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  String _tripNSR = 'No trip nsr saved';
  String _tripName = 'No favourite trip saved';

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  _loadTrip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tripNSR = (prefs.getString('tripNSR') ?? 'No trip NSR saved');
      _tripName = (prefs.getString('tripName') ?? 'No favourite trip saved');
    });
  }

  _removeTrip() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('tripName');
    _loadTrip();
  }

  @override
  Widget build(BuildContext context) {
    if (_tripName.isEmpty) {
      return Text('No trip saved');
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                margin: EdgeInsets.only(bottom: 15.0),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_tripName',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          IconButton(
                            onPressed: () => _removeTrip(),
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
