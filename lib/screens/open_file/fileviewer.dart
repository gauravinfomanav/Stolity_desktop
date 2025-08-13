import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:csv/csv.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stolity_desktop_application/dialogs/stolity_alert_prompt.dart';
import 'package:stolity_desktop_application/screens/open_file/controller.dart';

class FileViewer extends StatefulWidget {
  final String filePath;
  final String fileName;
  final String? fileKey;

  const FileViewer({
    Key? key,
    required this.filePath,
    required this.fileName,
    this.fileKey,
  }) : super(key: key);

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  late Widget _fileContentWidget;
  bool _isLoading = true;
  String? _error;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  AudioPlayer? _audioPlayer;

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
        case '.svg':
          _fileContentWidget = _buildSvgViewer();
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
        case '.json':
          _fileContentWidget = await _buildJsonViewer();
          break;
        case '.yml':
        case '.yaml':
        case '.xml':
        case '.log':
        case '.ini':
          _fileContentWidget = await _buildTextViewer();
          break;
        default:
          // Initialize a safe placeholder to avoid LateInitializationError in build
          _fileContentWidget = const SizedBox.shrink();
          // Schedule prompt after first frame to avoid calling before init completes
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            await StolityPrompt.show(
              context: context,
              title: 'Unsupported file',
              subtitle: 'This file type ($fileExtension) is not supported for in-app preview.',
              negativeButtonText: '',
              positiveButtonText: 'OK',
              onPositivePressed: () => Navigator.of(context).pop(),
            );
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
          return;
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

  Widget _buildSvgViewer() {
    return Center(
      child: SvgPicture.file(
        File(widget.filePath),
        fit: BoxFit.contain,
      ),
    );
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

  Future<Widget> _buildJsonViewer() async {
    try {
      final content = await File(widget.filePath).readAsString();
      final dynamic decoded = jsonDecode(content);
      final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SelectableText(
            pretty,
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
          ),
        ),
      );
    } catch (e) {
      // Fallback to raw if parse fails
      try {
        final raw = await File(widget.filePath).readAsString();
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SelectableText(raw, style: const TextStyle(fontSize: 13)),
          ),
        );
      } catch (e2) {
        return Center(child: Text('Error loading JSON file: $e2'));
      }
    }
  }

  Widget _buildVideoPlayer() {
    _videoController ??= VideoPlayerController.file(File(widget.filePath));
    _chewieController ??= ChewieController(
      videoPlayerController: _videoController!,
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
    return Chewie(controller: _chewieController!);
  }

  Widget _buildAudioPlayer() {
    _audioPlayer ??= AudioPlayer();
    _audioPlayer!.setFilePath(widget.filePath);
    
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
            stream: _audioPlayer!.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = _audioPlayer!.duration ?? Duration.zero;
              return ProgressBar(
                progress: position,
                total: duration,
                onSeek: (duration) {
                  _audioPlayer!.seek(duration);
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<PlayerState>(
                stream: _audioPlayer!.playerStateStream,
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
                      onPressed: _audioPlayer!.play,
                    );
                  } else {
                    return IconButton(
                      icon: const Icon(Icons.pause),
                      iconSize: 32.0,
                      onPressed: _audioPlayer!.pause,
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
        title: Text(widget.fileName, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Download',
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              final key = widget.fileKey ?? widget.fileName;
              FileOpenController().backgroundDownloadByKey(context, key);
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF7F7F9),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _fileContentWidget,
                  ),
      ),
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }
}