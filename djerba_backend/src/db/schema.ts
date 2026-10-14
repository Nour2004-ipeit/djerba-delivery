import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { relations } from 'drizzle-orm';

// ==========================================
// TABLE DES UTILISATEURS & AUTH
// ==========================================
export const user = sqliteTable('user', {
  id: text('id').primaryKey(),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  emailVerified: integer('emailVerified', { mode: 'boolean' }).notNull(),
  image: text('image'),
  createdAt: integer('createdAt', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updatedAt', { mode: 'timestamp' }).notNull(),
  // Custom fields
  role: text('role', { enum: ['client', 'driver', 'admin'] }).default('client'),
  phoneNumber: text('phoneNumber'),
  fcmToken: text('fcm_token'),
  phoneNumberVerified: integer('phoneNumberVerified', { mode: 'boolean' }),
  isActive: integer('is_active', { mode: 'boolean' }).default(true),
});

export const session = sqliteTable("session", {
  id: text("id").primaryKey(),
  expiresAt: integer('expiresAt', { mode: 'timestamp' }).notNull(),
  token: text('token').notNull().unique(),
  createdAt: integer('createdAt', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updatedAt', { mode: 'timestamp' }).notNull(),
  ipAddress: text('ipAddress'),
  userAgent: text('userAgent'),
  userId: text('userId').notNull().references(() => user.id)
});

export const account = sqliteTable("account", {
  id: text("id").primaryKey(),
  accountId: text('accountId').notNull(),
  providerId: text('providerId').notNull(),
  userId: text('userId').notNull().references(() => user.id),
  accessToken: text('accessToken'),
  refreshToken: text('refreshToken'),
  idToken: text('idToken'),
  accessTokenExpiresAt: integer('accessTokenExpiresAt', { mode: 'timestamp' }),
  refreshTokenExpiresAt: integer('refreshTokenExpiresAt', { mode: 'timestamp' }),
  scope: text('scope'),
  password: text('password'),
  createdAt: integer('createdAt', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updatedAt', { mode: 'timestamp' }).notNull()
});

export const verification = sqliteTable("verification", {
  id: text("id").primaryKey(),
  identifier: text('identifier').notNull(),
  value: text('value').notNull(),
  expiresAt: integer('expiresAt', { mode: 'timestamp' }).notNull(),
  createdAt: integer('createdAt', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updatedAt', { mode: 'timestamp' }).notNull()
});

// ==========================================
// TABLES DES LIVREURS (Extension Profil)
// ==========================================
export const passwordResetOtps = sqliteTable('password_reset_otps', {
  id: text('id').primaryKey(),
  userId: text('user_id').references(() => user.id, { onDelete: 'cascade' }).notNull(),
  identifier: text('identifier').notNull(), // Email where the OTP was sent
  otp: text('otp').notNull(),
  expiresAt: integer('expiresAt', { mode: 'timestamp' }).notNull(),
  createdAt: integer('createdAt', { mode: 'timestamp' }).$defaultFn(() => new Date()),
});

// ==========================================
// TABLES DES LIVREURS (Extension Profil)
// ==========================================
export const driverProfiles = sqliteTable('driver_profiles', {
  id: text('id').primaryKey(),
  userId: text('user_id').references(() => user.id, { onDelete: 'cascade' }).notNull().unique(),
  vehicleType: text('vehicle_type', { enum: ['moto', 'bicycle', 'car'] }).default('moto'),
  licensePlate: text('license_plate'),
  cashCollected: real('cash_collected').default(0), // Argent liquide récupéré pour l'app
  status: text('status', { enum: ['offline', 'available', 'busy'] }).default('offline'),
  currentLat: real('current_lat'),
  currentLng: real('current_lng'),
});

// ==========================================
// TABLES DES RESTAURANTS & CATALOGUE
// ==========================================
export const restaurants = sqliteTable('restaurants', {
  id: text('id').primaryKey(),
  adminId: text('admin_id').references(() => user.id, { onDelete: 'cascade' }).notNull(),
  name: text('name').notNull(),
  description: text('description'),
  address: text('address').notNull(),
  lat: real('lat').notNull(),
  lng: real('lng').notNull(),
  commissionRate: real('commission_rate').default(0.15), // 15% par défaut
  rating: real('rating').default(5.0),
  isActive: integer('is_active', { mode: 'boolean' }).default(true),
  isOpen: integer('is_open', { mode: 'boolean' }).default(true),
  imageUrl: text('image_url'),
  createdAt: integer('created_at', { mode: 'timestamp' }).$defaultFn(() => new Date()),
});

export const products = sqliteTable('products', {
  id: text('id').primaryKey(),
  restaurantId: text('restaurant_id').references(() => restaurants.id, { onDelete: 'cascade' }).notNull(),
  name: text('name').notNull(),
  description: text('description'),
  price: real('price').notNull(), // Toujours stocker la plus petite unité (ex: centimes)
  category: text('category').default('Général'),
  variants: text('variants', { mode: 'json' }).$type<{name: string, price: number}[]>(),
  isAvailable: integer('is_active', { mode: 'boolean' }).default(true),
  imageUrl: text('image_url'),
});

// ==========================================
// TABLES DES COMMANDES (LE CŒUR DU SYSTÈME)
// ==========================================
export const orders = sqliteTable('orders', {
  id: text('id').primaryKey(),
  orderNumber: text('order_number').unique().notNull(), // Ex: CMD-20260608-001
  clientId: text('client_id').references(() => user.id).notNull(),
  restaurantId: text('restaurant_id').references(() => restaurants.id).notNull(),
  driverId: text('driver_id').references(() => user.id),
  
  // Statuts stricts
  status: text('status', { 
    enum: ['pending', 'accepted', 'preparing', 'ready_for_pickup', 'picked_up', 'arrived_at_place', 'delivered', 'cancelled'] 
  }).notNull().default('pending'),
  
  // Détails financiers
  subtotal: real('subtotal').notNull(),
  deliveryFee: real('delivery_fee').notNull(),
  totalAmount: real('total_amount').notNull(),
  
  // Livraison
  deliveryAddress: text('delivery_address').notNull(),
  deliveryLat: real('delivery_lat').notNull(),
  deliveryLng: real('delivery_lng').notNull(),
  
  // Timestamps de suivi
  createdAt: integer('created_at', { mode: 'timestamp' }).$defaultFn(() => new Date()),
  acceptedAt: integer('accepted_at', { mode: 'timestamp' }),
  pickedUpAt: integer('picked_up_at', { mode: 'timestamp' }),
  deliveredAt: integer('delivered_at', { mode: 'timestamp' }),
});

export const orderItems = sqliteTable('order_items', {
  id: text('id').primaryKey(),
  orderId: text('order_id').references(() => orders.id, { onDelete: 'cascade' }).notNull(),
  productId: text('product_id').references(() => products.id).notNull(),
  productNameSnapshot: text('product_name_snapshot').notNull(), // Important: Historisation du nom si le resto change sa carte
  quantity: integer('quantity').notNull(),
  unitPriceSnapshot: real('unit_price_snapshot').notNull(), // Historisation du prix
});

// ==========================================
// RELATIONS DRIZZLE (Pour les jointures faciles)
// ==========================================
export const orderRelations = relations(orders, ({ one, many }) => ({
  client: one(user, { fields: [orders.clientId], references: [user.id] }),
  driver: one(user, { fields: [orders.driverId], references: [user.id] }),
  restaurant: one(restaurants, { fields: [orders.restaurantId], references: [restaurants.id] }),
  items: many(orderItems),
}));

export const orderItemsRelations = relations(orderItems, ({ one }) => ({
  order: one(orders, { fields: [orderItems.orderId], references: [orders.id] }),
  product: one(products, { fields: [orderItems.productId], references: [products.id] }),
}));
