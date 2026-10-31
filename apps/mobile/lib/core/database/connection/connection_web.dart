import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// SQLite WASM untuk Flutter web (dipakai untuk uji tampilan di Chrome).
///
/// Butuh `web/sqlite3.wasm` dan `web/drift_worker.js`; keduanya disertakan di
/// folder `web/`.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'recally',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
