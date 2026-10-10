import 'package:flutter/material.dart';
import 'video_bg_stub.dart'
    if (dart.library.html) 'video_bg_web.dart' as impl;

class VideoBackgroundWidget extends StatelessWidget {
  const VideoBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return impl.createWebVideoBackground();
  }
}
