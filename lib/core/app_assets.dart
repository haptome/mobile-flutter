/// Centralized asset path constants for the app
class AppAssets {
  AppAssets._();

  // Base paths
  static const String _iconsPath = 'assets/icons';
  static const String _imagesPath = 'assets/images';

  // Icons
  static const String logo = 'assets/icons/logo.png';
  static const String driversIcon = 'assets/icons/drivers.svg';
  static const String merchantIcon = 'assets/icons/merchant.svg';
  static const String employeeIcon = 'assets/icons/employee.svg';
  static const String televisionIcon = 'assets/icons/television.svg';
  static const String fridgeIcon = 'assets/icons/fridge.svg';
  static const String calendarIcon = 'assets/icons/calendar.svg';
  static const String homeIcon = 'assets/icons/home.svg';
  static const String personsIcon = 'assets/icons/persons.svg';
  static const String transactionIcon = 'assets/icons/transaction.svg';
  static const String profileIcon = 'assets/icons/profile.svg';

  // Images
  static const String electronics = '$_imagesPath/elecronics.jpg';
  static const String mpesa = '$_imagesPath/mpesa.jpg';
  static const String authBackground = '$_imagesPath/auth-background.png';

  // Helper method to get asset path
  static String icon(String name) => '$_iconsPath/$name';
  static String image(String name) => '$_imagesPath/$name';
}

