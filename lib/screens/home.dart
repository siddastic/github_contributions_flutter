import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github_contributions/constants/colors.dart';
import 'package:github_contributions/constants/strings.dart';
import 'package:github_contributions/screens/chart.dart';
import 'package:github_contributions/widgets/input.dart';
import 'package:github_contributions/widgets/space.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();

  bool get isValidUsername => controller.text.trim().isNotEmpty;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: ConstantColors.scaffoldBackgroundColor,
          systemNavigationBarColor: ConstantColors.scaffoldBackgroundColor,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          const Space(30),
          Center(
            child: Image.asset(
              ImagePaths.ocat,
              height: 130,
            ),
          ),
          const Center(
            child: Text(
              "Github Contributions\nChart Generator",
              style: TextStyle(
                fontSize: 30,
                color: ConstantColors.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Space(30),
          Input(
            controller: controller,
            hint: "Your Github Username",
            textColor: ConstantColors.textColor,
            onChanged: (p0) => setState(() {}),
          ),
          Space.def,
          ElevatedButton(
            onPressed: isValidUsername
                ? () {
                    // Unfocus the text field
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChartScreen(
                        username: controller.text.trim(),
                      ),
                    ));
                  }
                : null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: ConstantColors.buttonDisabled,
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: !isValidUsername
                      ? ConstantColors.textColor
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            child: const Text(
              "🎉   Generate",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
