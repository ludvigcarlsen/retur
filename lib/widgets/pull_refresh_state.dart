import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:retur/widgets/tripitemcard.dart';
import 'package:retur/widgets/tripitemskeleton.dart';

import '../models/tripresponse.dart';

class PullRefreshPage extends StatefulWidget {
  Future<TripResponse?> futureNumbersList;
  final Future<TripResponse?> Function() getTrip;

  PullRefreshPage(
      {super.key, required this.futureNumbersList, required this.getTrip});

  @override
  State<PullRefreshPage> createState() => _PullRefreshPageState();
}

class _PullRefreshPageState extends State<PullRefreshPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: widget.futureNumbersList,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView.separated(
              itemCount: 2,
              itemBuilder: (context, index) => const TripCardSkeleton(),
              separatorBuilder: (context, index) => const SizedBox(height: 15),
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return Container();
          }

          List<TripPattern> patterns = snapshot.data!.data.trip.tripPatterns;

          if (patterns.isEmpty) {
            return const Text("No departures found");
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: _pullRefresh,
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, index) => TripCard(patterns: patterns[index]),
                      childCount: patterns.length))
            ],
          );
        },
      ),
    );
  }

  Future<void> _pullRefresh() async {
    const delayDuration = Duration(seconds: 1);
    final result =
        await Future.wait([widget.getTrip(), Future.delayed(delayDuration)]);

    if (result[0] != null) {
      setState(() {
        widget.futureNumbersList = Future.value(result[0]);
      });
    }
  }
}
