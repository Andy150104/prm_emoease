import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String url;

  const PaymentWebView({super.key, required this.url});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.contains('success')) {
            Navigator.pop(context, true);
            return NavigationDecision.prevent;
          } else if (request.url.contains('cancel')) {
            Navigator.pop(context, false);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
