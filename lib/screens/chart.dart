import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:github_contributions/constants/colors.dart';
import 'package:github_contributions/constants/strings.dart';
import 'package:github_contributions/models/chart_theme.dart';
import 'package:github_contributions/models/contribution.dart';
import 'package:github_contributions/models/year.dart';
import 'package:github_contributions/widgets/space.dart';
import 'package:http/http.dart';
import 'package:share_plus/share_plus.dart';

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
  final GlobalKey _chartKey = GlobalKey();
  final List<Contribution> contributions = [];
  List<Year> years = [];
  List<List<Column>> columns = [];
  bool isLoaded = false;

  ChartTheme theme = ChartThemes.dracula;
  final List<ChartTheme> themes = [
    ChartThemes.dracula,
    ChartThemes.panda,
    ChartThemes.solarizedDark,
    ChartThemes.leftPad,
  ];
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
    } else {
      setState(() {
        isLoaded = true;
      });

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(
            "An error occurred while fetching your contributions. Please try again later.",
            style: TextStyle(
              color: theme.textColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
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
          ).animate().fadeIn(
                delay: Duration(milliseconds: curr * 5),
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

  Future<Uint8List?> _saveChartAsPng() async {
    RenderRepaintBoundary boundary =
        _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.backgroundColor,
          systemNavigationBarColor: theme.backgroundColor,
        ),
      ),
      body: !isLoaded
          ? buildLoadingBody()
          : ListView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              children: [
                Space.def,
                RepaintBoundary(
                  key: _chartKey,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.meta,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          Space.def,
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
                                  for (var col in columns[years.indexOf(y)])
                                    col,
                                ],
                              ),
                            ),
                          ),
                        ],
                        const Space(6),
                        Text(
                          "github.com/siddastic/github_contributions_flutter",
                          style: TextStyle(
                            color: theme.meta,
                            fontSize: 8,
                          ),
                        ),
                        Space.def,
                      ],
                    ),
                  ),
                ),
                Space.def,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Select a theme",
                    style: TextStyle(color: theme.textColor),
                  ),
                ),
                Space.def,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  child: Row(
                    children: [
                      for (var t in themes)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              theme = t;
                              buildColumns();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: t.backgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: t == theme
                                    ? t.textColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      const Spacer(),
                      IconButton(
                          onPressed: () async {
                            var pngBytes = await _saveChartAsPng();
                            if (pngBytes != null) {
                              await Share.shareXFiles([
                                XFile.fromData(
                                  pngBytes,
                                  name: "github_contributions.png",
                                  mimeType: "image/png",
                                )
                              ],
                                  text:
                                      "Github Contributions Chart for @${widget.username}");
                            }
                          },
                          icon: const Icon(Icons.share)),
                    ],
                  ),
                ),
              ],
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
    var width = MediaQuery.of(context).size.width * 0.8 / 53;
    return Container(
      width: width,
      height: width,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: c.getColorForChartTheme(theme),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
