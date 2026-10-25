import 'package:drift/drift.dart';

/// A deck is a named collection of cards.
@DataClassName('Deck')
class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// True when the row has local changes that still need to be pushed to Supabase.
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A flashcard, belonging to a deck.
@DataClassName('CardRow')
class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId =>
      text().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get front => text()();
  TextColumn get back => text()();

  /// Next time this card is due for review.
  DateTimeColumn get dueAt => dateTime()();

  /// Interval in whole days. `0` means the card is in relearning.
  IntColumn get intervalDays => integer().withDefault(const Constant(0))();
  RealColumn get ease => real().withDefault(const Constant(2.5))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One graded review. Append-only, so progress data stays trustworthy.
@DataClassName('Review')
class Reviews extends Table {
  TextColumn get id => text()();
  TextColumn get cardId => text().references(Cards, #id, onDelete: KeyAction.cascade)();

  /// `0` = lupa, `1` = ragu, `2` = ingat.
  IntColumn get rating => integer()();
  DateTimeColumn get reviewedAt => dateTime()();
  IntColumn get prevIntervalDays => integer()();
  IntColumn get newIntervalDays => integer()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Small key/value store for sync bookkeeping (e.g. last pulled timestamp).
@DataClassName('SyncState')
class SyncStates extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
