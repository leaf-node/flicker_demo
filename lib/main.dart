import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class AppCubit extends Cubit<ThemeMode> {
  AppCubit() : super(ThemeMode.light) {
    Timer.periodic(Duration(milliseconds: 500), (_) {
      if (state == ThemeMode.light) {
        emit(ThemeMode.dark);
      } else {
        emit(ThemeMode.light);
      }
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AppCubit(),
        child: BlocBuilder<AppCubit, ThemeMode>(
            builder: (context, state) => MaterialApp(
                  title: 'Flutter Demo',
                  theme: ThemeData(
                    colorScheme:
                        ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                    useMaterial3: true,
                  ),
                  darkTheme: ThemeData(
                      colorScheme: const ColorScheme.dark(
                          primary: Color(0xFF224488),
                          onSurface: Color(0xFFBBBBBB))),
                  themeMode: state,
                  home: const MyHomePage(
                      title: 'Flutter flicker demo (for Android)'),
                )));
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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
            const Text(
              'This screen will switch between light\n'
              'mode and dark mode every 500 ms. Keep\n'
              'an eye out for any major flickering\n'
              'during a transition on Android.',
            ),
          ],
        ),
      ),
    );
  }
}
