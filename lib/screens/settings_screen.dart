import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_locale_controller.dart';
import '../database/settings_store.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';

/// 通知タイミングのモード（SegmentedButton の value 用）
enum _NotifMode {
  monthly(1),
  weekly(2),
  off(null);

  const _NotifMode(this.value);
  final int? value;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _currencies = ['JPY', 'USD', 'EUR', 'GBP', 'CHF'];

  String? _baseCurrency;
  /// Dropdown value: `system`, `ja`, `en`
  String _localeCode = 'system';
  int? _notifDay;
  int? _notifWeekday;
  int _notifHour = 20;
  int _notifMinute = 0;

  _NotifMode get _notifMode {
    if (_notifDay != null) return _NotifMode.monthly;
    if (_notifWeekday != null) return _NotifMode.weekly;
    return _NotifMode.off;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = context.read<SettingsStore>();
    final base = await s.getBaseCurrency();
    final localeCode = await s.getAppLocaleCode();
    final day = await s.getNotificationDay();
    final wd = await s.getNotificationWeekday();
    final h = await s.getNotificationHour();
    final m = await s.getNotificationMinute();
    if (mounted) {
      setState(() {
        _baseCurrency = base;
        _localeCode = localeCode ?? 'system';
        _notifDay = day;
        _notifWeekday = wd;
        _notifHour = h;
        _notifMinute = m;
      });
    }
  }

  Future<void> _applyNotifications(AppLocalizations l10n) async {
    final s = context.read<SettingsStore>();
    final notif = context.read<NotificationService>();
    await notif.cancelAll();

    if (_notifDay != null) {
      await s.setNotificationDay(_notifDay);
      await s.setNotificationWeekday(null);
      await s.setNotificationTime(_notifHour, _notifMinute);
      await notif.scheduleDaily(
        id: 1,
        title: 'Target Vault',
        body: l10n.notifBodyDaily,
        hour: _notifHour,
        minute: _notifMinute,
      );
    } else if (_notifWeekday != null) {
      await s.setNotificationDay(null);
      await s.setNotificationWeekday(_notifWeekday);
      await s.setNotificationTime(_notifHour, _notifMinute);
      await notif.scheduleWeekly(
        id: 1,
        title: 'Target Vault',
        body: l10n.notifBodyWeekly,
        weekday: _notifWeekday!,
        hour: _notifHour,
        minute: _notifMinute,
      );
    } else {
      await s.setNotificationDay(null);
      await s.setNotificationWeekday(null);
    }
  }

  TextStyle _sectionLabelStyle() =>
      TextStyle(fontSize: 14, color: AppColors.onSurfaceAlpha(0.6));

  static const _localeCodes = ['system', 'ja', 'en'];

