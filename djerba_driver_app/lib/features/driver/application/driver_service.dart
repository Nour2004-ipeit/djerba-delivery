import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../data/driver_api.dart';
import '../../../core/services/push_notification_service.dart';

class DriverService extends ChangeNotifier {
  bool _isOnline = true;
  int _activeDeliveryStep = 0; // 0 to 5
  bool _hasActiveDelivery = false;
  
  List<Map<String, dynamic>> _availableTasks = [];
  Map<String, dynamic>? _activeTask;
  Map<String, dynamic>? _stats;
  bool _isLoadingTasks = false;

  List<Map<String, dynamic>> get availableTasks => _availableTasks;
  Map<String, dynamic>? get activeTask => _activeTask;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoadingTasks => _isLoadingTasks;

  bool get isOnline => _isOnline;
  int get activeDeliveryStep => _activeDeliveryStep;
  bool get hasActiveDelivery => _hasActiveDelivery;
  double? get currentLat => _currentLat;
  double? get currentLng => _currentLng;

  final DriverApi _api = DriverApi();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _taskTimer;
  double? _currentLat;
  double? _currentLng;

  DriverService() {
    _initGps();
    PushNotificationService.initialize(onNotification: _handleNewNotification);
  }

  List<Map<String, String>> _notifications = [];
  List<Map<String, String>> get notifications => _notifications;
  final Set<String> _notifiedOrderIds = {};

  void _handleNewNotification(String title, String body) {
    _notifications.insert(0, {
      'title': title,
      'body': body,
      'time': 'Just now'
    });
    notifyListeners();
  }

  Future<void> _initGps() async {
    try {
      if (kIsWeb) {
        _currentLat = 33.8076;
        _currentLng = 10.8451;
        _startTaskPolling();
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('[GPS] Location services are disabled.');
        _currentLat ??= 33.8076;
        _currentLng ??= 10.8451;
        _startTaskPolling();
        return;
      }

      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        print('[GPS] Location permission denied. Driver location will not be tracked.');
        _currentLat ??= 33.8076;
        _currentLng ??= 10.8451;
        _startTaskPolling();
        return;
      }

      // Start real GPS stream
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Only update when driver moves at least 10 meters
      );

      _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        _currentLat = position.latitude;
        _currentLng = position.longitude;

        // Only send location to backend when actively delivering
        if (_hasActiveDelivery && _isOnline) {
          _api.updateLocation(position.latitude, position.longitude);
        }
        notifyListeners();
      }, onError: (e) {
        print('[GPS] Stream error: $e');
      });

      _startTaskPolling();
    } catch (e) {
      print('[GPS] Initialization error: $e');
      _currentLat ??= 33.8076;
      _currentLng ??= 10.8451;
      _startTaskPolling();
    }
  }

  void _startTaskPolling() {
    // Load tasks immediately, then poll every 2s
    loadTasks();
    _taskTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isOnline) loadTasks();
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _taskTimer?.cancel();
    super.dispose();
  }

  Future<void> loadTasks() async {
    _isLoadingTasks = true;
    notifyListeners();
    final orders = await _api.getOrders();
    _stats = await _api.getStats();
    _availableTasks = orders.where((o) => o['status'] == 'pending' || o['status'] == 'preparing' || o['status'] == 'ready_for_pickup').toList();
    
    // Automatically trigger notification for any newly arrived order
    for (final task in _availableTasks) {
      final taskId = task['id']?.toString() ?? '';
      if (taskId.isNotEmpty && !_notifiedOrderIds.contains(taskId)) {
        _notifiedOrderIds.add(taskId);
        final restName = task['restaurant']?['name'] ?? 'Restaurant';
        final orderNum = task['orderNumber'] ?? '';
        final amount = task['totalAmount'] ?? task['deliveryFee'] ?? 4.5;
        _handleNewNotification(
          'Nouvelle Course Disponible ! 🛵',
          'Commande $orderNum ($amount TND) • $restName',
        );
      }
    }
    
    if (_hasActiveDelivery && _activeTask != null) {
      // Update the active task data if it exists, but don't reset the local step!
      final updatedTask = orders.where((o) => o['id'] == _activeTask!['id']).toList();
      if (updatedTask.isNotEmpty) {
        _activeTask = updatedTask.first;
      }
    } else {
      // For MVP, if no active delivery, try to find an existing one to resume
      final activeList = orders.where((o) => o['status'] == 'accepted' || o['status'] == 'picked_up' || o['status'] == 'arrived_at_place').toList();
      if (activeList.isNotEmpty) {
        _activeTask = activeList.first;
        _hasActiveDelivery = true;
        if (activeList.first['status'] == 'arrived_at_place') {
          _activeDeliveryStep = 4;
        } else if (activeList.first['status'] == 'picked_up') {
          _activeDeliveryStep = 3;
        } else {
          _activeDeliveryStep = 0;
        }
      }
    }
    
    _isLoadingTasks = false;
    notifyListeners();
  }
  
  void toggleOnline() {
    _isOnline = !_isOnline;
    notifyListeners();
  }
  
  Future<void> advanceDeliveryStep() async {
    if (_activeTask == null) return;
    
    if (_activeDeliveryStep < 5) {
      _activeDeliveryStep++;
      
      String nextStatus = 'accepted';
      if (_activeDeliveryStep == 1) nextStatus = 'preparing';
      if (_activeDeliveryStep == 2) nextStatus = 'ready_for_pickup';
      if (_activeDeliveryStep == 3) nextStatus = 'picked_up';
      if (_activeDeliveryStep == 4) nextStatus = 'arrived_at_place';
      if (_activeDeliveryStep == 5) nextStatus = 'delivered';
      
      await _api.updateOrderStatus(_activeTask!['id'], nextStatus);
      
      if (_activeDeliveryStep == 5) {
        _hasActiveDelivery = false;
        _activeDeliveryStep = 0;
        _activeTask = null;
      }
      notifyListeners();
    }
  }
  
  Future<void> acceptDelivery(Map<String, dynamic> task) async {
    final success = await _api.updateOrderStatus(task['id'], 'accepted');
    if (success) {
      _hasActiveDelivery = true;
      _activeDeliveryStep = 0; // Step 0 is Heading to Restaurant
      _activeTask = task;
      _availableTasks.removeWhere((t) => t['id'] == task['id']);
      notifyListeners();
    }
  }
}
