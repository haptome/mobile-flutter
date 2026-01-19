import 'package:flutter/material.dart';

/// A widget that displays icons based on icon names from our icon system
/// 
/// This widget maps icon names to Flutter's built-in icons
/// The icon name should be descriptive like "bank", "cart", "car", etc.
class CategoryIcon extends StatelessWidget {
  final String? iconName;
  final double size;
  final Color? color;

  const CategoryIcon({
    super.key,
    required this.iconName,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (iconName == null || iconName!.isEmpty) {
      return Icon(
        Icons.help_outline,
        size: size,
        color: color ?? Theme.of(context).disabledColor,
      );
    }

    return Icon(
      _getIconData(iconName!),
      size: size,
      color: color ?? Theme.of(context).iconTheme.color,
    );
  }

  /// Map icon names to Flutter Material icons
  IconData _getIconData(String name) {
    // Remove any prefix like 'mdi:' to get the actual icon name
    String cleanName = name.toLowerCase();
    if (cleanName.contains(':')) {
      cleanName = cleanName.split(':')[1];
    }
    final lowerName = cleanName;
    
    // Business & Finance
    if (lowerName.contains('bank') || 
        lowerName.contains('money') || 
        lowerName.contains('finance')) {
      return Icons.account_balance;
    }
    if (lowerName.contains('currency') || 
        lowerName.contains('cash') ||
        lowerName.contains('payment')) {
      return Icons.attach_money;
    }
    if (lowerName.contains('credit') || 
        lowerName.contains('card')) {
      return Icons.credit_card;
    }
    if (lowerName.contains('chart') || 
        lowerName.contains('graph')) {
      return Icons.show_chart;
    }
    if (lowerName.contains('business') || 
        lowerName.contains('briefcase')) {
      return Icons.work;
    }
    if (lowerName.contains('building') || 
        lowerName.contains('office')) {
      return Icons.business;
    }

    // Shopping & Commerce
    if (lowerName.contains('cart') || 
        lowerName.contains('shopping')) {
      return Icons.shopping_cart;
    }
    if (lowerName.contains('store') || 
        lowerName.contains('shop')) {
      return Icons.store;
    }
    if (lowerName.contains('gift')) {
      return Icons.card_giftcard;
    }
    if (lowerName.contains('clothing') || 
        lowerName.contains('tshirt') ||
        lowerName.contains('shirt')) {
      return Icons.checkroom;
    }
    if (lowerName.contains('food')) {
      return Icons.fastfood;
    }
    if (lowerName.contains('coffee')) {
      return Icons.local_cafe;
    }
    if (lowerName.contains('restaurant')) {
      return Icons.restaurant;
    }
    if (lowerName.contains('home')) {
      return Icons.home;

    // Transportation
    } else if (lowerName.contains('car')) {
      return Icons.directions_car;
    } else if (lowerName.contains('bus')) {
      return Icons.directions_bus;
    } else if (lowerName.contains('bike') || 
               lowerName.contains('bicycle')) {
      return Icons.pedal_bike;
    } else if (lowerName.contains('airplane') || 
               lowerName.contains('flight')) {
      return Icons.flight;
    } else if (lowerName.contains('train')) {
      return Icons.train;
    } else if (lowerName.contains('truck')) {
      return Icons.local_shipping;
    } else if (lowerName.contains('motorbike') || 
               lowerName.contains('motorcycle')) {
      return Icons.motorcycle;
    } else if (lowerName.contains('ship') || 
               lowerName.contains('boat')) {
      return Icons.directions_boat;

    // Technology
    } else if (lowerName.contains('laptop')) {
      return Icons.laptop;
    } else if (lowerName.contains('phone') || 
               lowerName.contains('mobile') ||
               lowerName.contains('cell')) {
      return Icons.phone_android;
    } else if (lowerName.contains('tablet')) {
      return Icons.tablet;
    } else if (lowerName.contains('monitor') || 
               lowerName.contains('computer')) {
      return Icons.computer;
    } else if (lowerName.contains('camera')) {
      return Icons.camera_alt;
    } else if (lowerName.contains('printer')) {
      return Icons.print;
    } else if (lowerName.contains('game')) {
      return Icons.games;

    // Health & Medical
    } else if (lowerName.contains('medical') || 
               lowerName.contains('health')) {
      return Icons.local_hospital;
    } else if (lowerName.contains('heart')) {
      return Icons.favorite;
    } else if (lowerName.contains('hospital')) {
      return Icons.local_hospital;
    } else if (lowerName.contains('pharmacy')) {
      return Icons.local_pharmacy;
    } else if (lowerName.contains('tooth')) {
      return Icons.emoji_objects;
    } else if (lowerName.contains('eye')) {
      return Icons.remove_red_eye;
    } else if (lowerName.contains('brain')) {
      return Icons.psychology;

    // Education
    } else if (lowerName.contains('school')) {
      return Icons.school;
    } else if (lowerName.contains('book')) {
      return Icons.menu_book;
    } else if (lowerName.contains('pencil')) {
      return Icons.edit;
    } else if (lowerName.contains('graduation')) {
      return Icons.school;
    } else if (lowerName.contains('library')) {
      return Icons.local_library;
    } else if (lowerName.contains('calculator')) {
      return Icons.calculate;
    } else if (lowerName.contains('atom')) {
      return Icons.science;

    // Entertainment
    } else if (lowerName.contains('music')) {
      return Icons.music_note;
    } else if (lowerName.contains('movie')) {
      return Icons.movie;
    } else if (lowerName.contains('tv') || 
               lowerName.contains('television')) {
      return Icons.tv;
    } else if (lowerName.contains('ticket')) {
      return Icons.confirmation_number;
    } else if (lowerName.contains('soccer')) {
      return Icons.sports_soccer;
    } else if (lowerName.contains('tennis')) {
      return Icons.sports_tennis;
    } else if (lowerName.contains('gym') || 
               lowerName.contains('dumbbell')) {
      return Icons.fitness_center;

    // Nature & Outdoors
    } else if (lowerName.contains('tree')) {
      return Icons.park;
    } else if (lowerName.contains('flower')) {
      return Icons.local_florist;
    } else if (lowerName.contains('leaf')) {
      return Icons.eco;
    } else if (lowerName.contains('sun')) {
      return Icons.wb_sunny;
    } else if (lowerName.contains('water')) {
      return Icons.water;
    } else if (lowerName.contains('mountain')) {
      return Icons.terrain;
    } else if (lowerName.contains('beach')) {
      return Icons.beach_access;

    // People & Social
    } else if (lowerName.contains('group') || 
               lowerName.contains('people')) {
      return Icons.groups;
    } else if (lowerName.contains('family')) {
      return Icons.family_restroom;
    } else if (lowerName.contains('handshake')) {
      return Icons.handshake;
    } else if (lowerName.contains('charity')) {
      return Icons.volunteer_activism;
    } else if (lowerName.contains('volunteer')) {
      return Icons.volunteer_activism;
    } else if (lowerName.contains('community')) {
      return Icons.people;

    // Miscellaneous
    } else if (lowerName.contains('tools')) {
      return Icons.build;
    } else if (lowerName.contains('wrench')) {
      return Icons.build;
    } else if (lowerName.contains('key')) {
      return Icons.key;
    } else if (lowerName.contains('lock')) {
      return Icons.lock;
    } else if (lowerName.contains('lightbulb') || 
               lowerName.contains('bulb')) {
      return Icons.lightbulb;
    } else if (lowerName.contains('fire')) {
      return Icons.local_fire_department;
    } else if (lowerName.contains('star')) {
      return Icons.star;
    }

    // Default fallback
    return Icons.category;
  }
}