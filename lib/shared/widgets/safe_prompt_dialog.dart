import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';

typedef PromptValidator = String? Function(String value);

class SafePromptDialog extends StatefulWidget {
  final String title;
  final String label;
  final String cancelLabel;
  final String confirmLabel;
  final String initialValue;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final PromptValidator? validator;
  final List<TextInputFormatter>? inputFormatters;

  const SafePromptDialog({
    super.key,
    required this.title,
    required this.label,
    required this.cancelLabel,
    required this.confirmLabel,
    this.initialValue = '',
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.inputFormatters,
  });

  @override
  State<SafePromptDialog> createState() => _SafePromptDialogState();
}

class _SafePromptDialogState extends State<SafePromptDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  void _submit() {
    final value = _controller.text.trim();
    final error = widget.validator?.call(value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, style: _titleStyle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        inputFormatters: widget.inputFormatters,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        decoration: InputDecoration(labelText: widget.label, errorText: _error),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      actions: [
        _DialogActions(
          cancelLabel: widget.cancelLabel,
          confirmLabel: widget.confirmLabel,
          onConfirm: _submit,
        ),
      ],
    );
  }
}

class SafePasswordDialog extends StatefulWidget {
  final String title;
  final String cancelLabel;
  final String confirmLabel;
  final bool requireConfirmation;

  const SafePasswordDialog({
    super.key,
    required this.title,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.requireConfirmation,
  });

  @override
  State<SafePasswordDialog> createState() => _SafePasswordDialogState();
}

class _SafePasswordDialogState extends State<SafePasswordDialog> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  String? _error;

  void _submit() {
    final t = AppLocalizations.of(context);
    if (_password.text.length < 8) {
      setState(
        () => _error = t?.minimumPassword ?? 'Use at least 8 characters.',
      );
      return;
    }
    if (widget.requireConfirmation && _password.text != _confirmation.text) {
      setState(
        () => _error = t?.passwordsDoNotMatch ?? 'Passwords do not match.',
      );
      return;
    }
    Navigator.of(context).pop(_password.text);
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title, style: _titleStyle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _password,
            obscureText: true,
            autofocus: true,
            textInputAction: widget.requireConfirmation
                ? TextInputAction.next
                : TextInputAction.done,
            onSubmitted: (_) {
              if (!widget.requireConfirmation) _submit();
            },
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: InputDecoration(
              labelText: 'Password',
              helperText: t?.minimumEightCharacters ?? 'At least 8 characters',
              errorText: _error,
            ),
          ),
          if (widget.requireConfirmation) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _confirmation,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: t?.confirmPassword ?? 'Confirm password',
              ),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      actions: [
        _DialogActions(
          cancelLabel: widget.cancelLabel,
          confirmLabel: widget.confirmLabel,
          onConfirm: _submit,
        ),
      ],
    );
  }
}

const _titleStyle = TextStyle(fontSize: 19, fontWeight: FontWeight.w700);

/// Equal-width Cancel / Confirm buttons shared by the prompt dialogs.
class _DialogActions extends StatelessWidget {
  const _DialogActions({
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onConfirm,
  });

  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              side: BorderSide(color: colors.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelLabel),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(onPressed: onConfirm, child: Text(confirmLabel)),
        ),
      ],
    );
  }
}
