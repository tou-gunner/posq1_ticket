import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:charset_converter/charset_converter.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:oktoast/oktoast.dart';

void _paintText(Canvas canvas, String text, Offset offset, { TextAlign align = TextAlign.left }) {
  final span = TextSpan(text: text, style: const TextStyle(color: Colors.black45));
  final tp = TextPainter(text: span, textAlign: align, textDirection: ui.TextDirection.ltr);
  tp.layout();
  tp.paint(canvas, offset);
}

Future<Uint8List> carTicket(PaperSize paper, CapabilityProfile profile) async {
  final Generator ticket = Generator(paper, profile);
  List<int> bytes = [];
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final title = await CharsetConverter.encode("UTF-8", "ປີ້ລົດ");
  final name = await CharsetConverter.encode("UTF-8", "ຊື່ຮ້ານ");
  final address = await CharsetConverter.encode("UTF-8", "ທີ່ຢູ່");
  final number = await CharsetConverter.encode("UTF-8", "ປ້າຍລົດ");
  final price = await CharsetConverter.encode("UTF-8", "ລາຄາ");
  final total = await CharsetConverter.encode("UTF-8", "ລວມ");

  // final title = await CharsetConverter.encode("windows1250", "Ticket");
  // final name = await CharsetConverter.encode("windows1250", "Name");
  // final address = await CharsetConverter.encode("windows1250", "Address");
  // final number = await CharsetConverter.encode("windows1250", "Plate Number");
  // final price = await CharsetConverter.encode("windows1250", "Price");
  // final total = await CharsetConverter.encode("windows1250", "Total");

  // bytes += ticket.textEncoded(title,
  //     styles: const PosStyles(
  //       align: PosAlign.center,
  //       height: PosTextSize.size2,
  //       width: PosTextSize.size2,
  //     ),
  //     linesAfter: 1
  // );
  //
  // bytes += ticket.textEncoded(name,
  //     styles: const PosStyles(align: PosAlign.center)
  // );
  //
  // bytes += ticket.textEncoded(address,
  //     styles: const PosStyles(align: PosAlign.center),
  //     linesAfter: 1
  // );

  _paintText(canvas, "ປີ້ລົດ", const Offset(250, 100));
  _paintText(canvas, "ຊື່ຮ້ານ", const Offset(100, 200));
  _paintText(canvas, "ທີ່ຢູ່", const Offset(500, 200));

  // bytes += ticket.hr();

  // bytes += ticket.row([
  //   PosColumn(textEncoded: number, width: 7),
  //   PosColumn(textEncoded: price, width: 5, styles: const PosStyles(align: PosAlign.right)),
  // ]);
  //
  // bytes += ticket.row([
  //   PosColumn(text: '5555', width: 7),
  //   PosColumn(text: '10,000', width: 5, styles: const PosStyles(align: PosAlign.right)),
  // ]);

  _paintText(canvas, "ປ້າຍລົດ", const Offset(100, 400));
  _paintText(canvas, "ລາຄາ", const Offset(250, 400));
  _paintText(canvas, "5555", const Offset(100, 500));
  _paintText(canvas, "10,000", const Offset(250, 500));

  // bytes += ticket.hr();

  // bytes += ticket.row([
  //   PosColumn(
  //       textEncoded: total,
  //       width: 6,
  //       styles: const PosStyles(
  //         height: PosTextSize.size2,
  //         width: PosTextSize.size2,
  //       )),
  //   PosColumn(
  //       text: '10,000',
  //       width: 6,
  //       styles: const PosStyles(
  //         align: PosAlign.right,
  //         height: PosTextSize.size2,
  //         width: PosTextSize.size2,
  //       )),
  // ]);

  _paintText(canvas, "ລວມ", const Offset(100, 700));
  _paintText(canvas, "10,000", const Offset(250, 700));

  var picture = recorder.endRecording();
  var image = await picture.toImage(paper.width, paper.width);
  var data = await image.toByteData();

  bytes += ticket.image(Image.fromBytes(paper.width, paper.width, data!.buffer.asInt8List()));

  bytes += ticket.feed(2);
  bytes += ticket.cut();
  return data.buffer.asUint8List();
}

