import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:csv/csv.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';

class FileViewer extends StatefulWidget {
  final String filePath;
  final String fileName;

  const FileViewer({
    Key? key,
    required this.filePath,
    required this.fileName,
  }) : super(key: key);

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  late Widget _fileContentWidget;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFileContent();
  }

  void _loadFileContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final fileExtension = path.extension(widget.fileName).toLowerCase();
      
      switch (fileExtension) {
        case '.pdf':
          _fileContentWidget = _buildPdfViewer();
          break;
        case '.jpg':
        case '.jpeg':
        case '.png':
        case '.gif':
        case '.bmp':
          _fileContentWidget = _buildImageViewer();
          break;
        case '.txt':
          _fileContentWidget = await _buildTextViewer();
          break;
        case '.md':
          _fileContentWidget = await _buildMarkdownViewer();
          break;
        case '.csv':
          _fileContentWidget = await _buildCsvViewer();
          break;
        case '.xlsx':
        case '.xls':
          _fileContentWidget = await _buildExcelViewer();
          break;
        case '.mp4':
        case '.avi':
        case '.mov':
        case '.wmv':
          _fileContentWidget = _buildVideoPlayer();
          break;
        case '.mp3':
        case '.wav':
        case '.m4a':
          _fileContentWidget = _buildAudioPlayer();
          break;
        default:
          _fileContentWidget = Center(
            child: Text(
              'Unsupported file type: $fileExtension',
              style: const TextStyle(fontSize: 16),
            ),
          );
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading file: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPdfViewer() {
    return SfPdfViewer.file(
      File(widget.filePath),
      enableDocumentLinkAnnotation: true,
      enableTextSelection: true,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      canShowPaginationDialog: true,
    );
  }

  Widget _buildImageViewer() {
    return Center(
      child: Image.file(
        File(widget.filePath),
        fit: BoxFit.contain,
      ),
    );
  }

  Future<Widget> _buildTextViewer() async {
    try {
      final content = await File(widget.filePath).readAsString();
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SelectableText(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    } catch (e) {
      return Center(child: Text('Error loading text file: $e'));
    }
  }

  Future<Widget> _buildMarkdownViewer() async {
    try {
      final content = await File(widget.filePath).readAsString();
      return Markdown(data: content);
    } catch (e) {
      return Center(child: Text('Error loading markdown file: $e'));
    }
  }

  Future<Widget> _buildCsvViewer() async {
    try {
      final content = await File(widget.filePath).readAsString();
      final List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(content);
      
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: rowsAsListOfValues[0]
                .map((item) => DataColumn(
                      label: Text(
                        item.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ))
                .toList(),
            rows: rowsAsListOfValues
                .sublist(1)
                .map(
                  (row) => DataRow(
                    cells: row
                        .map((cell) => DataCell(Text(cell.toString())))
                        .toList(),
                  ),
                )
                .toList(),
          ),
        ),
      );
    } catch (e) {
      return Center(child: Text('Error loading CSV file: $e'));
    }
  }

  Future<Widget> _buildExcelViewer() async {
    // For Excel files, a more complex approach is needed
    // This is a simplified placeholder that would need a more advanced implementation
    return const Center(
      child: Text('Excel viewer requires additional implementation'),
    );
  }

  Widget _buildVideoPlayer() {
    final videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    final chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );

    return Chewie(controller: chewieController);
  }

  Widget _buildAudioPlayer() {
    final audioPlayer = AudioPlayer();
    audioPlayer.setFilePath(widget.filePath);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.fileName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          StreamBuilder<Duration>(
            stream: audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = audioPlayer.duration ?? Duration.zero;
              return ProgressBar(
                progress: position,
                total: duration,
                onSeek: (duration) {
                  audioPlayer.seek(duration);
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<PlayerState>(
                stream: audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;
                  
                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      width: 32.0,
                      height: 32.0,
                      child: const CircularProgressIndicator(),
                    );
                  } else if (playing != true) {
                    return IconButton(
                      icon: const Icon(Icons.play_arrow),
                      iconSize: 32.0,
                      onPressed: audioPlayer.play,
                    );
                  } else {
                    return IconButton(
                      icon: const Icon(Icons.pause),
                      iconSize: 32.0,
                      onPressed: audioPlayer.pause,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Implement download functionality if needed
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality if needed
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _fileContentWidget,
    );
  }
}