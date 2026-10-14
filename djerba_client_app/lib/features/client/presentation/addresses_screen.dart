import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'user_service.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DjerbaTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text("Mes adresses", style: TextStyle(color: DjerbaTheme.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: ListenableBuilder(
        listenable: UserService(),
        builder: (context, _) {
          final addresses = UserService().addresses;
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: address.isDefault ? DjerbaTheme.primaryColor.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: address.isDefault ? DjerbaTheme.primaryColor : Colors.grey.withOpacity(0.2),
                    width: address.isDefault ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: address.isDefault ? DjerbaTheme.primaryColor : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        address.title.toLowerCase() == 'maison' ? Icons.home : Icons.work,
                        color: address.isDefault ? Colors.white : Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(address.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              if (address.isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: DjerbaTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text("Défaut", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(address.details, style: const TextStyle(color: DjerbaTheme.textSecondary, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                UserService().addAddress(
                  DeliveryAddress(id: DateTime.now().toString(), title: 'Nouvelle adresse', details: 'Avenue Habib Bourguiba', isDefault: false),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DjerbaTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Ajouter une adresse", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
