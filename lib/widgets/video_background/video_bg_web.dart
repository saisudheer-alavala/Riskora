// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

bool _isViewFactoryRegistered = false;

Widget createWebVideoBackground() {
  const viewType = 'riskora-bg-video-platform-view';

  if (!_isViewFactoryRegistered) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final videoElement = html.VideoElement()
        ..src = '338222_medium.mp4'
        ..autoplay = true
        ..loop = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..setAttribute('webkit-playsinline', 'true')
        ..setAttribute('muted', 'true')
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.pointerEvents = 'auto'
        ..style.opacity = '1.0';

      videoElement.play();
      return videoElement;
    });
    _isViewFactoryRegistered = true;
  }

  return const HtmlElementView(viewType: viewType);
}
