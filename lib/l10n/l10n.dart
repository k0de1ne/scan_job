import 'package:flutter/widgets.dart';
import 'package:scan_job/l10n/generated/app_localizations.dart';

export 'package:scan_job/l10n/generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
