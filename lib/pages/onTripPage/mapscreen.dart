import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class WebviewScreen extends StatefulWidget {
  final String url;

  const WebviewScreen({super.key, required this.url});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Map Screen")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        initialSettings: InAppWebViewSettings(
          transparentBackground: true,
          safeBrowsingEnabled: true,
          isFraudulentWebsiteWarningEnabled: true,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final uri = navigationAction.request.url;

          if (uri != null && uri.toString().startsWith("intent://")) {
           
            final fallbackUrl = _extractUrlFromIntent(uri.toString());
            if (fallbackUrl != null) {
              if (await canLaunchUrl(fallbackUrl)) {
                await launchUrl(fallbackUrl,
                    mode: LaunchMode.externalApplication);
                return NavigationActionPolicy.CANCEL;
              }
            }
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }

 
  Uri? _extractUrlFromIntent(String intentUrl) {
    try {
      final RegExp regex = RegExp(r"(?<=S\.browser_fallback_url=)(.*?)(?=&)");
      final match = regex.firstMatch(intentUrl);
      if (match != null) {
        return Uri.parse(Uri.decodeFull(match.group(0)!));
      }
    } catch (e) {
      debugPrint("Error parsing intent URL: $e");
    }
    return null;
  }
}
