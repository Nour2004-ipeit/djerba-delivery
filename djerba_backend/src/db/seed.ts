import { db } from './index';
import { restaurants, products } from './schema';
import { crypto } from 'crypto';

async function seed() {
  console.log('Seeding Database...');

  // Clear existing data (optional, but good for resetting)
  await db.delete(products);
  await db.delete(restaurants);

  const darElBahrId = 'rest_001';
  const casaBellaId = 'rest_002';
  const lamphitriteId = 'rest_003';

  // Insert Restaurants
  await db.insert(restaurants).values([
    {
      id: darElBahrId,
      name: 'Dar El Bahr',
      description: 'Cuisine traditionnelle djerbienne avec vue sur mer',
      address: 'Zone Touristique, Midoun',
      lat: 33.8315,
      lng: 11.0028,
      commissionRate: 0.15,
      rating: 4.8,
      isActive: true,
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1541518763669-27fef04b14ea?auto=format&fit=crop&q=80&w=600',
    },
    {
      id: casaBellaId,
      name: 'Casa Bella Djerba',
      description: 'Pizzas au feu de bois et spécialités italiennes',
      address: 'Route Touristique, Houmt Souk',
      lat: 33.8732,
      lng: 10.8583,
      commissionRate: 0.15,
      rating: 4.6,
      isActive: true,
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&q=80&w=600',
    },
    {
      id: lamphitriteId,
      name: 'L\'Amphitrite',
      description: 'Fruits de mer frais et poissons locaux',
      address: 'Port de Pêche, Aghir',
      lat: 33.7845,
      lng: 11.0234,
      commissionRate: 0.15,
      rating: 4.9,
      isActive: true,
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&q=80&w=600',
    },
  ]);

  // Insert Products
  await db.insert(products).values([
    // Dar El Bahr Products
    {
      id: 'prod_001',
      restaurantId: darElBahrId,
      name: 'Couscous au poisson (Bouri)',
      description: 'Couscous traditionnel préparé avec du mulet frais, légumes et épices de l\'île.',
      price: 24.500,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1541518763669-27fef04b14ea?auto=format&fit=crop&q=80&w=400',
    },
    {
      id: 'prod_002',
      restaurantId: darElBahrId,
      name: 'Brik à l\'œuf',
      description: 'Feuille de brick croustillante farcie au thon, persil et œuf coulant.',
      price: 4.500,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?auto=format&fit=crop&q=80&w=400',
    },
    // Casa Bella Products
    {
      id: 'prod_003',
      restaurantId: casaBellaId,
      name: 'Pizza Margherita',
      description: 'Sauce tomate maison, mozzarella fior di latte, basilic frais.',
      price: 18.000,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&q=80&w=400',
    },
    {
      id: 'prod_004',
      restaurantId: casaBellaId,
      name: 'Pâtes aux fruits de mer',
      description: 'Spaghetti aux crevettes, calmars et moules de Djerba.',
      price: 28.000,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?auto=format&fit=crop&q=80&w=400',
    },
    // L'Amphitrite Products
    {
      id: 'prod_005',
      restaurantId: lamphitriteId,
      name: 'Daurade Grillée',
      description: 'Daurade royale pêchée du jour, grillée au feu de bois, accompagnée de salade méchouia.',
      price: 35.000,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?auto=format&fit=crop&q=80&w=400',
    }
  ]);

  console.log('Database seeded successfully!');
  process.exit(0);
}

seed().catch((e) => {
  console.error(e);
  process.exit(1);
});
