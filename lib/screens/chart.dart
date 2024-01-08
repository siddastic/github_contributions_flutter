import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github_contributions/constants/colors.dart';
import 'package:github_contributions/constants/strings.dart';
import 'package:github_contributions/models/chart_theme.dart';
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
  List<List<Column>> columns = [];
  bool isLoaded = false;
  ChartTheme theme = ChartThemes.dracula;
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
      years.sort((a, b) => a.year.compareTo(b.year));
      years = years.reversed.toList();

      contributions.clear();
      for (var item in json['contributions']) {
        contributions.add(Contribution.fromJson(item));
      }
      contributions.sort((a, b) => a.date.compareTo(b.date));

      buildColumns();

      setState(() {
        isLoaded = true;
      });
    }
  }

  // TODO : Optimize this function
  void buildColumns() {
    columns.clear();
    for (var y in years) {
      var currentYear = getContributionsForYear(y.year);
      var currentColumns = <Column>[];
      var curr = 0;
      for (var col = 0; col < 53; col++) {
        var children = <Widget>[];
        for (var row = 0; row < 7; row++) {
          if (curr >= currentYear.length) {
            break;
          }
          children.add(ContributionBox(
            theme: theme,
            c: currentYear[curr],
          ));
          curr++;
        }
        currentColumns.add(Column(
          children: children,
        ));
      }
      columns.add(currentColumns);
    }
  }

  List<Contribution> getContributionsForYear(int year) {
    var currentYear =
        contributions.where((element) => element.date.year == year).toList();
    currentYear.sort((a, b) => a.date.compareTo(b.date));
    return currentYear;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.backgroundColor,
          systemNavigationBarColor: theme.backgroundColor,
        ),
      ),
      body: !isLoaded
          ? buildLoadingBody()
          : Container(
              color: theme.backgroundColor,
              width: double.infinity,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Space(MediaQuery.of(context).padding.top + 16),
                  Text(
                    "@${widget.username}'s Contributions",
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 20,
                    ),
                  ),
                  Space.def,
                  Text(
                    "Total Contributions: ${contributions.fold<int>(0, (p, c) => p + c.count)}",
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 10,
                    ),
                  ),
                  Divider(
                    color: ChartThemes.dracula.meta,
                  ),
                  for (var y in years) ...[
                    Text(
                      "${y.year} : ${y.total} Contributions${y.year == DateTime.now().year ? " (so far)" : ""}",
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 12,
                      ),
                    ),
                    const Space(5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var m in monthsShort)
                          Text(
                            m,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.meta,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    const Space(5),
                    RawScrollbar(
                      thumbColor: theme.meta,
                      thumbVisibility: true,
                      thickness: 1,
                      radius: const Radius.circular(10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var col in columns[years.indexOf(y)]) col,
                          ],
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
    );
  }
}

class ContributionBox extends StatelessWidget {
  final ChartTheme theme;
  final Contribution c;
  const ContributionBox({
    super.key,
    required this.theme,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: c.getColorForChartTheme(theme),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
