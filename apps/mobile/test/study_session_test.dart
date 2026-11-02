import 'package:flutter_test/flutter_test.dart';
import 'package:recally/core/database/app_database.dart';
import 'package:recally/features/study/domain/srs_engine.dart';
import 'package:recally/features/study/domain/study_session.dart';

CardRow card(String id) => CardRow(
  id: id,
  deckId: 'deck',
  front: 'Pertanyaan $id',
  back: 'Jawaban $id',
  dueAt: DateTime(2026, 1, 1),
  intervalDays: 0,
  ease: 2.5,
  reps: 0,
  lapses: 0,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  dirty: false,
);

void main() {
  test('jawaban kosong tidak membuka perbandingan', () {
    final session = StudySession(cards: [card('a')]);

    session.submitAnswer('   ');

    expect(session.step, StudyStep.jawab);
    expect(session.current.answer, isEmpty);
  });

  test('alur tulis jawaban maju sampai kartu terakhir', () {
    final session = StudySession(cards: [card('a'), card('b')]);

    expect(session.position, 1);
    expect(session.total, 2);
    expect(session.progress, 0);

    session.submitAnswer('  energi  ');

    expect(session.step, StudyStep.nilai);
    expect(session.current.answer, 'energi');
    expect(session.progress, 0, reason: 'belum dinilai');

    session.grade(RecallRating.ingat);

    expect(session.finished, isFalse);
    expect(session.position, 2);
    expect(session.step, StudyStep.jawab);
    expect(session.progress, 0.5);

    session.submitAnswer('jawaban kedua');
    session.grade(RecallRating.lupa);

    expect(session.finished, isTrue);
    expect(session.progress, 1);
    expect(session.countOf(RecallRating.ingat), 1);
    expect(session.countOf(RecallRating.lupa), 1);
    expect(session.countOf(RecallRating.ragu), 0);
    expect(session.lapsedCards.map((value) => value.id), ['b']);
  });

  test('mode hafalan membalik kartu tanpa mengetik', () {
    final session = StudySession(cards: [card('a')], mode: StudyMode.hafalan);

    session.reveal();

    expect(session.step, StudyStep.nilai);
    expect(session.current.answer, isEmpty);

    session.grade(RecallRating.ragu);

    expect(session.finished, isTrue);
    expect(session.countOf(RecallRating.ragu), 1);
  });

  test('nilai diabaikan sebelum kartu dibuka', () {
    final session = StudySession(cards: [card('a')]);

    session.grade(RecallRating.ingat);

    expect(session.current.rating, isNull);
    expect(session.finished, isFalse);
    expect(session.step, StudyStep.jawab);
  });

  test('mode bisa diganti di tengah sesi', () {
    final session = StudySession(cards: [card('a')]);

    session.setMode(StudyMode.hafalan);
    expect(session.mode, StudyMode.hafalan);

    session.reveal();
    session.setMode(StudyMode.tulis);
    expect(session.mode, StudyMode.tulis);
    expect(session.step, StudyStep.nilai);
  });
}
