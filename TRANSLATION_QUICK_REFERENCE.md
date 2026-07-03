# Translation Quick Reference

## Using TranslatedText in Your Code

### Basic Usage
```dart
import 'package:et_digital_equb/core/widgets/translated_text.dart';

// Display dynamic text with automatic translation
TranslatedText(
  groupName,  // e.g., "Coffee Savings Club"
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
)
```

### With Text Parameters
```dart
TranslatedText(
  category.name,
  textAlign: TextAlign.center,
  overflow: TextOverflow.ellipsis,
  maxLines: 1,
  style: GoogleFonts.montserrat(fontSize: 14),
)
```

## Translation Keys (en_us.dart)

### Common Translations Already Available
- `'members_label'`: 'Members'
- `'groups'`: 'groups'
- `'round'`: 'Round'
- `'daily'`: 'Daily'
- `'weekly'`: 'Weekly'
- `'monthly'`: 'Monthly'
- `'in_kind'`: 'In-Kind'
- And many more...

### Adding New Translation Keys

1. Open `lib/translations/en_us.dart`
2. Add your key-value pair to the `enUS` map:
```dart
'my_new_key': 'My English Text',
```

3. Use in your code:
```dart
Text('my_new_key'.tr)  // For static text
TranslatedText('Dynamic Text')  // For dynamic API data
```

## Translation Service Architecture

### TranslateService (Singleton)
```dart
// lib/core/services/translate_service.dart
final translated = await TranslateService.instance.translate(
  'Hello',
  from: 'en',
  to: 'am',
);
```

**Features:**
- ✅ In-memory caching (no redundant API calls)
- ✅ Non-blocking async translation
- ✅ Graceful fallback to English on error
- ✅ Uses Google Translate mobile endpoint (no API key needed)

### LanguageController
```dart
// lib/controllers/language_controller.dart
final controller = Get.find<LanguageController>();
controller.currentLocale.value = Locale('am');  // Switch to Amharic
controller.currentLocale.value = Locale('en');  // Switch to English
```

**Features:**
- ✅ Global language state management
- ✅ Reactive updates to all `TranslatedText` widgets
- ✅ Persists language preference

## Files Using Translation System

### Screens
- ✅ `group_detail_view.dart` - Group names in AppBar
- ✅ `in_kind_detail_view.dart` - In-Kind group names in AppBar
- ✅ `group_invite_view.dart` - Group names in invitation card
- ✅ `your_ekubs_view.dart` - Via completed_ekub_card
- ✅ `home_screen.dart` - Via category_section_cards

### Widgets
- ✅ `ekub_list_item_custom.dart` - Group names and member labels
- ✅ `completed_ekub_card.dart` - Completed ekub names
- ✅ `ekub_progress_card.dart` - Progress card titles
- ✅ `category_section_cards.dart` - Category names

## Testing Translations

### Manual Testing
1. Open app → All names appear in English
2. Wait 2-3 seconds → Names auto-translate to Amharic
3. Go to Settings → Toggle language to Amharic
4. Verify all names update instantly
5. Toggle back to English → Names revert

### Debugging
```dart
// Check if translation is working
final translated = await TranslateService.instance.translate(
  'Hello World',
  from: 'en',
  to: 'am',
);
print('Translated: $translated');

// Check current language
final isAmharic = Get.find<LanguageController>().isAmharic();
print('Is Amharic: $isAmharic');
```

## Performance Tips

1. **Use TranslatedText only for dynamic API data** - For static UI text, use `.tr` extension
2. **Leverage caching** - Same text won't be translated twice per session
3. **Batch translations** - App will auto-cache commonly used strings
4. **Monitor network** - Translations require internet (gracefully falls back if offline)

## Common Patterns

### Pattern 1: Dynamic List Items
```dart
ListView.builder(
  itemBuilder: (context, index) {
    return TranslatedText(
      items[index].name,
      style: TextStyle(fontSize: 14),
    );
  },
)
```

### Pattern 2: With Icons
```dart
Row(
  children: [
    Icon(Icons.group),
    SizedBox(width: 8),
    TranslatedText(group.name, style: TextStyle(fontSize: 16)),
  ],
)
```

### Pattern 3: Styled Text
```dart
TranslatedText(
  category.description,
  style: GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  ),
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
)
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Text not translating | Check internet connection, translations are async |
| Translation appears late | Normal - translations arrive after ~500ms, by design |
| Text stays in English | Check `LanguageController` is properly initialized |
| Same text not translating | Check if it's in the cache, clear cache in settings if needed |
| Error in console | Translation service logs errors but falls back gracefully |

## Notes

- ✅ All API data now uses TranslatedText for automatic Amharic translation
- ✅ No backend changes required
- ✅ Works offline (shows English, waits for translation when online)
- ✅ Cache is in-memory (clears on app restart)
- ✅ Language preference is persisted to SharedPreferences
