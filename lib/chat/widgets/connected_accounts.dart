import 'package:flutter/material.dart';
import 'package:scan_job/chat/widgets/hh_auth_bottom_sheet.dart';
import 'package:scan_job/l10n/l10n.dart';
import 'package:scan_job/theme/app_theme.dart';
import 'package:scan_job/tools/hh_tool.dart';

class ConnectedAccounts extends StatefulWidget {
  const ConnectedAccounts({super.key});

  @override
  State<ConnectedAccounts> createState() => _ConnectedAccountsState();
}

class _ConnectedAccountsState extends State<ConnectedAccounts> {
  List<Map<String, dynamic>> _accounts = [];
  String? _selectedId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await HhTool.instance.getAccounts();
      final selectedId = await HhTool.instance.getSelectedAccountId();
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _selectedId = selectedId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectAccount(String id) async {
    await HhTool.instance.executeTool('hh_select_account', {'account_id': id});
    await _loadAccounts();
  }

  Future<void> _removeAccount(String id) async {
    await HhTool.instance.authService.removeAccount(id);
    await _loadAccounts();
  }

  Future<void> _addAccount() async {
    final result = await HhAuthBottomSheet.show(context);
    if (result != null) {
      await _loadAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.sidebarAccountsTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant.withAlpha(180),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: _addAccount,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                tooltip: l10n.sidebarAccountsAdd,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_accounts.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.spacing.sm),
            child: Text(
              l10n.sidebarAccountsEmpty,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant.withAlpha(128),
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ..._accounts.map((account) {
            final id = account['id'] as String;
            final isSelected = id == _selectedId;
            final firstName = account['first_name'] as String? ?? '';
            final lastName = account['last_name'] as String? ?? '';
            final fullName = '$firstName $lastName'.trim();

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Material(
                color: isSelected ? colorScheme.primaryContainer.withAlpha(100) : Colors.transparent,
                borderRadius: BorderRadius.circular(context.radius.sm),
                child: InkWell(
                  onTap: () => _selectAccount(id),
                  borderRadius: BorderRadius.circular(context.radius.sm),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.sm,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_circle_outlined,
                          size: 20,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName.isNotEmpty ? fullName : l10n.sidebarAccountId(id),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (fullName.isNotEmpty)
                                Text(
                                  l10n.sidebarAccountId(id),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onSurfaceVariant.withAlpha(150),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (!isSelected)
                          IconButton(
                            icon: const Icon(Icons.close, size: 14),
                            onPressed: () => _removeAccount(id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            color: colorScheme.onSurfaceVariant.withAlpha(100),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
