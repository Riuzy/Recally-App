/// Hasil parsing teks "depan;belakang" untuk pembuatan kartu massal.
class ParsedCards {
  const ParsedCards({required this.cards, required this.invalidLines});

  final List<({String front, String back})> cards;

  /// Nomor baris (1-based) yang tidak bisa dipakai, untuk pesan error.
  final List<int> invalidLines;

  bool get hasInvalid => invalidLines.isNotEmpty;
}

/// Memecah teks menjadi kartu. Satu baris = satu kartu, dipisah `;` pertama.
///
/// Baris kosong dilewati. Baris tanpa pemisah, atau dengan sisi kosong,
/// dilaporkan sebagai tidak valid dan tidak ikut dibuat.
ParsedCards parseCardLines(String input) {
  final cards = <({String front, String back})>[];
  final invalid = <int>[];
  final lines = input.split(RegExp(r'\r?\n'));

  for (var index = 0; index < lines.length; index++) {
    final line = lines[index].trim();
    if (line.isEmpty) continue;

    final separator = line.indexOf(';');
    if (separator <= 0) {
      invalid.add(index + 1);
      continue;
    }

    final front = line.substring(0, separator).trim();
    final back = line.substring(separator + 1).trim();
    if (front.isEmpty || back.isEmpty) {
      invalid.add(index + 1);
      continue;
    }

    cards.add((front: front, back: back));
  }

  return ParsedCards(cards: cards, invalidLines: invalid);
}
