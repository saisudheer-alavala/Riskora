// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Set<String> _registeredPlatformViewTypes = {};

Widget createWebVideoBackground({String tag = 'default'}) {
  final viewType = 'riskora-bg-video-$tag';

  if (!_registeredPlatformViewTypes.contains(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final videoElement = html.VideoElement()
        ..autoplay = true
        ..loop = true
        ..muted = true
        ..defaultMuted = true
        ..setAttribute('playsinline', 'true')
        ..setAttribute('webkit-playsinline', 'true')
        ..setAttribute('muted', 'true')
        ..setAttribute('autoplay', 'true')
        ..setAttribute('loop', 'true')
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.pointerEvents = 'none'
        ..style.backgroundColor = '#0D0C15';

      // Provide multiple video paths so web server finds the file reliably
      final s1 = html.SourceElement()..src = '338222_medium.mp4'..type = 'video/mp4';
      final s2 = html.SourceElement()..src = 'assets/videos/338222_medium.mp4'..type = 'video/mp4';
      final s3 = html.SourceElement()..src = 'assets/338222_medium.mp4'..type = 'video/mp4';
      videoElement.append(s1);
      videoElement.append(s2);
      videoElement.append(s3);

      videoElement.play().catchError((e) {
        // Handled silently to avoid unhandled browser promise rejection
      });
      return videoElement;
    });
    _registeredPlatformViewTypes.add(viewType);
  }

  return HtmlElementView(viewType: viewType);
}
