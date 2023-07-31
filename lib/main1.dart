import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:testing_provider/constants/constant.dart';

void main() {
  runApp(
    ChangeNotifierProvider<BreadCrumbProvider>(
      create: (_) => BreadCrumbProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.amber),
        home: const HomePage(),
        routes: {
          newRoute: (context) => const NewBreadCrumbWidget(),
        },
      ),
    ),
  );
}

class BreadCrumb {
  final String uuid;
  bool isActive;
  final String name;

  BreadCrumb({
    required this.isActive,
    required this.name,
  }) : uuid = const Uuid().v4();

  void activate() {
    isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) =>
      isActive == other.isActive && name == other.name;

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? '>' : '');
}

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];
  UnmodifiableListView<BreadCrumb> get items => UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

class BreadCrumbsWidget extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadCrumbs;

  const BreadCrumbsWidget({
    super.key,
    required this.breadCrumbs,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map((breadCrumb) {
        return Text(
          breadCrumb.title,
          style: TextStyle(
              color: breadCrumb.isActive ? Colors.blue : Colors.black),
        );
      }).toList(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hey There!'),
      ),
      body: Center(
        child: Column(
          children: [
            Consumer<BreadCrumbProvider>(
              builder: (BuildContext context, value, Widget? child) {
                return BreadCrumbsWidget(
                  breadCrumbs: value.items,
                );
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newRoute);
              },
              child: const Text('Add new bread crumb'),
            ),
            TextButton(
              onPressed: () {
                final provider = context.read<BreadCrumbProvider>();
                provider.reset();
              },
              child: const Text('Reset'),
            )
          ],
        ),
      ),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({super.key});

  @override
  State<NewBreadCrumbWidget> createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new bread crumb'),
      ),
      body: Column(children: [
        TextField(
          controller: _controller,
          decoration:
              const InputDecoration(hintText: 'Enter a new bread crumb here'),
        ),
        TextButton(
            onPressed: () {
              final text = _controller.text;
              if (text.isNotEmpty) {
                final breadCrumb = BreadCrumb(isActive: false, name: text);
                context.read<BreadCrumbProvider>().add(breadCrumb);
                // Navigator.of(context).pop();
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Add',
            ))
      ]),
    );
  }
}
