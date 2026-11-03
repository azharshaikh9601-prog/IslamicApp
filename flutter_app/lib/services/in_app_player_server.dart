import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Embedded in-process loopback HTTP server that serves the official
/// YouTube player embed document with strict-origin Referrer headers.
///
/// This completely eliminates:
/// 1. "localhost refused to connect" (runs in-memory within Flutter itself)
/// 2. YouTube "Error 153" (provides a legitimate HTTP origin and Referrer header)
class InAppPlayerServer {
  static final InAppPlayerServer _instance = InAppPlayerServer._internal();
  factory InAppPlayerServer() => _instance;
  InAppPlayerServer._internal();

  HttpServer? _server;
  int _port = 0;
  bool _isStarting = false;

  int get port => _port;
  bool get isRunning => _server != null && _port > 0;

  Future<void> ensureStarted() async {
    if (isRunning || _isStarting) return;
    _isStarting = true;

    try {
      // Bind to an ephemeral loopback port
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _port = _server!.port;
      debugPrint('[InAppPlayerServer] Started embedded player server on port $_port');

      _server!.listen((HttpRequest request) {
        try {
          final uri = request.uri;
          final videoId = uri.queryParameters['v'] ?? '';
          final isShort = uri.queryParameters['short'] == '1';
          final loopParam = isShort ? '&loop=1&playlist=$videoId' : '';

          request.response.headers.set('Content-Type', 'text/html; charset=utf-8');
          request.response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
          request.response.headers.set('Access-Control-Allow-Origin', '*');

          final html = '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <meta name="referrer" content="strict-origin-when-cross-origin">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%;
      height: 100%;
      background-color: #000000;
      overflow: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    #player, iframe {
      width: 100%;
      height: 100%;
      border: 0;
    }
  </style>
</head>
<body>
  <div id="player"></div>
  <script>
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

    var player;
    function onYouTubeIframeAPIReady() {
      player = new YT.Player('player', {
        height: '100%',
        width: '100%',
        videoId: '$videoId',
        playerVars: {
          'autoplay': 1,
          'playsinline': 1,
          'controls': ${isShort ? 0 : 1},
          'rel': 0,
          'modestbranding': 1,
          ${isShort ? "'loop': 1, 'playlist': '$videoId'," : ""}
          'origin': 'http://127.0.0.1:$_port'
        },
        events: {
          'onReady': function(event) {
            ${isShort ? "event.target.playVideo();" : ""}
          }
        }
      });
    }
  </script>
</body>
</html>''';

          request.response.write(html);
          request.response.close();
        } catch (e) {
          debugPrint('[InAppPlayerServer] Error serving request: $e');
          try {
            request.response.statusCode = HttpStatus.internalServerError;
            request.response.close();
          } catch (_) {}
        }
      });
    } catch (e) {
      debugPrint('[InAppPlayerServer] Failed to bind local server: $e');
    } finally {
      _isStarting = false;
    }
  }

  String getUrlForVideo(String videoId, {bool isShort = false}) {
    if (isRunning) {
      return 'http://127.0.0.1:$_port/player?v=$videoId&short=${isShort ? '1' : '0'}';
    }
    // Fallback to youtube direct embed
    return 'https://www.youtube-nocookie.com/embed/$videoId?autoplay=1&controls=1&rel=0&playsinline=1';
  }

  void stop() {
    _server?.close(force: true);
    _server = null;
    _port = 0;
  }
}

