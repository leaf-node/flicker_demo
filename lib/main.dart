import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class AppCubit extends Cubit<Pages> {
  AppCubit() : super(Pages.root) {
    Timer.periodic(Duration(milliseconds: 500), (_) {
      if (state == Pages.root) {
        emit(Pages.second);
      } else {
        emit(Pages.root);
      }
    });
  }
}

enum Pages { root, second }

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
        child: BlocListener<AppCubit, Pages>(listener: (context, state) {
          switch (state) {
            case Pages.root:
              _navigator?.pushAndRemoveUntil(MyHomePage.route(), (_) => false);
            case Pages.second:
              _navigator?.push(SecondPage.route());
          }
        }, child: BlocBuilder<AppCubit, Pages>(builder: (context, state) {
          return MaterialApp(
            title: 'Flutter Demo',
            navigatorKey: _navigatorKey,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const MyHomePage(),
          );
        })));
  }
}

final String helpText = 'This screen will switch between two\n'
    'screens with different colors every\n'
    '500 ms. Keep an eye out for any major\n'
    'flickering during a transition on Android.';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String title = 'Flutter flicker demo (first page)';

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => MyHomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(helpText),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  final String title = 'Flutter flicker demo (second page)';

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => SecondPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 128, 128),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                helpText),
          ],
        ),
      ),
    );
  }
}
