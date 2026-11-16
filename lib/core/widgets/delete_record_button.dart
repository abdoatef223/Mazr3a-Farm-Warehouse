import 'package:flutter/material.dart';

import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/widgets/confirm_delete_dialog.dart';

class DeleteRecordButton extends StatefulWidget {
  const DeleteRecordButton({
    required this.onConfirmedDelete,
    super.key,
    this.isDeleting = false,
    this.dialogTitle,
    this.dialogMessage,
  });

  final Future<void> Function() onConfirmedDelete;
  final bool isDeleting;
  final String? dialogTitle;
  final String? dialogMessage;

  @override
  State<DeleteRecordButton> createState() => _DeleteRecordButtonState();
}

class _DeleteRecordButtonState extends State<DeleteRecordButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (widget.isDeleting) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.danger,
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: 'Delete record',
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: _isHovered
              ? colors.danger.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              final confirmed = await ConfirmDeleteDialog.show(
                context,
                title: widget.dialogTitle,
                message: widget.dialogMessage,
              );
              if (confirmed && context.mounted) {
                await widget.onConfirmedDelete();
              }
            },
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: _isHovered ? colors.danger : colors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
