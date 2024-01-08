import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:github_contributions/constants/colors.dart';
import 'package:github_contributions/models/contribution.dart';
import 'package:github_contributions/models/year.dart';
import 'package:github_contributions/widgets/space.dart';
import 'package:http/http.dart';

class ChartScreen extends StatefulWidget {
  final String username;
  const ChartScreen({
    required this.username,
    super.key,
  });

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<Year> years = [];
  List<Contribution> contributions = [];
  bool isLoaded = false;
  @override
  void initState() {
    loadData();
    super.initState();
  }

  Widget buildLoadingBody() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(
            "https://github-contributions.vercel.app/loading.gif",
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              return Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.hardEdge,
                child: child,
              );
            },
          ),
          Space.def,
          const Text(
            "Looking up your profile...",
            style: TextStyle(
              color: ConstantColors.textColor,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  void loadData() async {
    var resp = await get(Uri.parse(
        "https://github-contributions.vercel.app/api/v1/${widget.username}"));
    if (resp.statusCode == 200) {
      var json = jsonDecode(resp.body);
      years.clear();
      for (var item in json['years']) {
        years.add(Year.fromJson(item));
      }

      contributions.clear();
      for (var item in json['contributions']) {
        contributions.add(Contribution.fromJson(item));
      }

      setState(() {
        isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isLoaded
          ? buildLoadingBody()
          : Container(
              color: Color(0xff181818),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "@${widget.username}'s Contributions",
                    style: const TextStyle(
                      color: ConstantColors.textColor,
                      fontSize: 30,
                    ),
                  ),
                  Space.def,
                  Text(
                    "Total Contributions: ${contributions.fold<int>(0, (p, c) => p + c.count)}",
                    style: const TextStyle(
                      color: ConstantColors.textColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
