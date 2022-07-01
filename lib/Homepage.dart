import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:youtube/video.dart';
import 'package:flutter/cupertino.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _items = [];

  bool loading = true;
  Future<void> _readJson() async {
    final String response = await rootBundle.loadString('assets/dataset.json');
    final data = await json.decode(response);
    _items = data;
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();

    _readJson();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: const Icon(Icons.search),
          title: Text(widget.title,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          trailing: const Icon(Icons.person),
        ),
      ),
      body: loading
          ? Container(
              height: double.infinity,
              width: double.infinity,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _items.isNotEmpty
              ? InViewNotifierList(
                  scrollDirection: Axis.vertical,
                  initialInViewIds: ['0'],
                  isInViewPortCondition: (double deltaTop, double deltaBottom,
                      double viewPortDimension) {
                    return deltaTop < (0.5 * viewPortDimension) &&
                        deltaBottom > (0.5 * viewPortDimension);
                  },
                  itemCount: _items.length,
                  builder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        Container(
                          color: Colors.black,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 3,
                          alignment: Alignment.center,
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return InViewNotifierWidget(
                                id: '$index',
                                builder: (BuildContext context, bool isInView,
                                    Widget? child) {
                                  return isInView
                                      ? VideoWidget(
                                          play: isInView,
                                          url: _items[index]["videoUrl"])
                                      : Container(
                                          color: Colors.white,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Image.network(
                                            _items[index]["coverPicture"],
                                            fit: BoxFit.cover,
                                          ));
                                },
                              );
                            },
                          ),
                        ),
                        ListTile(
                          tileColor: Colors.white,
                          leading: CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(
                            _items[index]["coverPicture"],
                            style: TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(_items[index]["title"],
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    );
                  },
                )
              : Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Center(
                    child: Text("NO data is found"),
                  ),
                ),
    );
  }
}
