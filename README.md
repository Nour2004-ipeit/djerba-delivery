<div align="center">

# 🏝️ Djerba Delivery
### Plateforme Intelligente Multi-Acteurs de Livraison Logistique Insulaire en Temps Réel

[![Next.js](https://img.shields.io/badge/Next.js-16.2-black?style=for-the-badge&logo=next.js)](https://nextjs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)](https://dart.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178C6?style=for-the-badge&logo=typescript)](https://www.typescriptlang.org/)
[![Hono](https://img.shields.io/badge/Hono-v4-E36002?style=for-the-badge&logo=hono)](https://hono.dev/)
[![Drizzle ORM](https://img.shields.io/badge/Drizzle_ORM-0.45-C5F74F?style=for-the-badge&logo=drizzle)](https://orm.drizzle.team/)
[![Upstash Redis](https://img.shields.io/badge/Upstash-Redis_Geo-00E599?style=for-the-badge&logo=redis)](https://upstash.com/)
[![OpenStreetMap](https://img.shields.io/badge/OpenStreetMap-Leaflet-7EBC6F?style=for-the-badge&logo=openstreetmap)](https://www.openstreetmap.org/)

<p align="center">
  <b>Stage de Fin d'Année Ingénieur GEC2 (2025–2026)</b><br>
  <b>Auteur :</b> Nour BEN DAOUED &nbsp;|&nbsp; <b>Établissement :</b> ENET'Com Sfax<br>
  <b>Entreprise d'accueil :</b> Loomens (Cyberparc Djerba) &nbsp;|&nbsp; <b>Encadrant :</b> Ayoub Jrab
</p>

[🎥 Vidéo Démo](#-démonstration-vidéo--supports) • [📊 Slides Soutenance](#-slides-de-soutenance) • [🏛️ Architecture](#-architecture-système-n-tiers) • [📱 Les 4 Applications](#-les-4-applications-de-lécosystème) • [⚡ Démarrage](#-guide-de-démarrage-rapide)

---

</div>

## 📌 Contexte & Problématique Insulaire

L'île de Djerba (514 km²) présente des spécificités territoriales et économiques majeures qui rendent les solutions de livraison traditionnelles (Yassir, Glovo) inadaptées :
- **Absence d'adressage cadastral officiel :** Pistes sablonneuses, Menzels traditionnels isolés, et absence de numérotation de rue exploitable entraînant 30 à 60 minutes de retard moyen par indications orales téléphoniques.
- **Forte saisonnalité & concentration hôtelière :** Triplement de la population en période estivale avec un afflux massif de résidents temporaires dans les complexes hôteliers de Midoun et de la Zone Touristique.
- **Souveraineté des coûts d'API :** Dépendance critique des solutions existantes envers Google Maps facturé en devises étrangères, insoutenable pour une jeune pousse locale.
- **Modèle économique lourd :** Commissions prélevées de 25% à 35% asphyxiant les restaurateurs insulaires.

**Djerba Delivery** résout cette équation via une architecture souveraine couplant cartographie open-source (**OpenStreetMap / Leaflet** à 0 € de surcoût d'API), algorithmes spatiaux temps réel (**Upstash Redis GEO**), modèle unilatéral anti-collision de commande, et intégration d'**IA générative culinaire**.

---

## 🎥 Démonstration Vidéo & Supports

| Ressource | Emplacement / Format | Description |
| :--- | :--- | :--- |
| **🎬 Démo Complète** | `demo.mp4` *(124 Mo - Bureau / Releases)* | Enregistrement de la séquence transactionnelle de bout en bout sur les 4 terminaux synchronisés. |
| **📑 Diaporama Officiel** | [`docs/presentation/Soutenance_Djerba_Delivery_2026.pdf`](docs/presentation/Soutenance_Djerba_Delivery_2026.pdf) | Présentation de soutenance (18 slides haute fidélité sans filigrane). |
| **📘 Guide Maître Backend** | [`docs/guides/Djerba_Backend_Master_Guide.pdf`](docs/guides/Djerba_Backend_Master_Guide.pdf) | Spécification technique approfondie de l'API Hono/Next.js, schémas Drizzle et flux Redis. |
| **📗 Guide d'Intégration** | [`docs/guides/Djerba_Delivery_Project_Guide.pdf`](docs/guides/Djerba_Delivery_Project_Guide.pdf) | Manuel complet de déploiement et d'architecture des 4 applications Flutter. |

---

## 🏛️ Architecture Système N-Tiers

L'écosystème repose sur un découpage modulaire à haute performance et haute résilience :

```mermaid
graph TD
    subgraph "Front-End (4 Applications Flutter / Dart 3)"
        C[📱 Client App<br/>Port 8080]
        R[👨‍🍳 Restaurant Dashboard<br/>Port 8081]
        D[🛵 Courier Driver App<br/>Port 8082]
        A[🛡️ Super-Admin Console<br/>Port 8083]
    end

    subgraph "API Gateway & Backend Edge"
        GW[⚡ Next.js 16 + Hono v4 Router<br/>Port 3000]
        AUTH[Better-Auth RBAC & Zod Schema Validation]
    end

    subgraph "Services & Données"
        DB[(LibSQL / SQLite / Turso<br/>Drizzle ORM)]
        REDIS[(Upstash Redis<br/>GEO Indexing + Distributed Mutex)]
        AI[Pollinations AI<br/>Photographie Culinaire Synthétique]
        FCM[Firebase Cloud Messaging<br/>Push Notifications]
    end

    C & R & D & A -->|REST / JWT Bearer| GW
    GW --> AUTH
    GW --> DB
    GW --> REDIS
    GW --> AI
    GW --> FCM
```

---

## 📱 Les 4 Applications de l'Écosystème

### 1. Application Client (Flutter Web & Mobile)
Conçue sur-mesure pour les résidents et vacanciers avec pointage GPS direct sur carte OpenStreetMap et bascule automatique « Livraison Hôtel » (Sélection de l'hôtel + n° de chambre sans ambiguïté).

<div align="center">
  <img src="report_screenshots/client_app/04_client_home.png" width="30%" alt="Accueil Client"/>
  <img src="report_screenshots/client_app/06_client_restaurant_menu.png" width="30%" alt="Menu Restaurant"/>
  <img src="report_screenshots/client_app/10_client_live_tracking_map.png" width="30%" alt="Suivi Coursier GPS"/>
</div>

### 2. Application Livreur / Courier (Flutter Mobile)
Ergonomie pensée pour l'usage à une main au guidon de scooter : stepper linéaire à action contextuelle unique, radar spatial de courses disponibles, guidage cartographique et prise d'appel client directe.

<div align="center">
  <img src="report_screenshots/driver_app/02_driver_dashboard_earnings.png" width="30%" alt="Dashboard Livreur"/>
  <img src="report_screenshots/driver_app/03_driver_tasks_available.png" width="30%" alt="Courses Disponibles"/>
  <img src="report_screenshots/driver_app/06_driver_active_delivery_map.png" width="30%" alt="Itinéraire Livraison"/>
</div>

### 3. Dashboard Restaurateur (Flutter Web & Tablette)
Gestion en direct des commandes par colonnes d'état Kanban réactives (À traiter, En préparation, Prêt coursier), gestionnaire dynamique de menu et générateur visuel de plats par IA.

<div align="center">
  <img src="report_screenshots/restaurant_dashboard/03_resto_orders_new_requests.png" width="30%" alt="Commandes à Traiter"/>
  <img src="report_screenshots/restaurant_dashboard/06_resto_menu_manager.png" width="30%" alt="Gestionnaire de Menu"/>
  <img src="report_screenshots/restaurant_dashboard/08_resto_add_product_modal_full.png" width="30%" alt="Ajout Produit IA"/>
</div>

### 4. Console Super-Admin (Flutter Web)
Pilotage global des flux logistiques insulaires, gestion des utilisateurs, validation des coursiers et paramétrage du modèle de commission équitable (15%).

<div align="center">
  <img src="report_screenshots/admin_dashboard/01_admin_platform_overview.png" width="45%" alt="Vue Globale Admin"/>
  <img src="report_screenshots/admin_dashboard/02_admin_user_management.png" width="45%" alt="Gestion Utilisateurs"/>
</div>

---

## 💡 Innovations Techniques & Algorithmes

### 📡 1. Radar Spatial 5 km (Upstash Redis GEO)
- Les coursiers actifs transmettent leurs coordonnées géographiques toutes les 15 secondes via `GEOADD`.
- Un mécanisme d'éviction automatique avec TTL de 300 s exclut silencieusement tout coursier inactif.
- Dès qu'une commande passe à l'état `ready_for_pickup`, le backend déclenche un `GEOSEARCH` à rayon de 5 km exécuté en mémoire en **moins de 15 millisecondes**, notifiant uniquement les livreurs pertinents.

### 🔒 2. Mutex Distribué Anti-Collision (`SET NX EX 10`)
Pour prévenir les conflits d'acceptation simultanée lorsque plusieurs coursiers cliquent en même temps sur une nouvelle course :
```typescript
// Acquisition atomique avec TTL de 10 secondes
const acquired = await DispatchService.lockOrder(orderId, driverId);
if (!acquired || currentOrder.driverId) {
  return c.json({ error: "Course déjà assignée à un autre coursier" }, 409); // 409 Conflict
}
// 200 OK -> Attribution unique garantie sans collision
```

### 📈 3. Machine d'État Strictement Monotone
Pour garantir l'intégrité absolue de la chaîne logistique, le statut d'une commande obéit à une fonction de poids strictement croissante :
$$\text{Poids}(\text{nouveau}) \ge \text{Poids}(\text{actuel})$$
```
pending (0) ➔ accepted (1) ➔ preparing (2) ➔ ready_for_pickup (3) ➔ picked_up (4) ➔ arrived_at_place (5) ➔ delivered (6)
```
*Toute tentative de régression (ex: tentative de repasser de `delivered` vers `preparing`) est immédiatement rejetée avec une erreur HTTP 400 Bad Request.*

### 🎨 4. IA Culinaire Générative (Pollinations AI + Cache HTTP)
Permet à n'importe quel petit gargotier ou restaurateur local de générer instantanément des photographies professionnelles et appétissantes de ses spécialités méditerranéennes sans engager de photographe professionnel, avec mise en cache CDN (`max-age=31536000`).

---

## 📂 Structure du Répertoire Monorepo

```plaintext
djerba-delivery-backend/
├── .github/workflows/           # Intégration continue & déploiement automatique Vercel
├── djerba_backend/              # API REST Next.js 16 + Hono v4 (TypeScript, Drizzle, LibSQL)
│   ├── src/
│   │   ├── app/                 # Routes Next.js
│   │   ├── db/                  # Schémas Drizzle ORM (users, orders, restaurants, products)
│   │   └── server/              # Moteur Hono (routes admin, ai, drivers, orders, auth)
│   ├── scripts/                 # Scripts de test & seeding (seed_orders.ts)
│   └── .env.example             # Modèle des variables d'environnement documentées
├── djerba_client_app/           # Application Mobile/Web Client Flutter
├── djerba_driver_app/           # Application Mobile Livreur Scooter Flutter
├── djerba_restaurant_dashboard/ # Dashboard Web Cuisine Restaurateur Flutter
├── djerba_admin_dashboard/      # Console Web Super-Admin Flutter
├── docs/                        # Documentation d'ingénierie & diaporama
│   ├── guides/                  # Guides PDF & HTML détaillés du projet et du backend
│   └── presentation/            # Soutenance officielle ENET'Com 2026 (PDF sans filigrane)
├── report_screenshots/          # Captures d'écran HD des 4 applications et diagrammes
├── quad_view.html               # Vue 4-en-1 synchronisée pour démonstration sur grand écran
├── serve_all.js                 # Serveur HTTP multi-ports orchestrant les 4 apps web + Quad View
└── .gitignore                   # Exclusion stricte des artefacts de build, secrets et logs
```

---

## 🚀 Guide de Démarrage Rapide

### Prérequis
- [Node.js](https://nodejs.org/) v20+
- [Flutter SDK](https://flutter.dev/) v3.22+
- Navigateur Chrome / Edge pour le mode Web multi-applications

### 1. Cloner le Répertoire
```bash
git clone https://github.com/<votre-nom-utilisateur>/djerba-delivery.git
cd djerba-delivery
```

### 2. Démarrer le Backend
```bash
cd djerba_backend
npm install
cp .env.example .env
# Renseignez vos clés dans .env, puis initialisez la base de données :
npm run db:push
npm run dev
# L'API Hono démarre sur http://localhost:3000
```

### 3. Lancer les 4 Applications Front-End Simultanément
Grâce à l'orchestrateur inclus `serve_all.js`, vous pouvez servir l'ensemble des 4 applications Flutter web en une seule commande :
```bash
# À la racine du projet :
node serve_all.js
```

Accédez ensuite à la vue en grille multi-écrans sur :
👉 **[http://localhost:8085](http://localhost:8085)** (*Quad View synchronisée*)

| Application | URL Directe | Port |
| :--- | :--- | :--- |
| **Application Client** | `http://localhost:8080` | 8080 |
| **Cuisine Restaurateur** | `http://localhost:8081` | 8081 |
| **Livreur Coursier** | `http://localhost:8082` | 8082 |
| **Console Super-Admin** | `http://localhost:8083` | 8083 |
| **Vue Grille 4-en-1** | `http://localhost:8085` | 8085 |

---

## 🎓 Remerciements & Affiliation Académique

Ce projet a été conçu et réalisé dans le cadre du **Stage de Perfectionnement Ingénieur (GEC2)** à l'**École Nationale d'Électronique et des Télécommunications de Sfax (ENET'Com)**, en collaboration avec la startup **Loomens** (Cyberparc Djerba).

- **Auteur :** Nour BEN DAOUED
- **Encadrant Industriel :** Ayoub Jrab (Loomens)
- **Année Académique :** 2025–2026 / 2026–2027

---
<div align="center">
  <i>Développé avec passion pour l'île des rêves, Djerba.</i>
</div>
