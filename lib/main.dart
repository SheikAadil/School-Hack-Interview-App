import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_waveform/just_waveform.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final progressStream = BehaviorSubject<WaveformProgress>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final audioFile =
        File(p.join((await getTemporaryDirectory()).path, 'waveform.mp3'));
    try {
      await audioFile.writeAsBytes(
          (await rootBundle.load('audio/waveform.mp3')).buffer.asUint8List());
      final waveFile =
          File(p.join((await getTemporaryDirectory()).path, 'waveform.wave'));
      JustWaveform.extract(audioInFile: audioFile, waveOutFile: waveFile)
          .listen(progressStream.add, onError: progressStream.addError);
    } catch (e) {
      progressStream.addError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xff0D0D0D),
        appBar: AppBar(
          title: const Text(
            'Post',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Colors.white24,
              height: 0.2,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff0D0D0D),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xffF8F8F8),
              size: 22,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: const Text(
                "+ Invite",
                style: TextStyle(
                  color: Color(0xffF8F8F8),
                ),
              ),
            )
          ],
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      child: Row(
                        children: [
                          Container(
                            height: 45,
                            width: 45,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: const CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Image(
                                image: AssetImage('images/jl.png'),
                                height: 45,
                                width: 45,
                              ),
                            ),
                          ),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Joshua Lawrence",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xffF8F8F8),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "@joshua95",
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                ". 8h",
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 22, right: 22, top: 5, bottom: 5),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lecture about AI technology",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xffF8F8F8),
                      ),
                    ),
                    Text(
                      "By: Mohammed",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xffF8F8F8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 22, right: 22, top: 5, bottom: 5),
                height: 87,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8F8F8),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        height: 72,
                        width: 72,
                        child: const Icon(
                          Icons.play_arrow,
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    const Text(
                      "00:15",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffF8F8F8),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    //Audio waveform progress bar
                    Container(
                      height: 50.0,
                      width: 130,
                      child: StreamBuilder<WaveformProgress>(
                        stream: progressStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          final progress = snapshot.data?.progress ?? 0.0;
                          final waveform = snapshot.data?.waveform;
                          if (waveform == null) {
                            return Center(
                              child: Text(
                                '${(100 * progress).toInt()}%',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            );
                          }
                          return AudioWaveformWidget(
                            waveform: waveform,
                            start: Duration.zero,
                            duration: waveform.duration,
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF8F8F8),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      height: 22,
                      width: 38,
                      child: const Center(
                        child: Text(
                          "x1.5",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff0D0D0D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 22, right: 22, top: 10, bottom: 10),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Color(0xffF8F8F8),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "324",
                          style: TextStyle(
                            color: Color(0xffF8F8F8),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Color(0xffFF0000),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "324",
                          style: TextStyle(
                            color: Color(0xffF8F8F8),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          color: Color(0xffF8F8F8),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "324",
                          style: TextStyle(
                            color: Color(0xffF8F8F8),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image(image: AssetImage('images/ai.png')),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Ai Chat",
                          style: TextStyle(
                            color: Color(0xffF8F8F8),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.download,
                      color: Color(0xffF8F8F8),
                    ),
                  ],
                ),
              ),
              Container(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: const CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Image(
                                  image: AssetImage(
                                    'images/kiero.png',
                                  ),
                                  height: 55,
                                  width: 55,
                                ),
                              ),
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "kiero_d",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xffF8F8F8),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "@kiero_d",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      ". 2d",
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Replying to",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xffF8F8F8),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "@ashen95",
                                      style:
                                          TextStyle(color: Color(0xff4C9EEB)),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      ". 2d",
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 36, right: 22),
                          child: Row(
                            children: [
                              Container(
                                height: 88,
                                width: 2,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 268,
                                margin: const EdgeInsets.only(
                                  left: 38,
                                ),
                                child: Column(
                                  children: [
                                    const Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Interesting Nicola that not one reply or tag on this ',
                                            style: TextStyle(
                                              color: Color(0xffF8F8F8),
                                              fontSize: 16,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '#UX',
                                            style: TextStyle(
                                              color: Color(0xff4C9EEB),
                                              fontSize: 16,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                ' talent shout out in the 24hrs since your tweet here....🤔',
                                            style: TextStyle(
                                              color: Color(0xffF8F8F8),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: const Row(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .chat_bubble_outline_rounded,
                                                color: Color(0xffF8F8F8),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "324",
                                                style: TextStyle(
                                                  color: Color(0xffF8F8F8),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 22,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.favorite,
                                                color: Color(0xffFF0000),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "324",
                                                style: TextStyle(
                                                  color: Color(0xffF8F8F8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: const CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Image(
                                  image: AssetImage(
                                    'images/karene.png',
                                  ),
                                  height: 55,
                                  width: 55,
                                ),
                              ),
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "karennne",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xffF8F8F8),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "@karennne",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      ". 2d",
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Replying to",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xffF8F8F8),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "@ashen95",
                                      style:
                                          TextStyle(color: Color(0xff4C9EEB)),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      ". 2d",
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 36, right: 22),
                          child: Row(
                            children: [
                              Container(
                                height: 88,
                                width: 2,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 268,
                                margin: const EdgeInsets.only(
                                  left: 38,
                                ),
                                child: Column(
                                  children: [
                                    const Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Maybe I forgot the hashtags. ',
                                            style: TextStyle(
                                              color: Color(0xffF8F8F8),
                                              fontSize: 16,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '#hiringux #designjobs #sydneyux #sydneydesigners #uxjobs',
                                            style: TextStyle(
                                              color: Color(0xff4C9EEB),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: const Row(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .chat_bubble_outline_rounded,
                                                color: Color(0xffF8F8F8),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "324",
                                                style: TextStyle(
                                                  color: Color(0xffF8F8F8),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 22,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.favorite,
                                                color: Color(0xffFF0000),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "324",
                                                style: TextStyle(
                                                  color: Color(0xffF8F8F8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white24, width: 0.2)),
            color: Color(0xff0D0D0D),
          ),
          child: Container(
            margin:
                const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image(
                  image: AssetImage('images/navhome.png'),
                  height: 65,
                  width: 65,
                ),
                Image(
                  image: AssetImage('images/navgroups.png'),
                  height: 65,
                  width: 65,
                ),
                Image(
                  image: AssetImage('images/navknowledge.png'),
                  height: 65,
                  width: 65,
                ),
                Image(
                  image: AssetImage('images/navmessages.png'),
                  height: 65,
                  width: 65,
                ),
                Image(
                  image: AssetImage('images/navprofile.png'),
                  height: 65,
                  width: 65,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AudioWaveformWidget extends StatefulWidget {
  final Color waveColor;
  final double scale;
  final double strokeWidth;
  final double pixelsPerStep;
  final Waveform waveform;
  final Duration start;
  final Duration duration;

  const AudioWaveformWidget({
    Key? key,
    required this.waveform,
    required this.start,
    required this.duration,
    this.waveColor = Colors.white,
    this.scale = 1.0,
    this.strokeWidth = 3.0,
    this.pixelsPerStep = 7.0,
  }) : super(key: key);

  @override
  _AudioWaveformState createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveformWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: AudioWaveformPainter(
          waveColor: widget.waveColor,
          waveform: widget.waveform,
          start: widget.start,
          duration: widget.duration,
          scale: widget.scale,
          strokeWidth: widget.strokeWidth,
          pixelsPerStep: widget.pixelsPerStep,
        ),
      ),
    );
  }
}

class AudioWaveformPainter extends CustomPainter {
  final double scale;
  final double strokeWidth;
  final double pixelsPerStep;
  final Paint wavePaint;
  final Waveform waveform;
  final Duration start;
  final Duration duration;

  AudioWaveformPainter({
    required this.waveform,
    required this.start,
    required this.duration,
    Color waveColor = Colors.white,
    this.scale = 1.0,
    this.strokeWidth = 3.0,
    this.pixelsPerStep = 7.0,
  }) : wavePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = waveColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (duration == Duration.zero) return;

    double width = size.width;
    double height = size.height;

    final waveformPixelsPerWindow = waveform.positionToPixel(duration).toInt();
    final waveformPixelsPerDevicePixel = waveformPixelsPerWindow / width;
    final waveformPixelsPerStep = waveformPixelsPerDevicePixel * pixelsPerStep;
    final sampleOffset = waveform.positionToPixel(start);
    final sampleStart = -sampleOffset % waveformPixelsPerStep;
    for (var i = sampleStart.toDouble();
        i <= waveformPixelsPerWindow + 1.0;
        i += waveformPixelsPerStep) {
      final sampleIdx = (sampleOffset + i).toInt();
      final x = i / waveformPixelsPerDevicePixel;
      final minY = normalise(waveform.getPixelMin(sampleIdx), height);
      final maxY = normalise(waveform.getPixelMax(sampleIdx), height);
      canvas.drawLine(
        Offset(x + strokeWidth / 2, max(strokeWidth * 0.75, minY)),
        Offset(x + strokeWidth / 2, min(height - strokeWidth * 0.75, maxY)),
        wavePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return false;
  }

  double normalise(int s, double height) {
    if (waveform.flags == 0) {
      final y = 32768 + (scale * s).clamp(-32768.0, 32767.0).toDouble();
      return height - 1 - y * height / 65536;
    } else {
      final y = 128 + (scale * s).clamp(-128.0, 127.0).toDouble();
      return height - 1 - y * height / 256;
    }
  }
}
