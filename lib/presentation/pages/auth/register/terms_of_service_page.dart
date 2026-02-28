import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  String? localPath;
  bool _isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _downloadAndSavePdf();
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      final url = 'https://api.ehisob.uz/public/PrivacyPolicy/EHisob_oferta.pdf';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/terms.pdf');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          localPath = file.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load PDF';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppTheme.colors.white, leading: BackArrowButton(), title: Text('Oferta'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppTheme.colors.primary))
                  : errorMessage != null
                  ? Center(
                      child: Text(errorMessage!, style: TextStyle(color: Colors.black)),
                    )
                  : PDFView(
                      filePath: localPath!,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: false,
                      pageFling: true,
                      pageSnap: true,
                      defaultPage: 0,
                      fitPolicy: FitPolicy.BOTH,
                      backgroundColor: const Color.fromRGBO(28, 29, 35, 1),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
