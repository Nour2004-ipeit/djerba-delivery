import 'package:flutter/foundation.dart';

class DeliveryAddress {
  final String id;
  final String title;
  final String details;
  final bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.title,
    required this.details,
    this.isDefault = false,
  });
}

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  
  factory UserService() {
    return _instance;
  }
  
  UserService._internal();

  String _name = "Nour B.";
  String _email = "nour@example.com";
  String _phone = "+216 22 123 456";

  String get name => _name;
  String get email => _email;
  String get phone => _phone;

  void updateProfile({required String name, required String email, required String phone}) {
    _name = name;
    _email = email;
    _phone = phone;
    notifyListeners();
  }

  final List<DeliveryAddress> _addresses = [
    DeliveryAddress(id: '1', title: 'Maison', details: 'Midoun, Djerba - Près de la mosquée', isDefault: true),
    DeliveryAddress(id: '2', title: 'Travail', details: 'Houmt Souk, Djerba - Centre ville', isDefault: false),
  ];

  List<DeliveryAddress> get addresses => _addresses;

  void addAddress(DeliveryAddress address) {
    if (address.isDefault) {
      _clearDefault();
    }
    _addresses.add(address);
    notifyListeners();
  }

  void _clearDefault() {
    for (int i = 0; i < _addresses.length; i++) {
      if (_addresses[i].isDefault) {
        _addresses[i] = DeliveryAddress(
          id: _addresses[i].id,
          title: _addresses[i].title,
          details: _addresses[i].details,
          isDefault: false,
        );
      }
    }
  }
}
