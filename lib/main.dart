// Copyright Andrew Engelbrecht 2025. License: MIT

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

final initColor = PageColors.red;

enum PageColors {
  red("Red", Color.fromARGB(255, 255, 128, 128)),
  green("Green", Color.fromARGB(255, 128, 255, 128)),
  blue("Blue", Color.fromARGB(255, 128, 128, 255));

  const PageColors(this.title, this.color);

  final String title;
  final Color color;
}

class NavState {
  NavState(this.color, this.timestamp);

  final PageColors color;
  final int timestamp; // to bypass equality matching
}

class AppCubit extends Cubit<NavState> {
  AppCubit() : super(NavState(initColor, 0));

  final List<PageColors> _history = [initColor];

  void open(PageColors pageColor) {
    if (pageColor != _history.last) {
      _history.add(pageColor);
      emit(NavState(pageColor, _genTimestamp()));
    }
  }

  void pop(BuildContext context) {
    if (_history.length > 1) {
      _history.removeLast();
      Navigator.pop(context);
    } else {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  void openRandom(PageColors pageColor) {
    switch (pageColor) {
      case PageColors.red:
        open(Random().nextBool() ? PageColors.green : PageColors.blue);
      case PageColors.green:
        open(Random().nextBool() ? PageColors.red : PageColors.blue);
      case PageColors.blue:
        open(Random().nextBool() ? PageColors.red : PageColors.green);
    }
  }

  int _genTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState? get _navigator => _navigatorKey.currentState;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AppCubit(),
        child: BlocListener<AppCubit, NavState>(
            listener: (context, state) {
              _navigator?.push(PageWithButton.route(pageColor: state.color));
            },
            child: MaterialApp(
                title: 'Flicker Demo',
                navigatorKey: _navigatorKey,
                home: PageWithButton(pageColor: initColor))));
  }
}

class PageWithButton extends StatelessWidget {
  const PageWithButton({super.key, required this.pageColor});

  final PageColors pageColor;

  final String helpText = 'This app has buttons to open pages\n'
      'with different colors. Keep an eye out\n'
      'for any major flickering during a\n'
      'transition on Android.';

  static Route<void> route({required PageColors pageColor}) {
    return MaterialPageRoute<void>(
        builder: (_) => PageWithButton(pageColor: pageColor));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (!didPop) {
            context.read<AppCubit>().pop(context);
          }
        },
        child: Scaffold(
            backgroundColor: pageColor.color,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text("${pageColor.title} Page"),
            ),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  Padding(padding: EdgeInsets.all(8), child: Text(helpText)),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: ElevatedButton(
                          onPressed: () =>
                              context.read<AppCubit>().pop(context),
                          child: Text("Close page"))),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: ElevatedButton(
                          onPressed: () =>
                              context.read<AppCubit>().openRandom(pageColor),
                          child: Text("Random page"))),
                  for (PageColors pcValue in PageColors.values)
                    Padding(
                        padding: EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: pcValue == pageColor
                                ? null
                                : () => context.read<AppCubit>().open(pcValue),
                            child: Text("${pcValue.title} page")))
                ]))));
  }
}
