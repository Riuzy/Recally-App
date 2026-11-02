import '../../../core/database/app_database.dart';
import 'srs_engine.dart';

/// Cara menjawab kartu selama sesi.
enum StudyMode {
  /// Mengetik jawaban sebelum jawaban benar dibuka.
  tulis,

  /// Membalik kartu tanpa mengetik.
  hafalan,
}

/// Posisi di dalam satu kartu.
enum StudyStep {
  /// Pertanyaan masih terbuka; pengguna menulis atau membalik kartu.
  jawab,

  /// Jawaban sudah terbuka; pengguna menilai ingatannya.
  nilai,
}

/// Satu kartu beserta jawaban dan nilai yang diberikan pada sesi ini.
class StudyEntry {
  StudyEntry(this.card);

  final CardRow card;
  String answer = '';
  RecallRating? rating;

  bool get isGraded => rating != null;
}

/// State mesin sesi belajar. Murni (tanpa UI dan tanpa database) supaya alur
/// penilaian bisa diuji tanpa widget.
class StudySession {
  StudySession({required List<CardRow> cards, StudyMode mode = StudyMode.tulis})
    : entries = List.unmodifiable(cards.map(StudyEntry.new)),
      _mode = mode;

  final List<StudyEntry> entries;

  StudyMode _mode;
  int _index = 0;
  StudyStep _step = StudyStep.jawab;
  bool _finished = false;

  StudyMode get mode => _mode;
  StudyStep get step => _step;
  int get index => _index;
  int get position => _index + 1;
  int get total => entries.length;
  bool get isEmpty => entries.isEmpty;
  bool get isLast => _index >= entries.length - 1;
  bool get finished => _finished;

  StudyEntry get current => entries[_index];

  int get answeredCount => entries.where((entry) => entry.isGraded).length;

  /// 0..1 untuk bilah progres.
  double get progress => total == 0 ? 0 : answeredCount / total;

  int countOf(RecallRating rating) =>
      entries.where((entry) => entry.rating == rating).length;

  /// Kartu yang dinilai "Lupa"; dipakai untuk mengulang tanpa menunggu 10 menit.
  List<CardRow> get lapsedCards => entries
      .where((entry) => entry.rating == RecallRating.lupa)
      .map((entry) => entry.card)
      .toList(growable: false);

  /// Menyimpan jawaban lalu membuka perbandingan. Jawaban kosong ditolak.
  void submitAnswer(String text) {
    if (_finished || _step != StudyStep.jawab) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    current.answer = trimmed;
    _step = StudyStep.nilai;
  }

  /// Membuka jawaban tanpa mengetik (tombol "Lihat jawaban" / mode hafalan).
  void reveal() {
    if (_finished || _step != StudyStep.jawab) return;
    _step = StudyStep.nilai;
  }

  /// Menyimpan nilai kartu sekarang lalu maju ke kartu berikutnya.
  void grade(RecallRating rating) {
    if (_finished || _step != StudyStep.nilai) return;
    current.rating = rating;

    if (isLast) {
      _finished = true;
      return;
    }

    _index++;
    _step = StudyStep.jawab;
  }

  void setMode(StudyMode mode) {
    _mode = mode;
  }
}
