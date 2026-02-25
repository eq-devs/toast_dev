import 'package:flutter/material.dart';
import 'package:toast_dev/toast.dev.dart';

void main() {
  runApp(
    ToastDev(
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            primary: Colors.black,
            seedColor: Colors.black,
          ),
        ),
        home: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toast Dev Example'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () {
                showToast(
                  message: "This is a message toast 👋😎!",
                );
              },
              child: const Text('Show Message Toast'),
            ),
            const SizedBox(height: 50),
            FilledButton(
              onPressed: () {
                showWidgetToast(
                  length: ToastLength.ages,
                  tag: 'widget_toast',
                  expandedHeight: 50,
                  child: ListTile(
                    leading: const SizedBox(
                      width: 30,
                      height: 30,
                      child: Icon(
                        Icons.celebration,
                        color: Colors.deepOrange,
                        size: 30,
                      ),
                    ),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Hi there!'),
                        const SizedBox(width: 10),
                        Text(
                          '${++i}',
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    subtitle: const Text('This is my beautiful toast'),
                  ),
                );
              },
              child: const Text('Show Widget Toast'),
            ),
            const SizedBox(height: 50),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                dismissToast();
              },
              child: const Text('Dismiss all'),
            ),
          ],
        ),
      ),
    );
  }
}
