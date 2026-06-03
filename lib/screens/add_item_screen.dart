import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/item_status.dart';
import '../models/vault_item.dart';
import '../repositories/item_repository.dart';
import '../theme/app_colors.dart';
import '../utils/confirm_dialog.dart';
import '../utils/item_image_ref.dart';
import '../utils/thousands_separator_input_formatter.dart';
import '../widgets/item_cover_image.dart';
import 'add_item_image.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key, this.editItem});

  final VaultItem? editItem;

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
  bool _purchasedOnCredit = false;

  static const _currencies = ['JPY', 'USD', 'EUR', 'GBP', 'CHF'];

  @override
  void initState() {
    super.initState();
    if (widget.editItem != null) {
      _titleController.text = widget.editItem!.title;
      final isJpy = widget.editItem!.currency == 'JPY';
      _targetController.text = isJpy
          ? NumberFormat('#,###').format(widget.editItem!.targetAmount.toInt())
          : NumberFormat('#,##0.00').format(widget.editItem!.targetAmount);
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
    try {
      if (kIsWeb) {
        final bytes = await x.readAsBytes();
        if (!mounted) return;
        setState(
          () => _imagePath = 'data:image/jpeg;base64,${base64Encode(bytes)}',
        );
        return;
      }
      final path = await savePickedImageToAppDir(x);
      if (!mounted) return;
      if (path == null) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imageSaveFailed),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
      setState(() => _imagePath = path);
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.imageSaveFailed),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _clearImage() {
    setState(() => _imagePath = null);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final target = double.tryParse(_targetController.text.replaceAll(',', ''));
    if (title.isEmpty || target == null || target <= 0) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.titleAndTargetRequired)),
      );
      return;
    }

    setState(() => _isLoading = true);
    final repo = context.read<ItemRepository>();

    if (widget.editItem != null) {
      final id = widget.editItem!.id;
      final wasSaving = widget.editItem!.status == ItemStatus.saving;
      await repo.updateItem(
        id,
        title: title,
        targetAmount: target,
        currency: _currency,
        targetDate: _targetDate,
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        imagePath: _imagePath,
      );
      if (wasSaving && _purchasedOnCredit) {
        final ok = await repo.convertSavingItemToRepayingOnCredit(
          id,
          targetAmount: target,
        );
        if (!ok) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.convertToRepayingFailed),
                backgroundColor: AppColors.warning,
              ),
            );
          }
          return;
        }
      }
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
        purchasedOnCredit: _purchasedOnCredit,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteItem() async {
    final title = _titleController.text.trim().isEmpty
        ? widget.editItem!.title
        : _titleController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.deleteItemTitle,
      content: Text(l10n.deleteItemConfirm(title)),
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isLoading = true);
    await context.read<ItemRepository>().deleteItem(widget.editItem!.id);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.itemDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editItem != null;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: AppColors.onSurfaceAlpha(0.9)),
        ),
        title: Text(
          isEdit ? l10n.editItem : l10n.addItem,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontFamily: 'Manrope',
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
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    l10n.save,
                    style: const TextStyle(
                      color: AppColors.secondary,
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
                height: 190,
                decoration: AppColors.elevatedCard(radius: 24),
                child: itemImageRefIsDisplayable(_imagePath)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ItemCoverImage(
                              imageRef: _imagePath!,
                              fit: BoxFit.cover,
                            ),
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
                                tooltip: l10n.removePhoto,
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
                                  child: Icon(
                                    Icons.edit,
                                    color: AppColors.onSurfaceAlpha(1),
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
                            color: AppColors.onSurfaceAlpha(0.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.addPhotoOptional,
                            style: TextStyle(
                              color: AppColors.onSurfaceAlpha(0.5),
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
              style: TextStyle(
                color: AppColors.onSurfaceAlpha(1),
                fontSize: 16,
              ),
              decoration: InputDecoration(labelText: l10n.fieldTitle),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                ThousandsSeparatorInputFormatter(
                  decimalAllowed: _currency != 'JPY',
                ),
              ],
              style: TextStyle(
                color: AppColors.onSurfaceAlpha(1),
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: l10n.fieldTargetAmount,
                suffixText: _currency,
                suffixStyle: TextStyle(color: AppColors.onSurfaceAlpha(0.6)),
              ),
            ),
            if (widget.editItem == null ||
                widget.editItem!.status == ItemStatus.saving) ...[
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.purchasedOnCreditTitle,
                  style: TextStyle(
                    color: AppColors.onSurfaceAlpha(1),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  widget.editItem == null
                      ? l10n.purchasedOnCreditSubtitleNew
                      : l10n.purchasedOnCreditSubtitleEdit,
                  style: TextStyle(
                    color: AppColors.onSurfaceAlpha(0.55),
                    fontSize: 13,
                  ),
                ),
                value: _purchasedOnCredit,
                onChanged: (v) => setState(() => _purchasedOnCredit = v),
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(_currency),
              initialValue: _currency,
              dropdownColor: AppColors.surface,
              style: TextStyle(color: AppColors.onSurfaceAlpha(1)),
              decoration: InputDecoration(labelText: l10n.fieldCurrency),
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _currency = v ?? 'JPY'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              style: TextStyle(
                color: AppColors.onSurfaceAlpha(1),
                fontSize: 16,
              ),
              decoration: InputDecoration(labelText: l10n.fieldCategoryOptional),
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
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (date != null && mounted) {
                        setState(() => _targetDate = date);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.fieldTargetDateOptional,
                      ),
                      child: Text(
                        _targetDate != null
                            ? DateFormat.yMMMd(locale).format(_targetDate!)
                            : l10n.targetDateUnset,
                        style: TextStyle(
                          color: _targetDate != null
                              ? AppColors.onSurfaceAlpha(1)
                              : AppColors.onSurfaceAlpha(0.5),
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
                        l10n.clear,
                        style: TextStyle(
                          color: AppColors.onSurfaceAlpha(0.7),
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
                    color: AppColors.onSurfaceAlpha(0.5),
                  ),
                  label: Text(
                    l10n.deleteThisItem,
                    style: TextStyle(color: AppColors.error, fontSize: 14),
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
