import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishimitra/providers/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      icon: Icon(Icons.language),
      onSelected: (String languageCode) {
        languageProvider.changeLocale(languageCode);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          child: Text(l10n.english),
        ),
        PopupMenuItem<String>(
          value: 'hi',
          child: Text(l10n.hindi),
        ),
      ],
    );
  }
}
