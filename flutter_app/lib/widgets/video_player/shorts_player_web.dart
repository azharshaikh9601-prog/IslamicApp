// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Set<String> _registeredShortsViewTypes = {};

Widget buildShortsPlayer({
  required String youtubeId,
  required String title,
  VoidCallback? onWatched,
}) {
  return WebShortsPlayer(
    youtubeId: youtubeId,
    title: title,
    onWatched: onWatched,
  );
}

class WebShortsPlayer extends StatefulWidget {
  final String youtubeId;
  final String title;
  final VoidCallback? onWatched;

  const WebShortsPlayer({
    super.key,
    required this.youtubeId,
    required this.title,
    this.onWatched,
  });

  @override
  State<WebShortsPlayer> createState() => _WebShortsPlayerState();
}

class _WebShortsPlayerState extends State<WebShortsPlayer> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'youtube-short-inapp-${widget.youtubeId}';

    if (!_registeredShortsViewTypes.contains(_viewType)) {
      _registeredShortsViewTypes.add(_viewType);
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) {
          final origin = html.window.location.origin;
          final embedUrl =
              'https://www.youtube-nocookie.com/embed/${widget.youtubeId}?autoplay=1&enablejsapi=1&playsinline=1&rel=0&modestbranding=1&iv_load_policy=3&origin=${Uri.encodeComponent(origin)}';

          final iframe = html.IFrameElement()
            ..src = embedUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allow =
                'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'
            ..setAttribute('allowfullscreen', 'true')
            // Strictly sandbox iframe so it CANNOT navigate the parent window or redirect outside to YouTube
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
      child: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: HtmlElementView(viewType: _viewType),
        ),
      ),
    );
  }
}
