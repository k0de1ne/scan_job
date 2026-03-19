import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_job/app/cubit/app_cubit.dart';
import 'package:scan_job/app/cubit/app_state.dart';
import 'package:scan_job/l10n/l10n.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.settingsTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.settingsThemeTitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            const _ThemeSelector(),
            const SizedBox(height: 24),
            Text(
              l10n.settingsLlmTitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.settingsLlmHelp,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            const _LlmSettings(),
          ],
        ),
      ),
    );
  }
}

class _LlmSettings extends StatelessWidget {
  const _LlmSettings();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AppCubit>();

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return Column(
          children: [
            _SettingsTextField(
              label: l10n.settingsLlmBaseUrl,
              initialValue: state.llmBaseUrl,
              onChanged: cubit.setLlmBaseUrl,
            ),
            const SizedBox(height: 12),
            _SettingsTextField(
              label: l10n.settingsLlmApiKey,
              initialValue: state.llmApiKey,
              onChanged: cubit.setLlmApiKey,
              isPassword: true,
            ),
            const SizedBox(height: 12),
            _SettingsTextField(
              label: l10n.settingsLlmModelName,
              initialValue: state.llmModelName,
              onChanged: cubit.setLlmModelName,
            ),
          ],
        );
      },
    );
  }
}

class _SettingsTextField extends StatefulWidget {
  const _SettingsTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.isPassword = false,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool isPassword;

  @override
  State<_SettingsTextField> createState() => _SettingsTextFieldState();
}

class _SettingsTextFieldState extends State<_SettingsTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          obscureText: widget.isPassword,
          onChanged: widget.onChanged,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return Column(
          children: [
            _ThemeOption(
              label: l10n.settingsThemeSystem,
              isSelected: state.themeMode == ThemeMode.system,
              onTap: () => context.read<AppCubit>().setThemeMode(ThemeMode.system),
              icon: Icons.brightness_auto_outlined,
            ),
            const SizedBox(height: 4),
            _ThemeOption(
              label: l10n.settingsThemeLight,
              isSelected: state.themeMode == ThemeMode.light,
              onTap: () => context.read<AppCubit>().setThemeMode(ThemeMode.light),
              icon: Icons.light_mode_outlined,
            ),
            const SizedBox(height: 4),
            _ThemeOption(
              label: l10n.settingsThemeDark,
              isSelected: state.themeMode == ThemeMode.dark,
              onTap: () => context.read<AppCubit>().setThemeMode(ThemeMode.dark),
              icon: Icons.dark_mode_outlined,
            ),
          ],
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.surfaceContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 20,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
