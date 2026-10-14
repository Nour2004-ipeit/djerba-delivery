import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(item.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                if (item.options.isNotEmpty)
                  Text(item.options.entries.map((e) => '${e.key}: ${e.value}').join(', '), style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 12)),
                if (item.description != null)
                  Text(item.description!, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: "${item.price * item.quantity}", style: const TextStyle(color: DjerbaTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 16)),
                          const TextSpan(text: " TND", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ]
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => CartService().removeItem(item.id),
                            child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove, size: 16, color: DjerbaTheme.primaryColor)),
                          ),
                          const SizedBox(width: 8),
                          Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => CartService().addItem(item.productId, item.restaurantId, item.name, item.price, item.imageUrl, options: item.options, description: item.description),
                            child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 16, color: DjerbaTheme.primaryColor)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? 18 : 14,
                  fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
                  color: isTotal ? DjerbaTheme.textPrimary : DjerbaTheme.textSecondary,
                ),
              ),
              if (label == 'Service') ...[
                const SizedBox(width: 4),
                const Icon(Icons.info_outline, size: 14, color: DjerbaTheme.textTertiary),
              ]
            ],
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: DjerbaTheme.textPrimary,
                    fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
                    fontSize: isTotal ? 22 : 14,
                  ),
                ),
                TextSpan(
                  text: " TND",
                  style: TextStyle(
                    color: isTotal ? DjerbaTheme.textPrimary : DjerbaTheme.textSecondary,
                    fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
                    fontSize: isTotal ? 14 : 12,
                  ),
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartService(),
      builder: (context, _) {
        final items = CartService().items.values.toList();
        final subtotal = CartService().totalPrice;
        final total = subtotal > 0 ? subtotal + 5 : 0;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: DjerbaTheme.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: const Text("Mon panier", style: TextStyle(color: DjerbaTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 20)),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Delivery Time Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_filled, color: Colors.orange),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Livraison estimée", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text("30 - 45 min", style: TextStyle(color: Colors.orange.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text("Votre commande", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 16),

                      // Items
                      if (items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: Text("Votre panier est vide", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 16))),
                        )
                      else
                        ...items.map((item) => _buildCartItem(item)),
                      const SizedBox(height: 16),

                      // Promo Code
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Icon(Icons.local_offer_outlined, color: DjerbaTheme.textTertiary, size: 20),
                            ),
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Code promo",
                                  hintStyle: TextStyle(color: DjerbaTheme.textTertiary, fontSize: 14),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text("Appliquer", style: TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Pricing Breakdown
                      _buildSummaryRow("Sous-total", "$subtotal"),
                      _buildSummaryRow("Livraison", "3"),
                      _buildSummaryRow("Service", "2"),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),
                      _buildSummaryRow("Total", "$total", isTotal: true),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Checkout Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: ElevatedButton(
                    onPressed: items.isEmpty ? null : () {
                      context.push('/checkout');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DjerbaTheme.primaryColor,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Passer la commande • $total TND", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
