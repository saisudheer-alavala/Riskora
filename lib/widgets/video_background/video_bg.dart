import 'package:flutter/material.dart';
import 'video_bg_stub.dart'
    if (dart.library.html) 'video_bg_web.dart' as impl;

class VideoBackgroundWidget extends StatelessWidget {
  final String tag;
  const VideoBackgroundWidget({super.key, this.tag = 'default'});

  @override
  Widget build(BuildContext context) {
    return impl.createWebVideoBackground(tag: tag);
  }
}
