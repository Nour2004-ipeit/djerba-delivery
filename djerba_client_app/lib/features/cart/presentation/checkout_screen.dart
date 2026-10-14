import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'cart_service.dart';
import '../data/orders_api.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isHotelDelivery = true;
  int _selectedDeliveryMode = 0; // 0 = Standard, 1 = Express
  int _selectedPaymentMethod = 0; // 0=VISA, 1=Cash, 2=D17, 3=Flouci
  Map<String, double>? _selectedCoordinates;
  bool _isProcessing = false;

  Widget _buildDeliveryModeCard(int index, String title, String time, String price, IconData icon) {
    bool isSelected = _selectedDeliveryMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDeliveryMode = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? DjerbaTheme.primaryColor : Colors.grey.withOpacity(0.2), width: isSelected ? 2 : 1),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  Icon(icon, color: isSelected ? DjerbaTheme.primaryColor : Colors.orangeAccent, size: 32),
                  const SizedBox(height: 12),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF1F5F9) : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(time, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? DjerbaTheme.textSecondary : Colors.orange)),
                  ),
                  const SizedBox(height: 12),
                  Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: DjerbaTheme.primaryColor)),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: DjerbaTheme.primaryColor, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(int index, String title, Widget leadingIcon) {
    bool isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? DjerbaTheme.primaryColor : Colors.grey, width: isSelected ? 6 : 1),
              ),
            ),
            const SizedBox(width: 16),
            leadingIcon,
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartService(),
      builder: (context, _) {
        final subtotal = CartService().totalPrice;
        final deliveryFee = 6.0;
        final total = subtotal + deliveryFee;
        
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DjerbaTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text("Paiement", style: TextStyle(color: DjerbaTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adresse de livraison
            const Text("Adresse de livraison", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final result = await context.push('/address_picker');
                if (result != null && result is Map<String, double>) {
                  setState(() {
                    _selectedCoordinates = result;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: DjerbaTheme.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(child: Text(_selectedCoordinates != null ? "Coordonnées: ${_selectedCoordinates!['lat']?.toStringAsFixed(4)}, ${_selectedCoordinates!['lng']?.toStringAsFixed(4)}" : "Hôtel Radisson Djerba, Chambre 214", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                    Text("Modifier", style: TextStyle(color: DjerbaTheme.primaryColor.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Text("🌴", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  const Expanded(child: Text("Livraison touriste / hôtel", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                  Switch(
                    value: _isHotelDelivery,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green,
                    onChanged: (val) {
                      setState(() {
                        _isHotelDelivery = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Mode de livraison
            const Text("Mode de livraison", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDeliveryModeCard(0, "Standard", "25-35 min", "3 TND", Icons.moped_outlined),
                const SizedBox(width: 16),
                _buildDeliveryModeCard(1, "Express", "15-20 min", "6 TND", Icons.bolt_outlined),
              ],
            ),
            const SizedBox(height: 32),

            // Paiement
            const Text("Paiement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildPaymentMethod(0, "Carte bancaire **** 4582", Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF1434CB).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text("VISA", style: TextStyle(color: Color(0xFF1434CB), fontWeight: FontWeight.bold, fontSize: 12)),
                  )),
                  _buildPaymentMethod(1, "Espèces à la livraison", Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.money, color: Colors.orange, size: 16),
                  )),
                  _buildPaymentMethod(2, "D17 mobile pay", Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: const Text("D17", style: TextStyle(color: Color(0xFF0F3A3A), fontWeight: FontWeight.w900, fontSize: 14)),
                  )),
                  _buildPaymentMethod(3, "Flouci", Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: const Text("flouci", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 14)),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1), style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: DjerbaTheme.primaryColor, size: 18),
                  const SizedBox(width: 8),
                  const Text("Ajouter une carte", style: TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Récapitulatif
            const Text("Récapitulatif", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5D6D7E))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Sous-total", style: TextStyle(color: Color(0xFF5D6D7E), fontSize: 15)),
                      Text("$subtotal TND", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF5D6D7E))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Livraison", style: TextStyle(color: Color(0xFF5D6D7E), fontSize: 15)),
                      Text("$deliveryFee TND", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF5D6D7E))),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.black87, thickness: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF5D6D7E))),
                      Text("$total TND", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF5D6D7E))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 56,
        margin: const EdgeInsets.only(bottom: 16),
        child: ElevatedButton(
          onPressed: _isProcessing ? null : () async {
            setState(() { _isProcessing = true; });
            try {
              final items = CartService().items.values.toList();
              if (items.isNotEmpty) {
                final addrStr = _selectedCoordinates != null 
                    ? "Coordonnées: ${_selectedCoordinates!['lat']?.toStringAsFixed(4)}, ${_selectedCoordinates!['lng']?.toStringAsFixed(4)}"
                    : "Hôtel Radisson Djerba, Chambre 214";
                final lat = _selectedCoordinates?['lat'] ?? 33.876;
                final lng = _selectedCoordinates?['lng'] ?? 10.957;

                final orderId = await OrdersApi().createOrder(items, addrStr, lat, lng);
                CartService().clear();
                if (mounted) {
                  context.go('/tracking', extra: orderId);
                }
              } else {
                if (mounted) {
                  context.go('/tracking');
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
              }
            } finally {
              if (mounted) {
                setState(() { _isProcessing = false; });
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isProcessing ? Colors.grey : const Color(0xFF1ABC9C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) 
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              else 
                const Icon(Icons.lock_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(_isProcessing ? "Traitement..." : "Confirmer et payer $total TND", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
      },
    );
  }
}