  /// Dart [DateTime.weekday]: 1=Mon .. 7=Sun
  String _weekdayLabel(BuildContext context, int weekday) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.E(locale).format(DateTime(2024, 1, weekday));
  }

  String _languageLabel(AppLocalizations l10n, String code) {
    switch (code) {
      case 'ja':
        return l10n.languageJapanese;
      case 'en':
        return l10n.languageEnglish;
      default:
        return l10n.languageSystem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.onSurfaceAlpha(0.9)),
        ),
        title: Text(
          l10n.settingsTitle,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontFamily: 'Manrope',
          ),
        ),
      ),
      body: _baseCurrency == null
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.settingsLanguage, style: _sectionLabelStyle()),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_localeCode),
                    initialValue: _localeCode,
                    dropdownColor: AppColors.surface,
                    style: TextStyle(color: AppColors.onSurfaceAlpha(1)),
                    decoration: InputDecoration(
                      fillColor: AppColors.surfaceLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _localeCodes
                        .map(
                          (code) => DropdownMenuItem(
                            value: code,
                            child: Text(_languageLabel(l10n, code)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      await context.read<AppLocaleController>().setLocaleCode(
                        v,
                      );
                      if (!mounted) return;
                      setState(() => _localeCode = v);
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(l10n.settingsBaseCurrency, style: _sectionLabelStyle()),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_baseCurrency),
                    initialValue: _baseCurrency,
                    dropdownColor: AppColors.surface,
                    style: TextStyle(color: AppColors.onSurfaceAlpha(1)),
                    decoration: InputDecoration(
                      fillColor: AppColors.surfaceLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      final s = context.read<SettingsStore>();
                      await s.setBaseCurrency(v);
                      if (!mounted) return;
                      setState(() => _baseCurrency = v);
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(l10n.settingsNotifications, style: _sectionLabelStyle()),
                  const SizedBox(height: 8),
                  if (kIsWeb) ...[
                    Text(
                      l10n.settingsNotificationsWebUnavailable,
                      style: TextStyle(
                        color: AppColors.onSurfaceAlpha(0.65),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Opacity(
                    opacity: kIsWeb ? 0.45 : 1,
                    child: IgnorePointer(
                      ignoring: kIsWeb,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppColors.elevatedCard(radius: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.settingsNotifTiming,
                              style: TextStyle(
                                color: AppColors.onSurfaceAlpha(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<int?>(
                              segments: [
                                ButtonSegment<int?>(
                                  value: 1,
                                  label: Text(l10n.settingsNotifMonthly),
                                  icon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                  ),
                                ),
                                ButtonSegment<int?>(
                                  value: 2,
                                  label: Text(l10n.settingsNotifWeekly),
                                  icon: const Icon(Icons.date_range, size: 18),
                                ),
                                ButtonSegment<int?>(
                                  value: null,
                                  label: Text(l10n.settingsNotifOff),
                                  icon: const Icon(
                                    Icons.notifications_off_outlined,
                                    size: 18,
                                  ),
                                ),
                              ],
                              selected: {_notifMode.value},
                              onSelectionChanged: (Set<int?> v) {
                                final mode = v.firstOrNull;
                                setState(() {
                                  switch (mode) {
                                    case 1:
                                      _notifDay = _notifDay ?? 1;
                                      _notifWeekday = null;
                                      break;
                                    case 2:
                                      _notifWeekday =
                                          _notifWeekday ?? DateTime.monday;
                                      _notifDay = null;
                                      break;
                                    default:
                                      _notifDay = null;
                                      _notifWeekday = null;
                                  }
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.resolveWith((states) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return AppColors.primary.withValues(
                                          alpha: 0.25,
                                        );
                                      }
                                      return AppColors.background;
                                    }),
                                foregroundColor:
                                    WidgetStateProperty.resolveWith((states) {
                                      return states.contains(
                                            WidgetState.selected,
                                          )
                                          ? AppColors.primaryLight
                                          : AppColors.onSurfaceAlpha(0.7);
                                    }),
                                side: WidgetStateProperty.resolveWith((states) {
                                  return BorderSide(
                                    color: states.contains(WidgetState.selected)
                                        ? AppColors.primary.withValues(
                                            alpha: 0.5,
                                          )
                                        : AppColors.onSurfaceAlpha(0.12),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 毎月○日: 日付ドロップダウン
                            if (_notifDay != null) ...[
                              Text(
                                l10n.settingsNotifWhichDay,
                                style: TextStyle(
                                  color: AppColors.onSurfaceAlpha(0.7),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                key: ValueKey(_notifDay),
                                initialValue: _notifDay,
                                dropdownColor: AppColors.surface,
                                decoration: InputDecoration(
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                                style: TextStyle(
                                  color: AppColors.onSurfaceAlpha(1),
                                  fontSize: 15,
                                ),
                                items: List.generate(31, (i) {
                                  final d = i + 1;
                                  return DropdownMenuItem(
                                    value: d,
                                    child: Text(l10n.settingsNotifMonthlyDay(d)),
                                  );
                                }),
                                onChanged: (v) {
                                  if (v != null) setState(() => _notifDay = v);
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                            // 毎週○曜日: 曜日チップ（1行）
                            if (_notifWeekday != null) ...[
                              Text(
                                l10n.settingsNotifWhichWeekday,
                                style: TextStyle(
                                  color: AppColors.onSurfaceAlpha(0.7),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(7, (i) {
                                    final wd = i + 1;
                                    final selected = _notifWeekday == wd;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FilterChip(
                                        label: Text(_weekdayLabel(context, wd)),
                                        selected: selected,
                                        onSelected: (_) {
                                          setState(() => _notifWeekday = wd);
                                        },
                                        selectedColor: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        checkmarkColor: AppColors.primary,
                                        backgroundColor: AppColors.background,
                                        side: BorderSide(
                                          color: selected
                                              ? AppColors.primary.withValues(
                                                  alpha: 0.6,
                                                )
                                              : AppColors.onSurfaceAlpha(0.12),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            // 時刻（毎月/毎週どちらか選択時のみ強調）
                            if (_notifDay != null || _notifWeekday != null) ...[
                              Text(
                                l10n.settingsNotifTime,
                                style: TextStyle(
                                  color: AppColors.onSurfaceAlpha(0.7),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                      hour: _notifHour.clamp(0, 23),
                                      minute: _notifMinute.clamp(0, 59),
                                    ),
                                  );
                                  if (time != null && mounted) {
                                    setState(() {
                                      _notifHour = time.hour;
                                      _notifMinute = time.minute;
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLow,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.onSurfaceAlpha(0.08),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 20,
                                        color: AppColors.onSurfaceAlpha(0.8),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${_notifHour.toString().padLeft(2, '0')}:${_notifMinute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: AppColors.onSurfaceAlpha(1),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            FilledButton(
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final wasOff =
                                    _notifDay == null && _notifWeekday == null;
                                await _applyNotifications(l10n);
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      wasOff
                                          ? l10n.settingsNotifDisabledSnack
                                          : l10n.settingsNotifEnabledSnack,
                                    ),
                                    backgroundColor: AppColors.surface,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.primaryTextOnLight,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(l10n.settingsNotifApply),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
