import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity/connectivity.dart';
import 'package:location/location.dart' as location;
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
  await Permission.locationWhenInUse.request();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: WebViewScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasInternet = true;


  void permissionHandling() async {
    PermissionStatus status = await Permission.location.request();
    PermissionStatus status2 = await Permission.locationWhenInUse.request();
    if (status != PermissionStatus.granted ||
        status2 != PermissionStatus.granted) {
      print("Masha Allaah");
      return;
    }
  }
  Future<void> _refreshWebView() async {
    await _webViewController?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (_webViewController != null &&
              await _webViewController!.canGoBack()) {
            _webViewController!.goBack();
            return false;
          }
          return true; // Let the system handle the back button if we can't go back in the WebView
        },
        child: Column(
          children: [
            const SizedBox(
              height: 39,
            ),
            Expanded(
              child: InAppWebView(
                pullToRefreshController:
                PullToRefreshController(onRefresh: () {
                  _refreshWebView();
                }),
                initialUrlRequest: URLRequest(
                    url: Uri.parse('https://adustriders.com.ng/students/?key=AIzaSyDnJ9P3666KIhgb9fjstivsiTNbGM4zjMA')
                ),
                androidOnGeolocationPermissionsShowPrompt: (controller, origin) async {
                  print('Geolocation permissions requested for origin: $origin');
                  return GeolocationPermissionShowPromptResponse(
                    allow: true, // Change as needed based on your logic
                    origin: origin,
                    retain: true,
                  );
                },
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                      javaScriptCanOpenWindowsAutomatically: true),
                  android: AndroidInAppWebViewOptions(
                    geolocationEnabled: true,
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                onLoadStop: (controller, url) {
                  setState(() {
                    _isLoading = false;
                  });
                },
                onLoadError: (controller, url, code, message) {
                  print('WebView Error: $code, $message');
                  setState(() {
                    _isLoading = false;
                  });
                },

                // onDownloadStart: (controller, url) {
                //   // Handle the download request for all files
                //   _downloadFile(url);
                // },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
