/// `completions` satırı için kararlı birincil anahtar.
abstract final class CompletionRowId {
  static String forRecordAndDate(String recordId, String ymd) =>
      '${recordId}_$ymd';
}
