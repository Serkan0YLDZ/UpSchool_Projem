/// SQL CREATE TABLE ifadelerini ve sütun sabitlerini içerir.
/// Yalnızca string sabitleri tutar — başka hiçbir iş yapmaz (SRP).
abstract final class TableConstants {
  // ── Tablo adları ───────────────────────────────────────────────────────────

  static const String calendarEvents = 'calendar_events';
  static const String habits = 'habits';
  static const String todos = 'todos';
  static const String habitDayLogs = 'habit_day_logs';
  static const String streakSnapshots = 'streak_snapshots';

  // ── CREATE TABLE ifadeleri ─────────────────────────────────────────────────

  static const String createCalendarEvents = '''
    CREATE TABLE $calendarEvents (
      id             TEXT PRIMARY KEY,
      title          TEXT NOT NULL,
      description    TEXT,
      starts_at      TEXT NOT NULL,
      ends_at        TEXT,
      is_all_day     INTEGER NOT NULL DEFAULT 0,
      created_at     TEXT NOT NULL,
      updated_at     TEXT NOT NULL,
      deleted_at     TEXT,
      local_revision INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String createHabits = '''
    CREATE TABLE $habits (
      id               TEXT PRIMARY KEY,
      title            TEXT NOT NULL,
      schedule_kind    TEXT NOT NULL DEFAULT 'weekly',
      interval_days    INTEGER,
      weekly_days_mask INTEGER,
      anchor_date      TEXT NOT NULL,
      target_progress  INTEGER NOT NULL DEFAULT 100,
      target_unit      TEXT,
      icon_key         TEXT,
      icon_color_argb  INTEGER,
      created_at       TEXT NOT NULL,
      updated_at       TEXT NOT NULL,
      deleted_at       TEXT,
      local_revision   INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String createTodos = '''
    CREATE TABLE $todos (
      id             TEXT PRIMARY KEY,
      title          TEXT NOT NULL,
      description    TEXT,
      due_date       TEXT,
      priority       TEXT NOT NULL DEFAULT 'medium',
      is_completed   INTEGER NOT NULL DEFAULT 0,
      completed_at   TEXT,
      created_at     TEXT NOT NULL,
      updated_at     TEXT NOT NULL,
      deleted_at     TEXT,
      local_revision INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String createHabitDayLogs = '''
    CREATE TABLE $habitDayLogs (
      id             TEXT PRIMARY KEY,
      habit_id       TEXT NOT NULL REFERENCES $habits(id),
      calendar_date  TEXT NOT NULL,
      status         TEXT NOT NULL DEFAULT 'pending',
      skip_source    TEXT,
      created_at     TEXT NOT NULL,
      updated_at     TEXT NOT NULL,
      deleted_at     TEXT,
      local_revision INTEGER NOT NULL DEFAULT 0,
      UNIQUE(habit_id, calendar_date)
    )
  ''';

  static const String createStreakSnapshots = '''
    CREATE TABLE $streakSnapshots (
      habit_id                  TEXT PRIMARY KEY REFERENCES $habits(id),
      current_streak            INTEGER NOT NULL DEFAULT 0,
      longest_streak            INTEGER NOT NULL DEFAULT 0,
      series_state              TEXT NOT NULL DEFAULT 'active',
      series_closed_after       TEXT,
      last_done_date            TEXT,
      skip_used_this_week       INTEGER NOT NULL DEFAULT 0,
      skip_consumed_week_key    TEXT,
      open_miss_date            TEXT,
      recovery_scheduled_date   TEXT,
      recovery_applied          INTEGER NOT NULL DEFAULT 0,
      streak_frozen_before_miss INTEGER,
      updated_at                TEXT NOT NULL
    )
  ''';
}
