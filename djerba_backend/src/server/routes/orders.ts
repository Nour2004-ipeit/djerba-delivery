import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { db } from '../../db';
import { orders, orderItems, products, user } from '../../db/schema';
import { requireAuth } from '../middlewares/auth';
import { eq, inArray } from 'drizzle-orm';
import { restaurants } from '../../db/schema';
import { FCMService } from '../services/fcm';
import { DispatchService } from '../services/dispatch';

export const ordersRoute = new Hono()
  .post(
    '/',
    requireAuth(['client']),
    zValidator('json', z.object({
      restaurantId: z.string(),
      items: z.array(z.object({
        productId: z.string(),
        quantity: z.number().min(1),
        options: z.record(z.string()).optional(),
      })),
      deliveryAddress: z.string(),
      deliveryLat: z.number(),
      deliveryLng: z.number(),
    })),
    async (c) => {
      const authUser = c.get('user');
      const body = c.req.valid('json');

      try {
        // 1. Récupérer les prix actuels depuis la DB
        const productIds = body.items.map(i => i.productId);
        const dbProducts = await db.select().from(products).where(inArray(products.id, productIds));

        let subtotal = 0;
        const itemsToInsert = [];

        for (const item of body.items) {
          const dbProduct = dbProducts.find(p => p.id === item.productId);
          
          if (!dbProduct) {
            return c.json({ error: `Produit non trouvé: ${item.productId}` }, 404);
          }
          let price = dbProduct.price;
          let name = dbProduct.name;
          
          if (item.options) {
             if (item.options['Taille'] && dbProduct.variants) {
                const variant = dbProduct.variants.find((v: any) => v.name === item.options!['Taille']);
                if (variant) {
                   price = variant.price;
                }
             }
             const optionStrings = Object.entries(item.options).map(([k, v]) => `${v}`);
             if (optionStrings.length > 0) {
                name += ` (${optionStrings.join(', ')})`;
             }
          }
          
          if (dbProduct && !dbProduct.isAvailable) {
            return c.json({ error: `Produit indisponible: ${item.productId}` }, 400);
          }

          const lineTotal = price * item.quantity;
          subtotal += lineTotal;
          
          itemsToInsert.push({
            id: crypto.randomUUID(),
            productId: item.productId,
            productNameSnapshot: name,
            quantity: item.quantity,
            unitPriceSnapshot: price,
          });
        }

        const deliveryFee = 4.500; // Fixe pour le MVP
        const totalAmount = subtotal + deliveryFee;
        const orderId = crypto.randomUUID();
        const orderNumber = `CMD-${Date.now().toString().slice(-6)}`;

        // 2. Transaction SQL
        await db.transaction(async (tx) => {
          await tx.insert(orders).values({
            id: orderId,
            orderNumber,
            clientId: authUser.id,
            restaurantId: body.restaurantId,
            status: 'pending',
            subtotal,
            deliveryFee,
            totalAmount,
            deliveryAddress: body.deliveryAddress,
            deliveryLat: body.deliveryLat,
            deliveryLng: body.deliveryLng,
          });

          const itemsWithOrderId = itemsToInsert.map(i => ({ ...i, orderId }));
          await tx.insert(orderItems).values(itemsWithOrderId);
        });

        const admins = await db.select().from(user)
          .where(eq(user.role, 'restaurant_admin'));
        // Only notify the admin who owns this restaurant
        const restaurantResult = await db.select().from(restaurants).where(eq(restaurants.id, body.restaurantId)).get();
        if (restaurantResult) {
          await FCMService.sendNotificationToUser(restaurantResult.adminId, 'Nouvelle Commande', `Commande ${orderNumber} reçue !`);
        }

        return c.json({ success: true, orderId, orderNumber });
        
      } catch (error) {
        console.error("Order Error:", error);
        return c.json({ error: 'Erreur interne lors de la commande' }, 500);
      }
    }
  )
  // -----------------------------------------------------
  // GET /api/orders
  // Client gets their orders, Admin gets restaurant orders
  // -----------------------------------------------------
  .get('/', requireAuth(['client', 'admin', 'driver']), async (c) => {
    const user = c.get('user');
    
    try {
      let userOrders;
      if (user.role === 'client') {
        userOrders = await db.query.orders.findMany({
          where: eq(orders.clientId, user.id),
          with: { client: { columns: { name: true } }, items: true, driver: { columns: { name: true, image: true } }, restaurant: { columns: { name: true, imageUrl: true } } }
        });
      } else if (user.role === 'admin') {
        const adminRestaurant = await db.select().from(restaurants).where(eq(restaurants.adminId, user.id)).get();
        if (adminRestaurant) {
          userOrders = await db.query.orders.findMany({
            where: eq(orders.restaurantId, adminRestaurant.id),
            with: { client: { columns: { name: true } }, items: true, driver: { columns: { name: true, image: true } }, restaurant: { columns: { name: true, imageUrl: true } } }
          });
        } else {
          userOrders = [];
        }
      } else if (user.role === 'driver') {
        // Drivers only see orders that are active (not yet delivered/cancelled) and either unassigned or theirs
        userOrders = await db.query.orders.findMany({
          where: (orders, { or, and, eq: eqFn, inArray: inArr }) => inArr(orders.status, ['pending', 'accepted', 'preparing', 'ready_for_pickup', 'picked_up', 'arrived_at_place']),
          with: { client: { columns: { name: true } }, items: true, driver: { columns: { name: true, image: true } }, restaurant: { columns: { name: true, imageUrl: true } } }
        });
      } else {
        return c.json({ error: 'Unauthorized role' }, 403);
      }
      
      return c.json(userOrders);
    } catch (error) {
      console.error("Fetch Orders Error:", error);
      return c.json({ error: 'Erreur lors de la recupération des commandes' }, 500);
    }
  })
  // -----------------------------------------------------
  // PUT /api/orders/:id/status
  // Restaurant or Driver updates order status
  // -----------------------------------------------------
  .put('/:id/status', requireAuth(['admin', 'driver', 'client']), zValidator('json', z.object({
    status: z.enum(['pending', 'accepted', 'preparing', 'ready_for_pickup', 'picked_up', 'arrived_at_place', 'delivered', 'cancelled'])
  })), async (c) => {
    const id = c.req.param('id');
    const { status } = c.req.valid('json');
    const user = c.get('user');

    try {
      const currentOrder = await db.select().from(orders).where(eq(orders.id, id)).get();
      if (!currentOrder) return c.json({ error: 'Order not found' }, 404);

      const STATUS_WEIGHT: Record<string, number> = {
        'pending': 0, 'accepted': 1, 'preparing': 2, 'ready_for_pickup': 3,
        'picked_up': 4, 'arrived_at_place': 5, 'delivered': 6, 'cancelled': 99
      };

      let updateData: any = {};
      if (STATUS_WEIGHT[status] >= STATUS_WEIGHT[currentOrder.status]) {
        updateData.status = status;
      }
      if (status === 'accepted' && (user as any)?.role === 'driver') {
        // Tentative d'acquisition du verrou distribué atomique Redis Mutex (TTL = 10s)
        const acquired = await DispatchService.lockOrder(id, (user as any)?.id);
        if (!acquired || currentOrder.driverId) {
          return c.json({ error: "Course déjà assignée à un autre coursier" }, 409);
        }
        updateData.driverId = (user as any)?.id;
      }

      await db.update(orders).set(updateData).where(eq(orders.id, id));

      const updatedOrder = await db.select().from(orders).where(eq(orders.id, id)).get();
      if (updatedOrder) {
        // Notify the client about status change
        await FCMService.sendNotificationToUser(
          updatedOrder.clientId,
          'Mise à jour de commande',
          `Votre commande est maintenant : ${status}`
        );
      }

      return c.json({ success: true, status });
    } catch (error) {
      console.error("Update Order Error:", error);
      return c.json({ error: 'Erreur lors de la mise à jour' }, 500);
    }
  })
  // -----------------------------------------------------
  // GET /api/orders/:id/location
  // Client polls for driver location
  // -----------------------------------------------------
  .get('/:id/location', requireAuth(['client', 'admin']), async (c) => {
    const id = c.req.param('id');
    try {
      const order = await db.select().from(orders).where(eq(orders.id, id)).get();
      if (!order || !order.driverId) {
        return c.json({ lat: null, lng: null });
      }
      const { driverProfiles } = await import('../../db/schema');
      const driverProfile = await db.select().from(driverProfiles).where(eq(driverProfiles.userId, order.driverId)).get();
      return c.json({ 
        lat: driverProfile?.currentLat || null, 
        lng: driverProfile?.currentLng || null 
      });
    } catch (error) {
      console.error("Fetch Location Error:", error);
      return c.json({ error: 'Erreur lors de la recupération de la position' }, 500);
    }
  })
  // -----------------------------------------------------
  // GET /api/orders/:id
  // Client gets their order tracking info
  // -----------------------------------------------------
  .get('/:id', requireAuth(['client', 'admin', 'driver']), async (c) => {
    const id = c.req.param('id');
    try {
      const order = await db.query.orders.findFirst({
        where: eq(orders.id, id),
        with: {
          client: { columns: { name: true } },
          items: true,
          driver: { columns: { name: true, image: true } },
          restaurant: { columns: { name: true, lat: true, lng: true, imageUrl: true } }
        }
      });
      if (!order) return c.json({ error: 'Order not found' }, 404);
      return c.json(order);
    } catch (error) {
      console.error("Fetch Order Error:", error);
      return c.json({ error: 'Erreur lors de la recupération de la commande' }, 500);
    }
  });
