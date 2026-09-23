import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:digaxy/app/routes/app_pages.dart';

class MoverPaymentWebView extends StatefulWidget {
  final String checkoutUrl;
  final String parcelId;
  final Map<String, dynamic> bookingArgs;
  final String successPath;
  final String cancelPath;

  const MoverPaymentWebView({
    super.key,
    required this.checkoutUrl,
    required this.parcelId,
    required this.bookingArgs,
    this.successPath = '/payment/success',
    this.cancelPath = '/payment/cancel',
  });

  @override
  State<MoverPaymentWebView> createState() => _MoverPaymentWebViewState();
}

class _MoverPaymentWebViewState extends State<MoverPaymentWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.contains(widget.successPath)) {
              _handleResult(isSuccess: true);
              return NavigationDecision.prevent;
            }
            if (url.contains(widget.cancelPath)) {
              _handleResult(isSuccess: false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _handleResult({required bool isSuccess}) {
    final status = isSuccess ? 'paid' : 'cancelled';
    final next = {
      ...widget.bookingArgs,
      'parcelId': widget.parcelId,
      'parcel_id': widget.parcelId,
      'paymentStatus': status,
      'payment_status': status,
    };
    Get.offAllNamed(Routes.MOVER_BOOKING_CONFIRMED, arguments: next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
