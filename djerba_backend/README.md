# ⚙️ Djerba Delivery - Backend API

API REST haute performance développée avec **Next.js 16** et le micro-framework **Hono v4**, typée de bout en bout avec **TypeScript** et **Zod**, et interfacée avec **LibSQL (Turso)** via **Drizzle ORM** et **Upstash Redis**.

---

## 🏗️ Architecture Technique

- **Framework Web :** Hono v4 monté sur Next.js Edge / Node.js Runtime
- **Base de Données :** LibSQL / SQLite / Turso
- **ORM :** Drizzle ORM avec validation de schémas Zod
- **Cache & Dispatching Spatial :** Upstash Redis (`GEOADD`, `GEOSEARCH`)
- **Contrôle d'Accès :** Better-Auth RBAC (`client`, `driver`, `restaurant`, `admin`)
- **Notifications :** Firebase Cloud Messaging (FCM) & Nodemailer (SMTP)
- **IA Culinaire :** Pollinations AI proxy avec mise en cache CDN

---

## 📁 Organisation du Code (`src/`)

```plaintext
src/
├── app/                  # Points d'entrée Next.js
├── db/                   # Schémas Drizzle ORM (users, orders, restaurants, products)
└── server/
    ├── middlewares/      # Middlewares d'authentification RBAC et CORS
    ├── routes/           # Routes API REST (admin, ai, auth, drivers, orders, restaurants, users)
    └── services/         # Dispatch spatial, notifications FCM et Mutex distribué
```

---

## 🚀 Installation & Lancement

```bash
# 1. Installer les dépendances
npm install

# 2. Configurer les variables d'environnement
cp .env.example .env
# Renseigner les clés (Better-Auth, Turso, Upstash, SMTP)

# 3. Synchroniser le schéma de base de données
npm run db:push

# 4. Lancer le serveur de développement
npm run dev
# Serveur disponible sur http://localhost:3000
```

---

## 🧪 Scripts Utilitaires

- `npx tsx scripts/seed_orders.ts` : Injecte un jeu de commandes de test représentatives avec coordonnées géographiques sur Djerba.
