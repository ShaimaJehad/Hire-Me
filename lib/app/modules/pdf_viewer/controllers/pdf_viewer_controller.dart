import 'package:get/get.dart';

class PdfViewerController extends GetxController {
  late final String pdfUrl;

  @override
  void onInit() {
    super.onInit();
    pdfUrl = Get.arguments as String? ?? '';
  }
}
