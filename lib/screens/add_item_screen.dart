import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:drift/drift.dart' show Value;

import '../database/app_database.dart';
import '../repositories/item_repository.dart';
import '../utils/confirm_dialog.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key, this.editItem});

  final Item? editItem;

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _categoryController = TextEditingController();
  String? _imagePath;
  DateTime? _targetDate;
  String _currency = 'JPY';
  bool _isLoading = false;

  static const _currencies = ['JPY', 'USD', 'EUR', 'GBP', 'CHF'];

  @override
  void initState() {
    super.initState();
    if (widget.editItem != null) {
      _titleController.text = widget.editItem!.title;
      _targetController.text = widget.editItem!.targetAmount.toStringAsFixed(
        widget.editItem!.currency == 'JPY' ? 0 : 2,
      );
      _categoryController.text = widget.editItem!.category ?? '';
      _imagePath = widget.editItem!.imagePath;
      _targetDate = widget.editItem!.targetDate;
      _currency = widget.editItem!.currency;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null || !mounted) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File(
      '${dir.path}/item_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await x.saveTo(dest.path);
    setState(() => _imagePath = dest.path);
  }

  void _clearImage() {
    setState(() => _imagePath = null);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final target = double.tryParse(_targetController.text.replaceAll(',', ''));
    if (title.isEmpty || target == null || target <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('タイトルと目標金額を入力してください')));
      return;
    }

    setState(() => _isLoading = true);
    final repo = context.read<ItemRepository>();

    if (widget.editItem != null) {
      await repo.updateItem(
        widget.editItem!.id,
        title: title,
        targetAmount: target,
        currency: _currency,
        imagePath: Value(_imagePath),
        targetDate: _targetDate,
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
      );
    } else {
      await repo.createItem(
        title: title,
        targetAmount: target,
        currency: _currency,
        imagePath: _imagePath,
        targetDate: _targetDate,
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteItem() async {
    final title = _titleController.text.trim().isEmpty
        ? widget.editItem!.title
        : _titleController.text.trim();
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'アイテムを削除',
      content: Text('「$title」を削除しますか？ 入出金履歴も一緒に削除されます。'),
      confirmLabel: '削除',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isLoading = true);
    await context.read<ItemRepository>().deleteItem(widget.editItem!.id);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('アイテムを削除しました')));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editItem != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.9)),
        ),
        title: Text(
          isEdit ? 'アイテムを編集' : 'アイテムを追加',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    '保存',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: _imagePath != null && File(_imagePath!).existsSync()
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(File(_imagePath!), fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton.filled(
                                onPressed: _clearImage,
                                icon: const Icon(Icons.close, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(6),
                                  minimumSize: const Size(36, 36),
                                ),
                                tooltip: '写真を削除',
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '写真を追加（任意）',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'タイトル',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(_currency == 'JPY' ? r'[\d]' : r'[\d.]'),
                ),
              ],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                labelText: '目標金額',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixText: _currency,
                suffixStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '通貨',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
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
              onChanged: (v) => setState(() => _currency = v ?? 'JPY'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'カテゴリ（任意）',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            _targetDate ??
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null && mounted) setState(() => _targetDate = date);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '目標日（任意）',
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      child: Text(
                        _targetDate != null
                            ? '${_targetDate!.year}/${_targetDate!.month}/${_targetDate!.day}'
                            : '未設定',
                        style: TextStyle(
                          color: _targetDate != null
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_targetDate != null) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: () => setState(() => _targetDate = null),
                      child: Text(
                        'クリア',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (widget.editItem != null) ...[
              const SizedBox(height: 32),
              Center(
                child: TextButton.icon(
                  onPressed: _isLoading ? null : _deleteItem,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  label: const Text(
                    'このアイテムを削除',
                    style: TextStyle(color: Color(0xFFEF4444), fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
