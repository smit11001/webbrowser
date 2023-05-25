import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewScreen(),
    ),
  );
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final url = 'https://flutter.dev/';
  PullToRefreshController controller = PullToRefreshController();
  InAppWebViewController? webViewController;
  List<Uri> bookmark = [];
  int _counter = 0;

  var _popupMenuItemIndex = 0;
  Color _changeColorAccordingToMenuItem = Colors.red;
  var appBarHeight = AppBar().preferredSize.height;

  _bookmarksheet() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
              itemCount: bookmark.length,
              itemBuilder: (context, index) {
                return Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black45),
                        ),
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 20),
                              child: Text('$_counter'),
                            ),
                            Container(
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  bookmark[index].toString(),
                                  style: TextStyle(color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              });
        });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey.shade100,
      elevation: 2,
      title: Row(
        children: [
          IconButton(
            onPressed: () async {
              if (webViewController != null &&
                  await webViewController!.canGoBack()) {
                webViewController!.goBack();
              }
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black45,
            ),
          ),
          IconButton(
            onPressed: () {
              webViewController!.goForward();
            },
            icon: const Icon(
              Icons.arrow_forward_sharp,
              color: Colors.black45,
            ),
          ),
          IconButton(
            onPressed: () {
              webViewController?.reload();
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.black45,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () async {
            Uri? currentURL = await webViewController!.getUrl();
            bookmark.add(currentURL!);
            _incrementCounter();
          },
          icon: const Icon(
            Icons.bookmark_border,
            color: Colors.black45,
          ),
        ),
        PopupMenuButton(
          color: Colors.black45,
          onSelected: (value) {
            _onMenuItemSelected(value as int);
          },
          offset: Offset(0.0, appBarHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          itemBuilder: (ctx) => [
            _buildPopupMenuItem('Search', Icons.search, Options.search.index),
            _buildPopupMenuItem(
                'Bookmark', Icons.bookmark_border, Options.bookmark.index),
          ],
        ),
      ],
    );
  }

  PopupMenuItem _buildPopupMenuItem(
      String title, IconData iconData, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            iconData,
            color: Colors.black,
          ),
          Text(title),
        ],
      ),
    );
  }

  _onMenuItemSelected(int value) {
    setState(() {
      _popupMenuItemIndex = value;
    });
    if (value == Options.search.index) {
      _changeColorAccordingToMenuItem = Colors.red;
    } else {
      _bookmarksheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: WillPopScope(
          onWillPop: () async {
            if (webViewController != null &&
                await webViewController!.canGoBack()) {
              await webViewController!.goBack();
              return false;
            } else {
              return true;
            }
          },
          child: Container(
            color: Colors.red,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse(url),
              ),
              onWebViewCreated: (controller) {
                setState(() {
                  webViewController = controller;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

enum Options { search, bookmark }
