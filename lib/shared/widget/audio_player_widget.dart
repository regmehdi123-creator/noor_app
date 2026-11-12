import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../core/colors.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final String title;

  const AudioPlayerWidget({super.key, required this.url, required this.title});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      await _audioPlayer.setUrl(widget.url);
    } catch (e) {
      debugPrint("Audio Player Error: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              StreamBuilder<PlayerState>(
                stream: _audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;
                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      width: 48.0,
                      height: 48.0,
                      child: const CircularProgressIndicator(color: mainColor),
                    );
                  } else if (playing != true) {
                    return IconButton(
                      icon: const Icon(Icons.play_circle_filled),
                      iconSize: 48.0,
                      color: mainColor,
                      onPressed: _audioPlayer.play,
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return IconButton(
                      icon: const Icon(Icons.pause_circle_filled),
                      iconSize: 48.0,
                      color: mainColor,
                      onPressed: _audioPlayer.pause,
                    );
                  } else {
                    return IconButton(
                      icon: const Icon(Icons.replay_circle_filled),
                      iconSize: 48.0,
                      color: mainColor,
                      onPressed: () => _audioPlayer.seek(Duration.zero),
                    );
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text("استماع صوتي", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<Duration?>(
            stream: _audioPlayer.positionStream,
            builder: (context, snapshot) {
              return ProgressBar(
                progress: snapshot.data ?? Duration.zero,
                total: _audioPlayer.duration ?? Duration.zero,
                onSeek: (duration) {
                  _audioPlayer.seek(duration);
                },
                baseBarColor: mainColor.withValues(alpha: 0.1),
                progressBarColor: mainColor,
                bufferedBarColor: mainColor.withValues(alpha: 0.2),
                thumbColor: mainColor,
                barHeight: 5.0,
                thumbRadius: 8.0,
              );
            },
          ),
        ],
      ),
    );
  }
}
