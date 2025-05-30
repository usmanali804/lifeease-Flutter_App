import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/ocr_service.dart';
import '../../domain/ocr_history_item.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  final OCRService _ocrService = OCRService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();
  final CropController _cropController = CropController();

  File? _image;
  Uint8List? _imageBytes;
  String _recognizedText = '';
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isCropping = false;

  @override
  void dispose() {
    _ocrService.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _isCropping = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _image = imageFile;
      _recognizedText = '';
      _isLoading = true;
    });

    try {
      final text = await _ocrService.extractTextFromImage(_image!);
      setState(() {
        _recognizedText = text;
        _textController.text = text;
        _isLoading = false;
      });
      _ocrService.addToHistory(text, imagePath: _image!.path);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error extracting text: $e')));
    }
  }

  Future<void> _onCropComplete(Uint8List croppedBytes) async {
    try {
      // Save the cropped image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(croppedBytes);

      setState(() {
        _isCropping = false;
      });

      await _processImage(tempFile);
    } catch (e) {
      setState(() {
        _isCropping = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing cropped image: $e')),
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _textController.text = _recognizedText;
      } else {
        _recognizedText = _textController.text;
        _ocrService.addToHistory(_recognizedText, imagePath: _image?.path);
      }
    });
  }

  void _shareText() {
    if (_recognizedText.isNotEmpty) {
      Share.share(_recognizedText);
    }
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => _HistorySheet(
            history: _ocrService.history,
            onSelect: (item) {
              setState(() {
                _recognizedText = item.text;
                _textController.text = item.text;
                if (item.imagePath != null) {
                  _image = File(item.imagePath!);
                }
              });
              Navigator.pop(context);
            },
            onDelete: (id) {
              _ocrService.removeFromHistory(id);
              setState(() {});
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCropping && _imageBytes != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Crop Image'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _isCropping = false;
                _imageBytes = null;
              });
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Crop(
                image: _imageBytes!,
                controller: _cropController,
                onCropped: _onCropComplete,
                aspectRatio: 4 / 3,
                initialSize: 0.8,
                initialArea: Rect.fromLTWH(0.1, 0.1, 0.8, 0.8),
                withCircleUi: false,
                baseColor: Colors.black.withAlpha((0.6 * 255).round()),
                maskColor: Colors.white.withAlpha((0.6 * 255).round()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _cropController.crop(),
                child: const Text('Crop Image'),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR - Image to Text'),
        actions: [
          if (_recognizedText.isNotEmpty) ...[
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _toggleEdit,
            ),
            IconButton(icon: const Icon(Icons.share), onPressed: _shareText),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _recognizedText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Text copied to clipboard')),
                );
              },
            ),
          ],
          IconButton(icon: const Icon(Icons.history), onPressed: _showHistory),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_image != null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_image!, fit: BoxFit.contain),
            ),
          ),
        const SizedBox(height: 20),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
              ),
              child: _isEditing
            ? TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Edit recognized text...',
                ),
              )
            : SingleChildScrollView(
                child: Text(
            _recognizedText.isEmpty
                ? 'Recognized text will appear here...'
                : _recognizedText,
            style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
            ],
          ),
        ),
      );
  }
}

class _HistorySheet extends StatelessWidget {
  final List<OCRHistoryItem> history;
  final Function(OCRHistoryItem) onSelect;
  final Function(String) onDelete;

  const _HistorySheet({
    required this.history,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                history.isEmpty
                    ? const Center(child: Text('No history yet'))
                    : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return ListTile(
                          leading:
                              item.imagePath != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.file(
                                      File(item.imagePath!),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : const Icon(Icons.text_snippet),
                          title: Text(
                            item.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => onDelete(item.id),
                          ),
                          onTap: () => onSelect(item),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
