import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/routing_service.dart';
import '../../../core/theme.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, this.orderId = ''});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _currentStep = 0;
  Timer? _timer;
  LatLng? _driverLocation;
  String? _driverName;
  String? _driverImage;
  LatLng _restaurantLocation = const LatLng(33.8200, 10.8600);
  LatLng _deliveryLocation = const LatLng(33.8700, 10.9800);
  List<LatLng> _routePoints = [];
  final RoutingService _routingService = RoutingService();
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderData(); // Load immediately on open
    
    // Polling for live order status and driver location
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _fetchOrderData());
  }

  Future<void> _fetchOrderData() async {
    if (widget.orderId.isEmpty) return;
    try {
      final response = await DioClient().dio.get('/orders/${widget.orderId}');
      final order = response.data;
      
      if (order['status'] != null) {
        int step = 0;
        switch(order['status']) {
          case 'pending': step = 0; break;
          case 'accepted': step = 0; break;
          case 'preparing': step = 1; break;
          case 'ready_for_pickup': step = 1; break;
          case 'picked_up': step = 2; break;
          case 'arrived_at_place': step = 3; break;
          case 'delivered': step = 4; break;
        }
        
        setState(() {
          _currentStep = step;
          _mapReady = true;
          if (order['driver'] != null) {
            _driverName = order['driver']['name'];
            _driverImage = order['driver']['image'];
          }
          // Use real delivery coordinates from the order
          if (order['deliveryLat'] != null && order['deliveryLng'] != null) {
            _deliveryLocation = LatLng(
              (order['deliveryLat'] as num).toDouble(),
              (order['deliveryLng'] as num).toDouble(),
            );
          }
          // Use real restaurant coordinates
          if (order['restaurant'] != null && order['restaurant']['lat'] != null) {
            _restaurantLocation = LatLng(
              (order['restaurant']['lat'] as num).toDouble(),
              (order['restaurant']['lng'] as num).toDouble(),
            );
          }
        });
        
        if (step >= 4) {
          _timer?.cancel();
          _showRatingDialog();
        }
      }

      // Fetch driver GPS location
      if (_driverName != null) {
        final locResponse = await DioClient().dio.get('/orders/${widget.orderId}/location');
        if (locResponse.data['lat'] != null && locResponse.data['lng'] != null) {
          final newDriverLocation = LatLng(
            (locResponse.data['lat'] as num).toDouble(),
            (locResponse.data['lng'] as num).toDouble(),
          );
          
          if (_driverLocation == null || _driverLocation!.latitude != newDriverLocation.latitude || _driverLocation!.longitude != newDriverLocation.longitude) {
            setState(() {
              _driverLocation = newDriverLocation;
            });
            _updateRoute();
          }
        }
      } else {
        if (_routePoints.isEmpty && _restaurantLocation != const LatLng(33.8200, 10.8600)) {
          _updateRoute(); // Fetch route at least once even if no driver
        }
      }
    } catch (e) {
      // ignore for MVP
    }
  }

  Future<void> _updateRoute() async {
    List<LatLng> waypoints = [];
    if (_driverLocation != null) {
      waypoints.add(_driverLocation!);
    }
    waypoints.add(_restaurantLocation);
    waypoints.add(_deliveryLocation);

    final points = await _routingService.getMultiPointRoute(waypoints);
    if (mounted) {
      setState(() {
        _routePoints = points;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        int rating = 5;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text("Commande Livrée ! 🎉", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Comment s'est passée votre livraison ?", textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () => setState(() => rating = index + 1),
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/client_dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DjerbaTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Soumettre & Retourner", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isCompleted, bool isCurrent, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? DjerbaTheme.primaryColor : (isCurrent ? Colors.white : Colors.grey.shade300),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? DjerbaTheme.primaryColor : Colors.transparent,
                  width: isCurrent ? 6 : 0,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? DjerbaTheme.primaryColor : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: (isCompleted || isCurrent) ? Colors.black87 : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _deliveryLocation,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  userAgentPackageName: 'com.djerba.delivery',
                ),
                PolylineLayer(
                  polylines: [
                    if (_routePoints.isNotEmpty)
                      Polyline<Object>(
                        points: _routePoints,
                        strokeWidth: 5.0,
                        color: DjerbaTheme.primaryColor,
                      )
                    else
                      Polyline<Object>(
                        points: [
                          _restaurantLocation,
                          _driverLocation ?? LatLng(
                            (_restaurantLocation.latitude + _deliveryLocation.latitude) / 2,
                            (_restaurantLocation.longitude + _deliveryLocation.longitude) / 2,
                          ),
                          _deliveryLocation,
                        ],
                        strokeWidth: 4.0,
                        color: DjerbaTheme.primaryColor.withOpacity(0.5),
                        pattern: const StrokePattern.dotted(),
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Restaurant Marker (Origin)
                    Marker(
                      point: _restaurantLocation,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        child: const Center(child: Icon(Icons.restaurant, color: DjerbaTheme.primaryColor, size: 24)),
                      ),
                    ),
                    // Destination Marker
                    Marker(
                      point: _deliveryLocation,
                      width: 50,
                      height: 60,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.pinkAccent,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                            ),
                            child: const Icon(Icons.bed, color: Colors.white, size: 20),
                          ),
                          Container(width: 3, height: 10, color: Colors.pinkAccent),
                        ],
                      ),
                    ),
                    // Scooter Marker (driver live position)
                    Marker(
                      point: _driverLocation ?? _restaurantLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.moped, size: 36, color: DjerbaTheme.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Top Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.go('/client_dashboard'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                    child: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                    child: Row(
                      children: const [
                        Icon(Icons.headset_mic_outlined, size: 20),
                        SizedBox(width: 8),
                        Text("Aide", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Sheet Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Estimated Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Heure estimée d'arrivée", style: TextStyle(color: Colors.grey, fontSize: 14)),
                              SizedBox(height: 4),
                              Text("20:45", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: DjerbaTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Dans 25 min",
                              style: TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(),
                      ),

                      // Status Timeline
                      _buildTimelineStep("Commande acceptée", "Le restaurant a confirmé votre commande.", _currentStep >= 1, _currentStep == 0),
                      _buildTimelineStep("En préparation", "Votre repas est en cours de préparation.", _currentStep >= 2, _currentStep == 1),
                      _buildTimelineStep("En route", "Le livreur a récupéré votre commande.", _currentStep >= 3, _currentStep == 2),
                      _buildTimelineStep("Arrivé sur place", "Le livreur est à l'adresse de livraison.", _currentStep >= 4, _currentStep == 3),
                      _buildTimelineStep("Livré", "Profitez de votre repas !", _currentStep >= 4, _currentStep == 4, isLast: true),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(),
                      ),

                      // Driver Info
                      if (_driverName != null)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: _driverImage != null && _driverImage!.isNotEmpty
                                  ? NetworkImage(_driverImage!)
                                  : const NetworkImage("https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&q=80&w=150"),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_driverName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Row(
                                    children: const [
                                      Icon(Icons.star, color: Colors.orange, size: 16),
                                      SizedBox(width: 4),
                                      Text("4.9", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                      SizedBox(width: 4),
                                      Text("• Livreur Djerba", style: TextStyle(color: Colors.grey, fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
                              child: IconButton(
                                icon: const Icon(Icons.phone, color: DjerbaTheme.primaryColor),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: const [
                              Icon(Icons.hourglass_empty, color: Colors.grey),
                              SizedBox(width: 12),
                              Text("En attente d'un livreur...", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
