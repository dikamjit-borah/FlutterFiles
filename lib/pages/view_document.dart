import 'dart:io';

import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


class ViewDocument extends StatefulWidget {
  String documentPath;

  ViewDocument({Key? key, required this.documentPath}) : super(key: key);

  @override
  State<ViewDocument> createState() => _ViewDocumentState();
}

class _ViewDocumentState extends State<ViewDocument> {

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

      return SfPdfViewer.file(
        File(widget.documentPath),
      );


  }
  }
