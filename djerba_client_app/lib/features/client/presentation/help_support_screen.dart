import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Widget _buildFaqItem(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                "Ceci est une réponse générique pour la FAQ. Dans une application réelle, cette réponse contiendrait des informations utiles pour le client concernant sa commande, son compte, ou le fonctionnement de l'application.",
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text('Aide et Support', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text("Comment pouvons-nous vous aider ?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.2)),
          const SizedBox(height: 24),
          
          // Contact Options
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: DjerbaTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: DjerbaTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.chat_bubble_outline, color: DjerbaTheme.primaryColor, size: 32),
                      SizedBox(height: 12),
                      Text("Chat en direct", style: TextStyle(fontWeight: FontWeight.bold, color: DjerbaTheme.primaryColor)),
                      SizedBox(height: 4),
                      Text("Réponse < 2 min", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.phone_in_talk_outlined, color: Colors.orange, size: 32),
                      SizedBox(height: 12),
                      Text("Appelez-nous", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                      SizedBox(height: 4),
                      Text("75 650 000", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // FAQs
          const Text("Questions Fréquentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFaqItem("Où est ma commande ?"),
          _buildFaqItem("J'ai un problème avec un plat."),
          _buildFaqItem("Comment utiliser un code promo ?"),
          _buildFaqItem("Comment changer mon adresse de livraison ?"),
          _buildFaqItem("Puis-je annuler ma commande ?"),
        ],
      ),
    );
  }
}