Future<List<int>> demoReceipt(
    PaperSize paper, CapabilityProfile profile) async {
  final Generator ticket = Generator(paper, profile);
  List<int> bytes = [];

  // Print image
  // final ByteData data = await rootBundle.load('assets/rabbit_black.jpg');
  // final Uint8List imageBytes = data.buffer.asUint8List();
  // final Image? image = decodeImage(imageBytes);
  // bytes += ticket.image(image);

  bytes += ticket.text('GROCERYLY',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1);

  bytes += ticket.text('889  Watson Lane',
      styles: const PosStyles(align: PosAlign.center));
  bytes += ticket.text('New Braunfels, TX',
      styles: const PosStyles(align: PosAlign.center));
  bytes += ticket.text('Tel: 830-221-1234',
      styles: const PosStyles(align: PosAlign.center));
  bytes += ticket.text('Web: www.example.com',
      styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

  bytes += ticket.hr();
  bytes += ticket.row([
    PosColumn(text: 'Qty', width: 1),
    PosColumn(text: 'Item', width: 7),
    PosColumn(
        text: 'Price', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: 'Total', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);

  bytes += ticket.row([
    PosColumn(text: '2', width: 1),
    PosColumn(text: 'ONION RINGS', width: 7),
    PosColumn(
        text: '0.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: '1.98', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);
  bytes += ticket.row([
    PosColumn(text: '1', width: 1),
    PosColumn(text: 'PIZZA', width: 7),
    PosColumn(
        text: '3.45', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: '3.45', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);
  bytes += ticket.row([
    PosColumn(text: '1', width: 1),
    PosColumn(text: 'SPRING ROLLS', width: 7),
    PosColumn(
        text: '2.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: '2.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);
  bytes += ticket.row([
    PosColumn(text: '3', width: 1),
    PosColumn(text: 'CRUNCHY STICKS', width: 7),
    PosColumn(
        text: '0.85', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: '2.55', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);
  bytes += ticket.hr();

  bytes += ticket.row([
    PosColumn(
        text: 'TOTAL',
        width: 6,
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        )),
    PosColumn(
        text: '\$10.97',
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        )),
  ]);

  bytes += ticket.hr(ch: '=', linesAfter: 1);

  bytes += ticket.row([
    PosColumn(
        text: 'Cash',
        width: 7,
        styles: const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    PosColumn(
        text: '\$15.00',
        width: 5,
        styles: const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
  ]);
  bytes += ticket.row([
    PosColumn(
        text: 'Change',
        width: 7,
        styles: const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    PosColumn(
        text: '\$4.03',
        width: 5,
        styles: const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
  ]);

  bytes += ticket.feed(2);
  bytes += ticket.text('Thank you!',
      styles: const PosStyles(align: PosAlign.center, bold: true));

  final now = DateTime.now();
  final formatter = DateFormat('MM/dd/yyyy H:m');
  final String timestamp = formatter.format(now);
  bytes += ticket.text(timestamp,
      styles: const PosStyles(align: PosAlign.center), linesAfter: 2);

  // Print QR Code from image
  // try {
  //   const String qrData = 'example.com';
  //   const double qrSize = 200;
  //   final uiImg = await QrPainter(
  //     data: qrData,
  //     version: QrVersions.auto,
  //     gapless: false,
  //   ).toImageData(qrSize);
  //   final dir = await getTemporaryDirectory();
  //   final pathName = '${dir.path}/qr_tmp.png';
  //   final qrFile = File(pathName);
  //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
  //   final img = decodeImage(imgFile.readAsBytesSync());

  //   bytes += ticket.image(img);
  // } catch (e) {
  //   print(e);
  // }

  // Print QR Code using native function
  // bytes += ticket.qrcode('example.com');

  ticket.feed(2);
  ticket.cut();
  return bytes;
}

Future<List<int>> testTicket(
    PaperSize paper, CapabilityProfile profile) async {
  final Generator generator = Generator(paper, profile);
  List<int> bytes = [];

  bytes += generator.text(
      'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
  // bytes += generator.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
  //     styles: PosStyles(codeTable: PosCodeTable.westEur));
  // bytes += generator.text('Special 2: blåbærgrød',
  //     styles: PosStyles(codeTable: PosCodeTable.westEur));

  bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
  bytes += generator.text('Reverse text', styles: const PosStyles(reverse: true));
  bytes += generator.text('Underlined text',
      styles: const PosStyles(underline: true), linesAfter: 1);
  bytes +=
      generator.text('Align left', styles: const PosStyles(align: PosAlign.left));
  bytes += generator.text('Align center',
      styles: const PosStyles(align: PosAlign.center));
  bytes += generator.text('Align right',
      styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

  bytes += generator.row([
    PosColumn(
      text: 'col3',
      width: 3,
      styles: const PosStyles(align: PosAlign.center, underline: true),
    ),
    PosColumn(
      text: 'col6',
      width: 6,
      styles: const PosStyles(align: PosAlign.center, underline: true),
    ),
    PosColumn(
      text: 'col3',
      width: 3,
      styles: const PosStyles(align: PosAlign.center, underline: true),
    ),
  ]);

  bytes += generator.text('Text size 200%',
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ));

  // Print image
  final ByteData data = await rootBundle.load('assets/logo.png');
  final Uint8List buf = data.buffer.asUint8List();
  final Image image = decodeImage(buf)!;
  bytes += generator.image(image);
  // Print image using alternative commands
  // bytes += generator.imageRaster(image);
  // bytes += generator.imageRaster(image, imageFn: PosImageFn.graphics);

  // Print barcode
  final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
  bytes += generator.barcode(Barcode.upcA(barData));

  // Print mixed (chinese + latin) text. Only for printers supporting Kanji mode
  // bytes += generator.text(
  //   'hello ! 中文字 # world @ éphémère &',
  //   styles: PosStyles(codeTable: PosCodeTable.westEur),
  //   containsChinese: true,
  // );

  bytes += generator.feed(2);

  bytes += generator.cut();
  return bytes;
}

PrinterBluetoothManager printerManager = PrinterBluetoothManager();
Future<Uint8List> sample4(PrinterBluetooth printer) async {
  printerManager.selectPrinter(printer);

  // TODO Don't forget to choose printer's paper
  const PaperSize paper = PaperSize.mm58;
  final profile = await CapabilityProfile.load();

  return carTicket(paper, profile);

  // TEST PRINT
  // final PosPrintResult res =
  // await printerManager.printTicket(await testTicket(paper));

  // DEMO RECEIPT
  // final PosPrintResult res =  await printerManager.printTicket((await carTicket(paper, profile)));

  //showToast(res.msg);
}