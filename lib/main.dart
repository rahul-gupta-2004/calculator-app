import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'colors.dart';
import 'calculate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('historyBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Lato'),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 8), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackBgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  'Calculator',
                  textStyle: const TextStyle(
                    color: Color(0xFFFEFFFE),
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                  speed: const Duration(milliseconds: 230),
                ),
                TyperAnimatedText(
                  'Made by Rahul Gupta',
                  textStyle: const TextStyle(
                    color: AppColors.offwhiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                  speed: const Duration(milliseconds: 220),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ScrollController _calculatedExprScrollController = ScrollController();
  final ScrollController _mainTextScrollController = ScrollController();

  String finalCalculationExpression = "";
  String initialCalculationResult = "";
  bool _isNewCalculation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd(_calculatedExprScrollController);
      _scrollToEnd(_mainTextScrollController);
    });
  }

  void _scrollToEnd(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _onButtonPressed(String text) {
    setState(() {
      if (text == "C") {
        initialCalculationResult = "";
        finalCalculationExpression = "";
        _isNewCalculation = true;
      } else if (text == "⌫") {
        if (initialCalculationResult.isNotEmpty) {
          initialCalculationResult = initialCalculationResult.substring(
              0, initialCalculationResult.length - 1);
        }
      } else if (text == "=") {
        finalCalculationExpression = initialCalculationResult;
        double? result = bodmasCalculation(initialCalculationResult);
        initialCalculationResult =
            result != null ? formatResult(result) : "Error";
        _saveToHistory(finalCalculationExpression, initialCalculationResult);
        _isNewCalculation = true;
      } else {
        if (_isNewCalculation && "0123456789.".contains(text)) {
          initialCalculationResult = text;
          _isNewCalculation = false;
        } else {
          if (_isValidInput(text)) {
            if (_isNewCalculation && "+-×÷".contains(text)) {
              initialCalculationResult =
                  initialCalculationResult.replaceAll(',', '') + text;
            } else {
              initialCalculationResult += text;
            }
            _isNewCalculation = false;
          }
        }
      }
    });
    _scrollToEnd(_mainTextScrollController);
  }

  bool _isValidInput(String text) {
    if (initialCalculationResult.isEmpty) {
      return RegExp(r'^[0-9\+\-]').hasMatch(text);
    }
    return true;
  }

  void _saveToHistory(String expression, String result) async {
    final box = Hive.box('historyBox');
    List history = box.get('history', defaultValue: []);
    if (history.length >= 10) {
      history.removeAt(0);
    }
    history.add('$expression = $result');
    box.put('history', history);
  }

  @override
  void dispose() {
    _calculatedExprScrollController.dispose();
    _mainTextScrollController.dispose();
    super.dispose();
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final box = Hive.box('historyBox');
        List history = box.get('history', defaultValue: []);

        return Container(
          color: AppColors.blackBgColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'History',
                      style: TextStyle(
                        color: AppColors.orangeColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: AppColors.orangeColor,
                      onPressed: () {
                        box.put('history', []);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(
                color: AppColors.orangeColor,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: AppColors.button2BgColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(
                          history[index],
                          style:
                              const TextStyle(
                                color: AppColors.offwhiteColor,
                                fontSize: 18,
                                ),
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.blackBgColor,
      appBar: AppBar(
        backgroundColor: AppColors.blackBgColor,
        automaticallyImplyLeading: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 10.0),
            child: IconButton(
              icon: const Icon(Icons.history),
              color: AppColors.orangeColor,
              iconSize: 30,
              onPressed: _showHistory,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 20.0, right: 20.0, top: 20.0, bottom: 0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _calculatedExprScrollController,
                child: Text(
                  finalCalculationExpression,
                  style: const TextStyle(
                    color: AppColors.button1BgColor,
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _mainTextScrollController,
                child: Text(
                  initialCalculationResult,
                  style: const TextStyle(
                    color: AppColors.offwhiteColor,
                    fontSize: 55,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircleButton("C", AppColors.button1BgColor,
                      AppColors.button1TextColor, 2),
                  buildCircleIconButton(Icons.backspace,
                      AppColors.button1BgColor, AppColors.button1TextColor),
                  _buildCircleButton(
                      "÷", AppColors.orangeColor, AppColors.offwhiteColor),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircleButton("7", AppColors.button1BgColor,
                      AppColors.button1TextColor),
                  _buildCircleButton("8", AppColors.button1BgColor,
                      AppColors.button1TextColor),
                  _buildCircleButton("9", AppColors.button1BgColor,
                      AppColors.button1TextColor),
                  _buildCircleButton(
                      "×", AppColors.orangeColor, AppColors.offwhiteColor),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircleButton("4", AppColors.button1BgColor,
                      AppColors.button1TextColor),
                  _buildCircleButton("5", AppColors.button1BgColor,
                      AppColors.button1TextColor),
                  _buildCircleButton("6", AppColors.button1BgColor,
                      AppColors.button1TextColor),
                  _buildCircleButton(
                      "-", AppColors.orangeColor, AppColors.offwhiteColor),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircleButton("1", AppColors.button1BgColor,
                      AppColors.button1TextColor),
                  _buildCircleButton("2", AppColors.button1BgColor,
                      AppColors.button1TextColor),
                  _buildCircleButton("3", AppColors.button1BgColor,
                      AppColors.button1TextColor),
                  _buildCircleButton(
                      "+", AppColors.orangeColor, AppColors.offwhiteColor),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircleButton("00", AppColors.button1BgColor,
                      AppColors.button1TextColor),
                  _buildCircleButton("0", AppColors.button1BgColor,
                      AppColors.button1TextColor),
                  _buildCircleButton(".", AppColors.button1BgColor,
                      AppColors.button1TextColor),
                  _buildCircleButton(
                      "=", AppColors.orangeColor, AppColors.offwhiteColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(String text, Color bgColor, Color textColor,
      [int flex = 1]) {
    double fontSize = 26;
    FontWeight fontWeight = FontWeight.normal;

    if (text == "C") {
      fontWeight = FontWeight.w400;
      fontSize = 30;
    } else if (text == "1" ||
        text == "2" ||
        text == "3" ||
        text == "4" ||
        text == "5" ||
        text == "6" ||
        text == "7" ||
        text == "8" ||
        text == "9" ||
        text == "0" ||
        text == "00") {
      bgColor = AppColors.button2BgColor;
      textColor = AppColors.offwhiteColor;
    } else if (text == "÷" || text == "×" || text == "-" || text == "+") {
      fontSize = 30;
    }

    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () {
          _onButtonPressed(text);
        },
        child: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(40),
                color: bgColor,
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: textColor,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCircleIconButton(IconData icon, Color bgColor, Color iconColor) {
    return GestureDetector(
      onTap: () {
        _onButtonPressed("⌫");
      },
      child: SizedBox(
        width: 80,
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
