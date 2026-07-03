// Purpose: A drop-in replacement for Text that auto-translates its content
// via Google Translate when the app locale is Amharic, and reacts to live
// language switches (EN ↔ AM) without requiring a hot reload.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/language_controller.dart';
import '../services/translate_service.dart';

class TranslatedText extends StatefulWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool softWrap;

  const TranslatedText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap = true,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String _displayText = '';
  Worker? _localeWorker;

  @override
  void initState() {
    super.initState();
    _displayText = widget.data;

    // React every time the language is toggled
    final languageController = Get.find<LanguageController>();
    _localeWorker = ever(languageController.currentLocale, (_) {
      _translate();
    });

    _translate();
  }

  @override
  void didUpdateWidget(TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _displayText = widget.data;
      _translate();
    }
  }

  @override
  void dispose() {
    _localeWorker?.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final languageController = Get.find<LanguageController>();
    final isAmharic = languageController.isAmharic();

    if (!isAmharic) {
      // Switched back to English — show original immediately
      if (mounted && _displayText != widget.data) {
        setState(() => _displayText = widget.data);
      }
      return;
    }

    // Switched to Amharic — fetch translation
    final translated = await TranslateService.instance.translate(
      widget.data,
      from: 'en',
      to: 'am',
    );

    if (mounted) {
      setState(() => _displayText = translated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.style,
      textAlign: widget.textAlign,
      overflow: widget.overflow,
      maxLines: widget.maxLines,
      softWrap: widget.softWrap,
    );
  }
}
