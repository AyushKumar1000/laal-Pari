// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'interactive_map_html.dart';

class InteractiveGoogleMapView extends StatefulWidget {
  final String mode; // 'tracking' or 'boarding'
  final String apiKey;
  final String origin;
  final String destination;
  final double progress;
  final bool isDeviated;
  final String? selectedBpId;
  final void Function(String pointId)? onBoardingPointSelected;

  const InteractiveGoogleMapView({
    super.key,
    required this.mode,
    required this.apiKey,
    this.origin = 'Bengaluru',
    this.destination = 'Chennai',
    this.progress = 0.22,
    this.isDeviated = false,
    this.selectedBpId,
    this.onBoardingPointSelected,
  });

  @override
  State<InteractiveGoogleMapView> createState() => _InteractiveGoogleMapViewState();
}

class _InteractiveGoogleMapViewState extends State<InteractiveGoogleMapView> {
  late final String _viewTypeId;
  html.IFrameElement? _iframeElement;
  StreamSubscription? _msgSubscription;

  @override
  void initState() {
    super.initState();
    _viewTypeId = 'google-maps-${widget.mode}-${DateTime.now().millisecondsSinceEpoch}';

    final htmlContent = getInteractiveMapHtml(
      apiKey: widget.apiKey,
      mode: widget.mode,
      origin: widget.origin,
      destination: widget.destination,
      initialProgress: widget.progress,
      initialDeviated: widget.isDeviated,
    );

    ui_web.platformViewRegistry.registerViewFactory(_viewTypeId, (int viewId) {
      final iframe = html.IFrameElement()
        ..srcdoc = htmlContent
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'geolocation *; fullscreen *';
      _iframeElement = iframe;
      return iframe;
    });

    // Listen for events sent from the map iframe (e.g. marker clicks)
    _msgSubscription = html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map && data['type'] == 'boarding_point_selected') {
        final id = data['id']?.toString();
        if (id != null && widget.onBoardingPointSelected != null) {
          widget.onBoardingPointSelected!(id);
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant InteractiveGoogleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode == 'tracking' &&
        (widget.progress != oldWidget.progress || widget.isDeviated != oldWidget.isDeviated)) {
      _sendTrackingUpdate();
    }
    if (widget.mode == 'boarding' && widget.selectedBpId != oldWidget.selectedBpId) {
      _sendBoardingSelectUpdate();
    }
  }

  void _sendTrackingUpdate() {
    _iframeElement?.contentWindow?.postMessage({
      'type': 'update_progress',
      'progress': widget.progress,
      'isDeviated': widget.isDeviated,
    }, '*');
  }

  void _sendBoardingSelectUpdate() {
    if (widget.selectedBpId != null) {
      _iframeElement?.contentWindow?.postMessage({
        'type': 'select_bp',
        'id': widget.selectedBpId,
      }, '*');
    }
  }

  @override
  void dispose() {
    _msgSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewTypeId);
  }
}
