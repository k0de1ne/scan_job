import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_job/app/cubit/app_cubit.dart';
import 'package:scan_job/app/cubit/app_state.dart';
import 'package:scan_job/l10n/l10n.dart';
import 'package:scan_job/theme/app_theme.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    return showDialog<void>(
      context: context,
      builder: (context) => BlocProvider.value(
        value: appCubit,
        child: const SettingsDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: context.appColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.sm),
      ),
      child: SingleChildScrollView(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(context.spacing.xl),
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
              SizedBox(height: context.spacing.xl),
              Text(
                l10n.settingsThemeTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: context.spacing.md),
              const _ThemeSelector(),
              SizedBox(height: context.spacing.xl),
              Text(
                l10n.settingsLlmTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: context.spacing.sm),
              Text(
                l10n.settingsLlmHelp,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: context.spacing.lg),
              const _LlmSettings(),
            ],
          ),
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
            SizedBox(height: context.spacing.md),
            _SettingsTextField(
              label: l10n.settingsLlmApiKey,
              initialValue: state.llmApiKey,
              onChanged: cubit.setLlmApiKey,
              isPassword: true,
            ),
            SizedBox(height: context.spacing.md),
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
        SizedBox(height: context.spacing.xs),
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.spacing.md,
              vertical: context.spacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radius.sm),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radius.sm),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.radius.sm),
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
              onTap: () =>
                  context.read<AppCubit>().setThemeMode(ThemeMode.system),
              icon: Icons.brightness_auto_outlined,
            ),
            SizedBox(height: context.spacing.xs),
            _ThemeOption(
              label: l10n.settingsThemeLight,
              isSelected: state.themeMode == ThemeMode.light,
              onTap: () =>
                  context.read<AppCubit>().setThemeMode(ThemeMode.light),
              icon: Icons.light_mode_outlined,
            ),
            SizedBox(height: context.spacing.xs),
            _ThemeOption(
              label: l10n.settingsThemeDark,
              isSelected: state.themeMode == ThemeMode.dark,
              onTap: () =>
                  context.read<AppCubit>().setThemeMode(ThemeMode.dark),
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
      color: isSelected
          ? colorScheme.surfaceContainer
          : context.appColors.transparent,
      borderRadius: BorderRadius.circular(context.radius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.radius.sm),
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: context.spacing.md),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
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
