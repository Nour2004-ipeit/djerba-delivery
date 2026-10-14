import { Hono } from 'hono';
import { db } from '../../db';
import { restaurants, products } from '../../db/schema';
import { eq } from 'drizzle-orm';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { requireAuth } from '../middlewares/auth';
import { nanoid } from 'nanoid';

export const restaurantsRoute = new Hono()
  // Create a restaurant
  .post('/', requireAuth(['admin']), zValidator('json', z.object({
    name: z.string().min(1),
    description: z.string().optional(),
    address: z.string().min(1),
    lat: z.number(),
    lng: z.number(),
    imageUrl: z.string().url().optional(),
  })), async (c) => {
    const user = c.get('user');
    const data = c.req.valid('json');
    try {
      const newRestaurant = await db.insert(restaurants).values({
        id: `rest_${nanoid(10)}`,
        adminId: user.id,
        name: data.name,
        description: data.description,
        address: data.address,
        lat: data.lat,
        lng: data.lng,
        imageUrl: data.imageUrl ?? 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&q=80&w=600',
        isActive: true,
        isOpen: true,
      }).returning();
      return c.json(newRestaurant[0], 201);
    } catch (error) {
      console.error(error);
      return c.json({ error: 'Failed to create restaurant' }, 500);
    }
  })
  // Get my restaurant
  .get('/my-restaurant', requireAuth(['admin']), async (c) => {
    const user = c.get('user');
    try {
      const result = await db.select().from(restaurants).where(eq(restaurants.adminId, user.id));
      if (result.length === 0) return c.json({ error: 'Restaurant not found' }, 404);
      return c.json(result[0]);
    } catch (error) {
      console.error(error);
      return c.json({ error: 'Failed to fetch my restaurant' }, 500);
    }
  })
  // Get all active restaurants
  .get('/', async (c) => {
    try {
      const activeRestaurants = await db.select().from(restaurants).where(eq(restaurants.isActive, true));
      const allProducts = await db.select().from(products);
      
      const enriched = activeRestaurants.map(r => {
        const rProducts = allProducts.filter(p => p.restaurantId === r.id);
        const categories = rProducts.map(p => p.category).join(' ');
        const productNames = rProducts.map(p => p.name).join(' ');
        return {
          ...r,
          description: `${r.description} ${categories} ${productNames}`
        };
      });

      return c.json(enriched);
    } catch (error) {
      console.error(error);
      return c.json({ error: 'Failed to fetch restaurants' }, 500);
    }
  })

  // Global product search
  .get('/search/products', async (c) => {
    const q = c.req.query('q')?.toLowerCase() || '';
    try {
      const allProducts = await db.select().from(products);
      const activeRestaurants = await db.select().from(restaurants).where(eq(restaurants.isActive, true));
      
      const filtered = allProducts.filter(p => 
        p.name.toLowerCase().includes(q) || 
        (p.description && p.description.toLowerCase().includes(q)) || 
        p.category.toLowerCase().includes(q)
      );
      
      const enrichedProducts = filtered.map(p => {
        const r = activeRestaurants.find(rest => rest.id === p.restaurantId);
        return {
          ...p,
          restaurant: r ? { name: r.name, image: r.imageUrl } : null
        };
      });
      
      return c.json(enrichedProducts);
    } catch (error) {
      console.error(error);
      return c.json({ error: 'Failed to search products' }, 500);
    }
  })

  // Get specific restaurant by ID
  .get('/:id', async (c) => {
    const id = c.req.param('id');
    try {
      const result = await db.select().from(restaurants).where(eq(restaurants.id, id));
      if (result.length === 0) return c.json({ error: 'Restaurant not found' }, 404);
      return c.json(result[0]);
    } catch (error) {
      console.error(error);
      return c.json({ error: 'Failed to fetch restaurant' }, 500);
    }
  })

  // Update restaurant
  .patch('/:id', requireAuth(['admin']), zValidator('json', z.object({
    imageUrl: z.string().url().optional(),
  })), async (c) => {
    const id = c.req.param('id');
    const data = c.req.valid('json');
    try {
      const updated = await db.update(restaurants)
        .set({ imageUrl: data.imageUrl })
        .where(eq(restaurants.id, id))
        .returning();
      if (updated.length === 0) return c.json({ error: 'Restaurant not found' }, 404);
      return c.json(updated[0]);
    } catch (error) {
      console.error(error);
      return c.json({ error: 'Failed to update restaurant' }, 500);
    }
  })
  // Get products for a specific restaurant
  .get('/:id/products', async (c) => {
    const id = c.req.param('id');
    try {
      const restaurantProducts = await db
        .select()
        .from(products)
        .where(eq(products.restaurantId, id));

      return c.json(restaurantProducts);
    } catch (error) {
      console.error(error);
      return c.json({ error: 'Failed to fetch products' }, 500);
    }
  })
  // Create a product for a specific restaurant
  .post('/:id/products', requireAuth(['admin']), zValidator('json', z.object({
    name: z.string().min(1),
    description: z.string().optional(),
    price: z.number().positive(),
    category: z.string().optional().default('Général'),
    variants: z.array(z.object({ name: z.string(), price: z.number() })).optional(),
    imageUrl: z.string().url(),
  })), async (c) => {
    const id = c.req.param('id');
    const data = c.req.valid('json');
    try {
      const newProduct = await db.insert(products).values({
        id: 'prod_' + Math.random().toString(36).substring(2, 10),
        restaurantId: id,
        name: data.name,
        description: data.description ?? '',
        category: data.category,
        price: data.price,
        variants: data.variants,
        imageUrl: data.imageUrl,
        isAvailable: true,
      }).returning();
      return c.json(newProduct[0], 201);
    } catch (error) {
      console.error(error);
      return c.json({ error: 'Failed to create product' }, 500);
    }
  })
  // Toggle product availability
  .patch('/:id/products/:productId/availability', zValidator('json', z.object({
    isAvailable: z.boolean(),
  })), async (c) => {
    const productId = c.req.param('productId');
    const data = c.req.valid('json');
    try {
      const updated = await db.update(products)
        .set({ isAvailable: data.isAvailable })
        .where(eq(products.id, productId))
        .returning();
      if (updated.length === 0) return c.json({ error: 'Product not found' }, 404);
      return c.json(updated[0]);
    } catch (error) {
      console.error(error);
      return c.json({ error: 'Failed to update product' }, 500);
    }
  })
  // Delete product
  .delete('/:id/products/:productId', async (c) => {
    const productId = c.req.param('productId');
    try {
      const deleted = await db.delete(products).where(eq(products.id, productId)).returning();
      if (deleted.length === 0) return c.json({ error: 'Product not found' }, 404);
      return c.json({ success: true });
    } catch (error) {
      console.error(error);
      return c.json({ error: 'Failed to delete product' }, 500);
    }
  });
