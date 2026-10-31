// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Set<String> _registeredVideoViewTypes = {};

Widget buildInAppVideoPlayer({
  Key? key,
  required String youtubeId,
  required String title,
  VoidCallback? onWatched,
}) {
  return WebInAppVideoPlayer(
    key: key,
    youtubeId: youtubeId,
    title: title,
    onWatched: onWatched,
  );
}

class WebInAppVideoPlayer extends StatefulWidget {
  final String youtubeId;
  final String title;
  final VoidCallback? onWatched;

  const WebInAppVideoPlayer({
    super.key,
    required this.youtubeId,
    required this.title,
    this.onWatched,
  });

  @override
  State<WebInAppVideoPlayer> createState() => _WebInAppVideoPlayerState();
}

class _WebInAppVideoPlayerState extends State<WebInAppVideoPlayer> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'youtube-nocookie-player-${widget.youtubeId}';

    if (!_registeredVideoViewTypes.contains(_viewType)) {
      _registeredVideoViewTypes.add(_viewType);
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) {
          final origin = html.window.location.origin;
          final embedUrl =
              'https://www.youtube-nocookie.com/embed/${widget.youtubeId}?autoplay=1&enablejsapi=1&rel=0&modestbranding=1&playsinline=1&origin=${Uri.encodeComponent(origin)}';

          final iframe = html.IFrameElement()
            ..src = embedUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allow =
                'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'
            ..setAttribute('allowfullscreen', 'true')
            ..setAttribute('sandbox',
                'allow-scripts allow-same-origin allow-presentation allow-forms');
          return iframe;
        },
      );
    }

    widget.onWatched?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
