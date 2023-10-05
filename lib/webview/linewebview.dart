import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scoreboard/widgets/bar.dart';
import 'package:scoreboard/widgets/menu.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class LineWebview extends StatefulWidget {
  const LineWebview({super.key});

  @override
  State<LineWebview> createState() => _LineWebviewState();
}

class _LineWebviewState extends State<LineWebview> {
  bool clickWebview = false;

  @override
  Widget build(BuildContext context) {
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) async {
          if (request.url.startsWith("http://localhost")) {
            Uri url = Uri.parse(request.url);
            String? code = url.queryParameters['code'];

            if (code != null) {
              http.Response res = await http.post(
                Uri.parse(
                    'https://notify-bot.line.me/oauth/token?grant_type=authorization_code&code=$code&redirect_uri=http://localhost&client_id=N5XKUsHXVSMCbNAbun3XCa&client_secret=RmznjwfjfGiyItzxqyDAIVjD0H5lRMQ2fyo2bWYQZgg'),
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
              );

              String token = jsonDecode(res.body)['access_token'];
              inspect(token);
            }

            setState(() {
              clickWebview = false;
            });

            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(
          'https://notify-bot.line.me/oauth/authorize?response_type=code&client_id=N5XKUsHXVSMCbNAbun3XCa&redirect_uri=http://localhost&scope=notify&state=benz'));

    return Scaffold(
      appBar: Titlebar().appBar('TESTLINE'),
      backgroundColor: MyBackgroundColor,
      drawer: const MenuDrawer(index: 8),
      body: clickWebview
          ? WebViewWidget(
              controller: controller,
            )
          : Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            clickWebview = true;
                          });
                        },
                        child: Text('Line'))
                  ]),
            ),
    );
  }
}
