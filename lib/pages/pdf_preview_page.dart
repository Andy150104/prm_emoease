import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class PdfViewPage extends StatefulWidget {
  final String filePath;
  const PdfViewPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Xem PDF'),
      actions: [
        IconButton(
          icon: const Icon(Icons.download_rounded),
          tooltip: 'Tải xuống',
          onPressed: _confirmAndDownload,
        ),
      ],
    ),
    body: PDFView(
      filePath: widget.filePath,
      enableSwipe: true,
      swipeHorizontal: false,
      onError: (err) => print('PDFView error: $err'),
      onPageError: (page, err) => print('Lỗi trang $page: $err'),
    ),
  );

  /// 1. Hiển thị dialog hỏi user
  Future<void> _confirmAndDownload() async {
    final should = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận tải xuống'),
        content: const Text('Bạn có chắc muốn tải file PDF về thiết bị không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('OK')),
        ],
      ),
    );

    if (should == true) {
      await _downloadPdf();
    }
  }

  /// 2. Yêu cầu quyền trên Android 11+ hoặc storage truyền thống
  Future<bool> _askStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 11+ cần MANAGE_EXTERNAL_STORAGE
      if (await Permission.manageExternalStorage.isDenied) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          // Mở Settings nếu user từ chối vĩnh viễn
          await openAppSettings();
          return false;
        }
      }
      return true;
    }
    // iOS không cần storage
    final s = await Permission.storage.request();
    return s.isGranted;
  }

  /// 3. Thực hiện đọc bytes & ghi file
  Future<void> _downloadPdf() async {
    final granted = await _askStoragePermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần cấp quyền truy cập bộ nhớ để tải file')),
      );
      return;
    }

    try {
      final bytes = await File(widget.filePath).readAsBytes();

      // Lấy thư mục Download chuẩn
      final dirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = path.basename(widget.filePath);
      final savePath = path.join(downloadsDir.path, fileName);

      final savedFile = await File(savePath).writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu thành công: ${savedFile.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu file: $e')),
      );
    }
  }
}
