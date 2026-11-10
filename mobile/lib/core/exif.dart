import 'dart:typed_data';

/// Minimal JPEG EXIF reader — ported from webapp `parseExif` (IFD0 ASCII only).

const Map<int, String> kExifAsciiNames = {
  0x010F: 'Make',
  0x0110: 'Model',
  0x0131: 'Software',
};

const List<String> kEditSoftwareHints = [
  'photoshop',
  'canva',
  'gimp',
  'picsart',
  'snapseed',
  'lightroom',
  'pixlr',
  'remini',
  'faceapp',
];

class ExifSummary {
  const ExifSummary({
    this.make,
    this.model,
    this.software,
    this.isJpeg = false,
    this.parseFailed = false,
  });

  final String? make;
  final String? model;
  final String? software;
  final bool isJpeg;
  final bool parseFailed;

  bool get hasEditSoftwareHint {
    final sw = software?.toLowerCase() ?? '';
    if (sw.isEmpty) return false;
    return kEditSoftwareHints.any(sw.contains);
  }

  bool get hasAnyTag =>
      (make != null && make!.isNotEmpty) ||
      (model != null && model!.isNotEmpty) ||
      (software != null && software!.isNotEmpty);
}

String _readAscii(ByteData view, int vOff, int count) {
  final buf = StringBuffer();
  for (var c = 0; c < count - 1; c++) {
    if (vOff + c >= view.lengthInBytes) break;
    final ch = view.getUint8(vOff + c);
    if (ch == 0) break;
    buf.writeCharCode(ch);
  }
  return buf.toString();
}

Map<String, String> _parseTiffIfd0(ByteData view, int tiffStart) {
  if (tiffStart + 8 > view.lengthInBytes) return {};
  final little = view.getUint16(tiffStart, Endian.big) == 0x4949;
  final endian = little ? Endian.little : Endian.big;
  final ifd0Rel = view.getUint32(tiffStart + 4, endian);
  final ifd0 = tiffStart + ifd0Rel;
  if (ifd0 + 2 > view.lengthInBytes) return {};
  final n = view.getUint16(ifd0, endian);
  final tags = <String, String>{};
  for (var i = 0; i < n; i++) {
    final eo = ifd0 + 2 + i * 12;
    if (eo + 12 > view.lengthInBytes) break;
    final tag = view.getUint16(eo, endian);
    final type = view.getUint16(eo + 2, endian);
    final count = view.getUint32(eo + 4, endian);
    final name = kExifAsciiNames[tag];
    if (name == null || type != 2) continue;
    final vOff = count <= 4
        ? eo + 8
        : tiffStart + view.getUint32(eo + 8, endian);
    tags[name] = _readAscii(view, vOff, count);
  }
  return tags;
}

Map<String, String>? _parseExifApp1(ByteData view, int segStart) {
  if (segStart + 6 > view.lengthInBytes) return null;
  if (view.getUint32(segStart, Endian.big) != 0x45786966) return null;
  if (view.getUint16(segStart + 4, Endian.big) != 0x0000) return null;
  return _parseTiffIfd0(view, segStart + 6);
}

ExifSummary parseJpegExif(Uint8List bytes) {
  try {
    final view = ByteData.sublistView(bytes);
    if (view.lengthInBytes < 4) {
      return const ExifSummary(parseFailed: true);
    }
    if (view.getUint16(0, Endian.big) != 0xFFD8) {
      return const ExifSummary(isJpeg: false);
    }
    var offset = 2;
    final len = view.lengthInBytes;
    while (offset < len - 4) {
      final marker = view.getUint16(offset, Endian.big);
      if ((marker & 0xFF00) != 0xFF00) break;
      final segLen = view.getUint16(offset + 2, Endian.big);
      if (marker == 0xFFE1) {
        final tags = _parseExifApp1(view, offset + 4);
        if (tags != null) {
          return ExifSummary(
            isJpeg: true,
            make: tags['Make'],
            model: tags['Model'],
            software: tags['Software'],
          );
        }
      }
      offset += 2 + segLen;
    }
    return const ExifSummary(isJpeg: true);
  } catch (_) {
    return const ExifSummary(parseFailed: true);
  }
}
