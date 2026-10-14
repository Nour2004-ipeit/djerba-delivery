# 🛵 Djerba Delivery - Courier Driver App

Application mobile Flutter conçue sur-mesure pour les livreurs et coursiers motorisés sur le terrain djerbien.

## ✨ Fonctionnalités Clés
- **Ergonomie Guidon à Une Main :** Interface simplifiée au maximum avec boutons tactiles de grande taille pour une manipulation aisée au guidon.
- **Radar Spatial 5 km :** Réception instantanée des courses prêtes dans un rayon de 5 km via indexation spatiale Redis.
- **Verrou Atomique Anti-Collision :** Garantie qu'une course ne peut être attribuée qu'à un seul livreur (Mutex distribué).
- **Stepper Linéaire Monotone :** Progression unilatérale de livraison à action unique (*En route vers resto*, *Arrivé au resto*, *Commande récupérée*, *En route vers client*, *Livré*).
- **Guidage & Itinéraire :** Affichage cartographique précis vers les hôtels et Menzels isolés.

## 🚀 Lancement Local
```bash
flutter pub get
flutter run -d chrome --web-port 8082
```
