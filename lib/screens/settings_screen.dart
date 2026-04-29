import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/settings_store.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _currencies = ['JPY', 'USD', 'EUR', 'GBP', 'CHF'];
  static const _weekdays = ['日', '月', '火', '水', '木', '金', '土'];

  String? _baseCurrency;
  int? _notifDay;
  int? _notifWeekday;
  int _notifHour = 20;
  int _notifMinute = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = context.read<SettingsStore>();
    final base = await s.getBaseCurrency();
    final day = await s.getNotificationDay();
    final wd = await s.getNotificationWeekday();
    final h = await s.getNotificationHour();
    final m = await s.getNotificationMinute();
    if (mounted) {
      setState(() {
        _baseCurrency = base;
        _notifDay = day;
        _notifWeekday = wd;
        _notifHour = h;
        _notifMinute = m;
      });
    }
  }

  Future<void> _applyNotifications() async {
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
        body: '今日の入金を記録しましょう',
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
        body: '今週の入金を記録しましょう',
        weekday: _notifWeekday!,
        hour: _notifHour,
        minute: _notifMinute,
      );
    } else {
      await s.setNotificationDay(null);
      await s.setNotificationWeekday(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        title: Text(
          '設定',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _baseCurrency == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ベース通貨',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _baseCurrency,
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                  Text(
                    '通知',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '日付指定（給料日など）',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: List.generate(31, (i) {
                            final day = i + 1;
                            final selected = _notifDay == day;
                            return FilterChip(
                              label: Text('$day日'),
                              selected: selected,
                              onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    _notifDay = day;
                                    _notifWeekday = null;
                                  } else {
                                    _notifDay = null;
                                  }
                                });
                              },
                              selectedColor: const Color(
                                0xFF6366F1,
                              ).withValues(alpha: 0.3),
                              checkmarkColor: const Color(0xFF6366F1),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '曜日指定',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: List.generate(7, (i) {
                            final wd = i + 1;
                            final selected = _notifWeekday == wd;
                            return FilterChip(
                              label: Text(_weekdays[i]),
                              selected: selected,
                              onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    _notifWeekday = wd;
                                    _notifDay = null;
                                  } else {
                                    _notifWeekday = null;
                                  }
                                });
                              },
                              selectedColor: const Color(
                                0xFF6366F1,
                              ).withValues(alpha: 0.3),
                              checkmarkColor: const Color(0xFF6366F1),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              '時刻',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            FilledButton.icon(
                              onPressed: () async {
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
                              icon: const Icon(Icons.schedule, size: 20),
                              label: Text(
                                '${_notifHour.toString().padLeft(2, '0')}:${_notifMinute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0D0D0D),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final wasOff =
                                _notifDay == null && _notifWeekday == null;
                            await _applyNotifications();
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  wasOff ? '通知をオフにしました' : '通知を設定しました',
                                ),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('通知を設定'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
