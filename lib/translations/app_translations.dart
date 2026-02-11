// Purpose: Localization translations (Amharic/English)
// Author: ET Digital Equb Team
// Linked Spec Section: FR01-FR03

import 'package:get/get.dart';
import 'en_us.dart';
import 'am_et.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'am_ET': amET,
      };
}
