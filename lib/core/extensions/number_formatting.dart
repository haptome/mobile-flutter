// Purpose: Number formatting extensions for shortening large numbers
// Author: Created for Ekub app

extension NumberFormatting on num {
  /// Shortens a number to a readable format with K/M/B suffixes
  ///
  /// Examples:
  /// 1000 => "1K"
  /// 1500 => "1.5K"
  /// 1000000 => "1M"
  /// 1500000 => "1.5M"
  /// 1000000000 => "1B"
  ///
  /// @param decimals Number of decimal places (default: 1)
  /// @param threshold Minimum value to format (default: 1000)
  String shorten({int decimals = 1, int threshold = 1000}) {
    // Handle special numeric values
    if (!isFinite) {
      if (isInfinite) return '∞';
      if (isNaN) return 'N/A';
    }
    
    if (this < threshold) {
      return toString();
    }

    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(decimals)}B';
    }

    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(decimals)}M';
    }

    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(decimals)}K';
    }

    return toStringAsFixed(decimals);
  }

  /// Shortens a number with space between value and suffix
  ///
  /// Examples:
  /// 1000 => "1 K"
  /// 1500000 => "1.5 M"
  String shortenWithSpace({int decimals = 1, int threshold = 1000}) {
    // Handle special numeric values
    if (!isFinite) {
      if (isInfinite) return '∞';
      if (isNaN) return 'N/A';
    }
    
    if (this < threshold) {
      return toString();
    }

    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(decimals)} B';
    }

    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(decimals)} M';
    }

    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(decimals)} K';
    }

    return toStringAsFixed(decimals);
  }

  /// Formats currency with ETB symbol and shortened format
  ///
  /// Examples:
  /// 1000 => "ETB 1K"
  /// 1500000 => "ETB 1.5M"
  String toCurrencyShort({int decimals = 1}) {
    return '${shorten(decimals: decimals)} ETB';
  }

  /// Formats currency with space and shortened format
  ///
  /// Examples:
  /// 1000 => "ETB 1 K"
  /// 1500000 => "ETB 1.5 M"
  String toCurrencyShortWithSpace({int decimals = 1}) {
    return '${shortenWithSpace(decimals: decimals)} ETB';
  }
}
