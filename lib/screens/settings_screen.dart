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
  static const _localeCodes = ['system', 'ja', 'en'];

  /// 新しい貯金箱をつくるときの初期通貨。合算・換算はしない。
  String? _defaultCurrency;

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
    if (!mounted) return;
    setState(() {
      _defaultCurrency = base;
      _localeCode = localeCode ?? 'system';
      _notifDay = day;
      _notifWeekday = wd;
      _notifHour = h;
      _notifMinute = m;
    });
  }

  /// 設定を保存し、通知を組み直す。結果は呼び出し側がユーザーに伝える。
  Future<NotificationResult> _applyNotifications(AppLocalizations l10n) async {
    final s = context.read<SettingsStore>();
    final notif = context.read<NotificationService>();
    await notif.cancelAll();

    if (_notifDay != null) {
      await s.setNotificationDay(_notifDay);
      await s.setNotificationWeekday(null);
      await s.setNotificationTime(_notifHour, _notifMinute);
      return notif.scheduleMonthly(
        id: 1,
        title: 'Target Vault',
        body: l10n.notifBodyMonthly,
        day: _notifDay!,
        hour: _notifHour,
        minute: _notifMinute,
      );
    }

    if (_notifWeekday != null) {
      await s.setNotificationDay(null);
      await s.setNotificationWeekday(_notifWeekday);
      await s.setNotificationTime(_notifHour, _notifMinute);
      return notif.scheduleWeekly(
        id: 1,
        title: 'Target Vault',
        body: l10n.notifBodyWeekly,
        weekday: _notifWeekday!,
        hour: _notifHour,
        minute: _notifMinute,
      );
    }

    await s.setNotificationDay(null);
    await s.setNotificationWeekday(null);
    return NotificationResult.scheduled;
  }

  Future<void> _onApplyPressed(AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final wasOff = _notifDay == null && _notifWeekday == null;
    final result = await _applyNotifications(l10n);
    if (!mounted) return;

    // 失敗を黙って飲み込むと「設定した」のに通知が来ない状態になる。
    // 必ず結果を伝え、次に取れる行動を示す。
    final String message;
    SnackBarAction? action;
    switch (result) {
      case NotificationResult.scheduled:
      case NotificationResult.unsupported:
        message = wasOff
            ? l10n.settingsNotifDisabledSnack
            : l10n.settingsNotifEnabledSnack;
      case NotificationResult.permissionDenied:
        message = l10n.notifPermissionDenied;
        action = SnackBarAction(
          label: l10n.retry,
          onPressed: () async {
            await context.read<NotificationService>().requestPermissions();
            if (mounted) await _onApplyPressed(l10n);
          },
        );
      case NotificationResult.failed:
        message = l10n.notifScheduleFailed;
        action = SnackBarAction(
          label: l10n.retry,
          onPressed: () => _onApplyPressed(l10n),
        );
    }

    messenger.showSnackBar(SnackBar(content: Text(message), action: action));
  }

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
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: _defaultCurrency == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Section(
                    title: l10n.settingsLanguage,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(_localeCode),
                      initialValue: _localeCode,
                      isExpanded: true,
                      items: _localeCodes
                          .map(
                            (code) => DropdownMenuItem(
                              value: code,
                              child: Text(
                                _languageLabel(l10n, code),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                  ),
                  const SizedBox(height: 28),
                  _Section(
                    title: l10n.settingsDefaultCurrency,
                    hint: l10n.settingsDefaultCurrencyHint,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(_defaultCurrency),
                      initialValue: _defaultCurrency,
                      isExpanded: true,
                      items: _currencies
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) async {
                        if (v == null) return;
                        await context.read<SettingsStore>().setBaseCurrency(v);
                        if (!mounted) return;
                        setState(() => _defaultCurrency = v);
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  _Section(
                    title: l10n.settingsNotifications,
                    hint: kIsWeb
                        ? l10n.settingsNotificationsWebUnavailable
                        : null,
                    child: Opacity(
                      opacity: kIsWeb ? 0.45 : 1,
                      child: IgnorePointer(
                        ignoring: kIsWeb,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppColors.elevatedCard(radius: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.settingsNotifTiming,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _timingSelector(l10n),
                              if (_notifDay != null) ...[
                                const SizedBox(height: 16),
                                _FieldLabel(l10n.settingsNotifWhichDay),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<int>(
                                  key: ValueKey(_notifDay),
                                  initialValue: _notifDay,
                                  isExpanded: true,
                                  items: List.generate(31, (i) {
                                    final d = i + 1;
                                    return DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                        l10n.settingsNotifMonthlyDay(d),
                                      ),
                                    );
                                  }),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _notifDay = v);
                                    }
                                  },
                                ),
                              ],
                              if (_notifWeekday != null) ...[
                                const SizedBox(height: 16),
                                _FieldLabel(l10n.settingsNotifWhichWeekday),
                                const SizedBox(height: 8),
                                _weekdayChips(),
                              ],
                              if (_notifMode != _NotifMode.off) ...[
                                const SizedBox(height: 16),
                                _FieldLabel(l10n.settingsNotifTime),
                                const SizedBox(height: 8),
                                _timeField(),
                              ],
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: () => _onApplyPressed(l10n),
                                child: Text(l10n.settingsNotifApply),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _timingSelector(AppLocalizations l10n) {
    // 文字サイズが大きいと3択が横に収まらないため、必要なら横スクロールさせる。
    return LayoutBuilder(
      builder: (context, constraints) {
        final selector = _timingSegments(l10n);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: selector,
          ),
        );
      },
    );
  }

  Widget _timingSegments(AppLocalizations l10n) {
    return SegmentedButton<int?>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment<int?>(value: 1, label: Text(l10n.settingsNotifMonthly)),
        ButtonSegment<int?>(value: 2, label: Text(l10n.settingsNotifWeekly)),
        ButtonSegment<int?>(value: null, label: Text(l10n.settingsNotifOff)),
      ],
      selected: {_notifMode.value},
      onSelectionChanged: (Set<int?> v) {
        final mode = v.firstOrNull;
        setState(() {
          switch (mode) {
            case 1:
              _notifDay = _notifDay ?? 1;
              _notifWeekday = null;
            case 2:
              _notifWeekday = _notifWeekday ?? DateTime.monday;
              _notifDay = null;
            default:
              _notifDay = null;
              _notifWeekday = null;
          }
        });
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: AppColors.surfaceLow,
        foregroundColor: AppColors.onSurfaceVariant,
        selectedBackgroundColor: AppColors.primary,
        selectedForegroundColor: AppColors.onPrimary,
        side: const BorderSide(color: AppColors.outline),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _weekdayChips() {
    return SingleChildScrollView(
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
              showCheckmark: false,
              onSelected: (_) => setState(() => _notifWeekday = wd),
              side: BorderSide(
                color: selected ? AppColors.primaryOutline : AppColors.outline,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _timeField() {
    final label =
        '${_notifHour.toString().padLeft(2, '0')}:'
        '${_notifMinute.toString().padLeft(2, '0')}';
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
              hour: _notifHour.clamp(0, 23),
              minute: _notifMinute.clamp(0, 59),
            ),
          );
          if (time == null || !mounted) return;
          setState(() {
            _notifHour = time.hour;
            _notifMinute = time.minute;
          });
        },
        icon: const Icon(Icons.schedule, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// 見出し + 補足 + 中身。設定画面のセクションはすべてこの形にそろえる。
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.hint});

  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.onBackground,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(
            hint!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
    );
  }
}
