import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;

  PdfViewerPage({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Viewer")),
      body: const PDF().fromUrl(
        pdfUrl,
        placeholder: (progress) => Center(child: CircularProgressIndicator(value: progress / 100)),
        errorWidget: (error) => Center(child: Text("⚠️ Error loading PDF")),
      ),
    );
  }
}
